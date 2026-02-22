#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────
# run_api.sh — Jalankan API tests (Public dan/atau Private)
#
# Usage:
#   ./ci_cd/scripts/run_api.sh [options]
#
# Options:
#   -e, --env       Environment: dev | staging | production (default: staging)
#   -s, --suite     Suite: public | private | all (default: all)
#   -t, --tags      Robot tags filter, e.g. "smoke"
#   -o, --output    Output directory (default: results/api)
#   -h, --help      Show this help
#
# Examples:
#   ./ci_cd/scripts/run_api.sh
#   ./ci_cd/scripts/run_api.sh -e production -s public
#   ./ci_cd/scripts/run_api.sh -e staging -s private -t smoke
# ────────────────────────────────────────────────────────────

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────
ENV="staging"
SUITE="all"
TAGS=""
OUTPUT_BASE="results/api"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ── Parse args ────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--env)       ENV="$2";    shift 2 ;;
    -s|--suite)     SUITE="$2";  shift 2 ;;
    -t|--tags)      TAGS="$2";   shift 2 ;;
    -o|--output)    OUTPUT_BASE="$2"; shift 2 ;;
    -h|--help)
      head -30 "$0" | grep '^#' | sed 's/^# \?//'
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
else
  echo "⚠️  $ENV_FILE not found, using existing environment variables"
fi

# ── Tags arg ──────────────────────────────────────────────
TAGS_ARG=""
if [[ -n "$TAGS" ]]; then
  TAGS_ARG="--include $TAGS"
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# ── Run Public ────────────────────────────────────────────
run_public() {
  echo ""
  echo "═══════════════════════════════════════"
  echo "  🔌 Running Public API Tests"
  echo "  ENV: $ENV  |  Tags: ${TAGS:-all}"
  echo "═══════════════════════════════════════"
  robot \
    --outputdir "${OUTPUT_BASE}/public" \
    --output    "output_${TIMESTAMP}.xml" \
    --log       "log_${TIMESTAMP}.html" \
    --report    "report_${TIMESTAMP}.html" \
    --variable  "ENV:${ENV}" \
    --loglevel  INFO \
    --timestampoutputs \
    $TAGS_ARG \
    tests/api/indodax_public_api.robot
}

# ── Run Private ───────────────────────────────────────────
run_private() {
  echo ""
  echo "═══════════════════════════════════════"
  echo "  🔐 Running Private API Tests"
  echo "  ENV: $ENV  |  Tags: ${TAGS:-all}"
  echo "═══════════════════════════════════════"

  if [[ -z "${INDODAX_API_KEY:-}" ]] || [[ -z "${INDODAX_API_SECRET:-}" ]]; then
    echo "❌ INDODAX_API_KEY / INDODAX_API_SECRET not set"
    echo "   Set them via environment or .env.${ENV}"
    exit 1
  fi

  robot \
    --outputdir "${OUTPUT_BASE}/private" \
    --output    "output_${TIMESTAMP}.xml" \
    --log       "log_${TIMESTAMP}.html" \
    --report    "report_${TIMESTAMP}.html" \
    --variable  "ENV:${ENV}" \
    --loglevel  INFO \
    --timestampoutputs \
    $TAGS_ARG \
    tests/api/indodax_private_api.robot
}

# ── Dispatch ──────────────────────────────────────────────
case "$SUITE" in
  public)  run_public ;;
  private) run_private ;;
  all)
    run_public
    run_private
    echo ""
    echo "📊 Merging XML reports..."
    mkdir -p "${OUTPUT_BASE}/merged"
    rebot \
      --outputdir "${OUTPUT_BASE}/merged" \
      --output    "output.xml" \
      --log       "log.html" \
      --report    "report.html" \
      --name      "Indodax API Suite — ${ENV}" \
      "${OUTPUT_BASE}/public/output_${TIMESTAMP}.xml" \
      "${OUTPUT_BASE}/private/output_${TIMESTAMP}.xml"
    echo "✅ Merged report: ${OUTPUT_BASE}/merged/report.html"
    ;;
  *)
    echo "❌ Unknown suite: $SUITE (must be: public | private | all)"
    exit 1
    ;;
esac

echo ""
echo "✅ API tests done. Results: ${FRAMEWORK_DIR}/${OUTPUT_BASE}"
