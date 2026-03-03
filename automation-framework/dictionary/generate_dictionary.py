#!/usr/bin/env python3
"""
generate_dictionary.py
──────────────────────
Scan all .robot files and generate a keyword_dictionary.robot file.

Output format:
  *** Settings ***   — Resource imports grouped by test type (CMD+clickable paths)
  *** Keywords ***   — [Index] stub keywords per file (CMD+clickable keyword names)

Usage:
    uv run python dictionary/generate_dictionary.py
"""

import re
import os
from datetime import datetime
from collections import defaultdict

SKIP_DIRS = {"results", "__pycache__", ".venv", "pabot_results", ".git", "scripts"}
KEYWORD_SECTION = re.compile(r"^\*+\s*Keywords?\s*\*+")
NEW_SECTION = re.compile(r"^\*+")
KW_DEFINITION = re.compile(r"^(?!#)(?!\.\.\.)([A-Za-z\u00C0-\u024F][^\n\[\$].*)")

GROUPS = ["API", "Web", "Mobile Android", "Mobile iOS", "Common"]

OUTPUT_FILE = "dictionary/keyword_dictionary.robot"
REPORT_FILE = "dictionary/keyword_report.txt"

SEP = "═" * 58
DIV = "─" * 74


def classify(rel_path: str) -> str:
    p = rel_path.replace("\\", "/").lower()
    if "mobile" in p and "ios" in p:
        return "Mobile iOS"
    if "mobile" in p:
        return "Mobile Android"
    if "api" in p:
        return "API"
    if "web" in p:
        return "Web"
    return "Common"


def is_mobile_android(rel_path: str) -> bool:
    p = rel_path.replace("\\", "/").lower()
    return "mobile" in p and "android" in p


def is_mobile_ios(rel_path: str) -> bool:
    p = rel_path.replace("\\", "/").lower()
    return "mobile" in p and "ios" in p


def scan_files(root: str) -> dict[str, list[str]]:
    """Return {rel_file_path: [keyword_names_in_source_order]}."""
    file_kws: dict[str, list[str]] = {}
    for dirpath, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for fname in sorted(files):
            if not fname.endswith(".robot"):
                continue
            filepath = os.path.join(dirpath, fname)
            rel = os.path.relpath(filepath, root)
            kws: list[str] = []
            in_keywords = False
            with open(filepath, encoding="utf-8", errors="ignore") as fh:
                for line in fh:
                    stripped = line.rstrip()
                    if KEYWORD_SECTION.match(stripped):
                        in_keywords = True
                        continue
                    if NEW_SECTION.match(stripped):
                        in_keywords = False
                        continue
                    if in_keywords:
                        m = KW_DEFINITION.match(stripped)
                        if m:
                            kw_name = m.group(1).strip()
                            if kw_name:
                                kws.append(kw_name)
            if kws:
                file_kws[rel] = kws
    return file_kws


def build_duplicate_map(file_kws: dict[str, list[str]]) -> dict[str, list[str]]:
    """Return {keyword_name: [file, ...]} for keywords defined in >1 file.

    Intentional cross-platform duplicates are excluded — keywords that appear
    only across mobile/android and mobile/ios paths are by-design platform
    overrides, not real duplicates.
    """
    kw_files: dict[str, list[str]] = defaultdict(list)
    for rel_file, kws in file_kws.items():
        for kw in kws:
            kw_files[kw].append(rel_file)

    result: dict[str, list[str]] = {}
    for kw, files in kw_files.items():
        if len(files) <= 1:
            continue
        android_files = [f for f in files if is_mobile_android(f)]
        ios_files     = [f for f in files if is_mobile_ios(f)]
        other_files   = [f for f in files if not is_mobile_android(f) and not is_mobile_ios(f)]
        # Skip if ALL occurrences are purely cross-platform android/ios pairs
        if android_files and ios_files and not other_files:
            continue
        result[kw] = files
    return result


def resource_path(scripts_dir: str, root: str, rel_file: str) -> str:
    return os.path.relpath(os.path.join(root, rel_file), scripts_dir).replace("\\", "/")


def main():
    root = os.path.abspath(".")
    scripts_dir = os.path.join(root, "scripts")

    file_kws = scan_files(root)
    dupes = build_duplicate_map(file_kws)
    total_kw = sum(len(v) for v in file_kws.values()) - sum(len(v) - 1 for v in dupes.values())

    # ── Group files ───────────────────────────────────────────────
    grouped: dict[str, list[str]] = {g: [] for g in GROUPS}
    for rel_file in sorted(file_kws.keys()):
        grouped[classify(rel_file)].append(rel_file)

    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    lines: list[str] = []

    # ══════════════════════════════════════════════════════════════
    # *** Settings ***
    # ══════════════════════════════════════════════════════════════
    lines += [
        "*** Settings ***",
        f"Documentation    Keyword Dictionary — Auto-generated on {now}",
        "...",
        "...              ╔══════════════════════════════════════════════════════╗",
        "...              ║  CMD+click keyword name di dalam body [Index] mana  ║",
        "...              ║  pun → langsung lompat ke definisi di source file.  ║",
        "...              ╚══════════════════════════════════════════════════════╝",
        "...",
        f"...              Total keywords : {total_kw}  |  Duplicates : {len(dupes)}",
        "...              Regenerate     : uv run python scripts/generate_dictionary.py",
        "",
    ]

    for group in GROUPS:
        files = grouped[group]
        if not files:
            continue
        total_g = sum(len(file_kws[f]) for f in files)
        lines += [
            f"# {SEP}",
            f"# {group} — {len(files)} file(s), {total_g} keyword(s)",
            f"# {SEP}",
        ]
        for rel_file in files:
            lines.append(f"Resource    {resource_path(scripts_dir, root, rel_file)}")
        lines.append("")

    # ══════════════════════════════════════════════════════════════
    # *** Keywords ***
    # ══════════════════════════════════════════════════════════════
    lines += [
        "",
        "*** Keywords ***",
        f"# {DIV}",
        "# Cara pakai:",
        "#   CMD+click pada nama keyword di dalam body [Index] mana pun",
        "#   → RobotCode resolve reference secara statik & buka file + baris sumber.",
        "#",
        "#   [Index] keywords di bawah TIDAK untuk dieksekusi (tag: skip).",
        f"# {DIV}",
        "",
    ]

    for group in GROUPS:
        files = grouped[group]
        if not files:
            continue
        lines += [
            f"# {SEP}",
            f"# {group}",
            f"# {SEP}",
            "",
        ]
        for rel_file in files:
            fname = os.path.basename(rel_file)
            kws = file_kws[rel_file]
            kw_count = len(kws)
            dupe_note = ""
            dupe_kws = [kw for kw in kws if kw in dupes]
            if dupe_kws:
                dupe_note = f"  (⚠️ duplicate: {', '.join(dupe_kws)})"
            lines += [
                f"[Index] {fname}",
                f"    [Documentation]    {fname} — {kw_count} keyword{'s' if kw_count != 1 else ''}{dupe_note}",
                "    [Tags]    index    norun    skip",
            ]
            for kw in kws:
                lines.append(f"    {kw}")
            lines.append("")

    # ── Write output ──────────────────────────────────────────────
    out_path = os.path.join(root, OUTPUT_FILE)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    # ── Write duplicate report ────────────────────────────────────
    report_lines = [
        "Robot Framework Keyword Dictionary — Duplicate Report",
        "=" * 56,
        f"Generated : {now}",
        f"Total     : {total_kw} unique keywords",
        f"Duplicates: {len(dupes)}",
        "",
    ]
    if dupes:
        report_lines.append("⚠️  Duplicate keywords (defined in multiple files):")
        for kw, files in sorted(dupes.items()):
            report_lines.append(f"\n  [{kw}]")
            for f in files:
                report_lines.append(f"    → {f}")
    else:
        report_lines.append("✅ No duplicate keywords found.")

    rpt_path = os.path.join(root, REPORT_FILE)
    with open(rpt_path, "w", encoding="utf-8") as f:
        f.write("\n".join(report_lines))

    status = f"⚠️  {len(dupes)} duplicate(s)" if dupes else "✅ No duplicates"
    print(f"{status} | {total_kw} keywords | Dictionary → {OUTPUT_FILE} | Report → {REPORT_FILE}")
    if dupes:
        print("\n⚠️  Duplicate keywords:")
        for kw, files in sorted(dupes.items()):
            print(f"   [{kw}]")
            for f in files:
                print(f"     → {f}")


if __name__ == "__main__":
    main()
