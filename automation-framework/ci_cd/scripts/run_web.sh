#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────
# run_web.sh — Jalankan Web tests dengan Playwright
#
# Usage:
#   ./ci_cd/scripts/run_web.sh [options]
#
# Options:
#   -e, --env       Environment: dev | staging | production (default: staging)
#   -b, --browser   Browser: chromium | firefox | webkit | all (default: chromium)
#   -H, --headless  Headless mode: true | false (default: true)
#   -t, --tags      Robot tags filter, e.g. "smoke"
#   -o, --output    Output directory (default: results/web)
#   -h, --help      Show this help
#
# Examples:
#   ./ci_cd/scripts/run_web.sh
#   ./ci_cd/scripts/run_web.sh -e production -b chromium -H false
#   ./ci_cd/scripts/run_web.sh -b all
# ────────────────────────────────────────────────────────────

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────
ENV="staging"
BROWSER="chromium"
HEADLESS="true"
TAGS=""
OUTPUT_BASE="results/web"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ── Parse args ────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--env)      ENV="$2";      shift 2 ;;
    -b|--browser)  BROWSER="$2";  shift 2 ;;
    -H|--headless) HEADLESS="$2"; shift 2 ;;
    -t|--tags)     TAGS="$2";     shift 2 ;;
    -o|--output)   OUTPUT_BASE="$2"; shift 2 ;;
    -h|--help)
      head -25 "$0" | grep '^#' | sed 's/^# \?//'
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Load env file ─────────────────────────────────────────
cd "$FRAMEWORK_DIR"

ENV_FILE=".env.${ENV}"
if [[ -f "$ENV_FILE" ]]; then
  echo "📂 Loading $ENV_FILE"
  set -o allexport
  source "$ENV_FILE"
  set +o allexport
fi

TAGS_ARG=""
if [[ -n "$TAGS" ]]; then
  TAGS_ARG="--include $TAGS"
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# ── Single browser run ────────────────────────────────────
run_browser() {
  local b="$1"
  echo ""
  echo "═══════════════════════════════════════"
  echo "  🌐 Web Tests — $b (headless=$HEADLESS)"
  echo "  ENV: $ENV"
  echo "═══════════════════════════════════════"

  # Init browser jika belum ada
  echo "🔧 Initializing Playwright browser: $b"
  rfbrowser init "$b"

  robot \
    --outputdir "${OUTPUT_BASE}/${b}" \
    --output    "output_${TIMESTAMP}.xml" \
    --log       "log_${TIMESTAMP}.html" \
    --report    "report_${TIMESTAMP}.html" \
    --variable  "ENV:${ENV}" \
    --variable  "BROWSER:${b}" \
    --variable  "HEADLESS:${HEADLESS}" \
    --variable  "WEB_BASE_URL:${WEB_BASE_URL:-}" \
    --loglevel  INFO \
    --timestampoutputs \
    $TAGS_ARG \
    tests/web/
}

# ── Dispatch ──────────────────────────────────────────────
if [[ "$BROWSER" == "all" ]]; then
  for b in chromium firefox webkit; do
    run_browser "$b"
  done
  
  echo ""
  echo "📊 Merging all browser reports..."
  mkdir -p "${OUTPUT_BASE}/merged"
  rebot \
    --outputdir "${OUTPUT_BASE}/merged" \
    --output    "output.xml" \
    --log       "log.html" \
    --report    "report.html" \
    --name      "Indodax Web Suite (All Browsers) — ${ENV}" \
    "${OUTPUT_BASE}/chromium/output_${TIMESTAMP}.xml" \
    "${OUTPUT_BASE}/firefox/output_${TIMESTAMP}.xml" \
    "${OUTPUT_BASE}/webkit/output_${TIMESTAMP}.xml"
  echo "✅ Merged report: ${OUTPUT_BASE}/merged/report.html"
else
  run_browser "$BROWSER"
fi

echo ""
echo "✅ Web tests done. Results: ${FRAMEWORK_DIR}/${OUTPUT_BASE}"
