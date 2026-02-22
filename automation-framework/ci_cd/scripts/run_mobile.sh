#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────
# run_mobile.sh — Jalankan Mobile tests di local device farm
#
# Usage:
#   ./ci_cd/scripts/run_mobile.sh [options]
#
# Options:
#   -e, --env       Environment: dev | staging | production (default: production)
#   -p, --platform  Platform: android | ios (default: android)
#   -d, --device    Device serial / UDID (default: auto-detect pertama)
#   -s, --suite     Test file path relative ke tests/mobile/ (default: search_and_validate_eth.robot)
#   -t, --tags      Robot tags filter
#   -o, --output    Output base directory (default: results/mobile)
#       --no-appium Skip Appium server check (pakai yang sudah jalan)
#   -h, --help      Show this help
#
# Examples:
#   ./ci_cd/scripts/run_mobile.sh
#   ./ci_cd/scripts/run_mobile.sh -e production -d R8AIGF001200RC6
#   ./ci_cd/scripts/run_mobile.sh -p ios -d 00008030-001234567890
#   ./ci_cd/scripts/run_mobile.sh -s debug_search_flow.robot -t smoke
# ────────────────────────────────────────────────────────────

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────
ENV="production"
PLATFORM="android"
DEVICE=""
SUITE="search_and_validate_eth.robot"
TAGS=""
OUTPUT_BASE="results/mobile"
APPIUM_PORT=4723
SKIP_APPIUM=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ── Parse args ────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--env)       ENV="$2";      shift 2 ;;
    -p|--platform)  PLATFORM="$2"; shift 2 ;;
    -d|--device)    DEVICE="$2";   shift 2 ;;
    -s|--suite)     SUITE="$2";    shift 2 ;;
    -t|--tags)      TAGS="$2";     shift 2 ;;
    -o|--output)    OUTPUT_BASE="$2"; shift 2 ;;
    --no-appium)    SKIP_APPIUM=true; shift ;;
    -h|--help)
      head -28 "$0" | grep '^#' | sed 's/^# \?//'
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

cd "$FRAMEWORK_DIR"

# ── Load mobile env file ───────────────────────────────────
MOBILE_ENV_FILE=".env.mobile.${ENV}"
if [[ -f "$MOBILE_ENV_FILE" ]]; then
  echo "📂 Loading $MOBILE_ENV_FILE"
  set -o allexport
  source "$MOBILE_ENV_FILE"
  set +o allexport
else
  echo "⚠️  $MOBILE_ENV_FILE not found, continuing with current env"
fi

# ── Appium check ──────────────────────────────────────────
if [[ "$SKIP_APPIUM" == false ]]; then
  echo "🔍 Checking Appium server on port $APPIUM_PORT..."
  if curl -sf "http://127.0.0.1:${APPIUM_PORT}/status" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if d.get('value',{}).get('ready') else 1)" 2>/dev/null; then
    echo "✅ Appium is ready"
  else
    echo "⚡ Starting Appium server..."
    nohup appium --port "$APPIUM_PORT" --log /tmp/appium.log &
    APPIUM_PID=$!
    echo "   PID: $APPIUM_PID — waiting 5s..."
    sleep 5
    if curl -sf "http://127.0.0.1:${APPIUM_PORT}/status" >/dev/null 2>&1; then
      echo "✅ Appium started (PID $APPIUM_PID)"
    else
      echo "❌ Appium failed to start. Check /tmp/appium.log"
      exit 1
    fi
  fi
fi

# ── Device resolution ─────────────────────────────────────
if [[ "$PLATFORM" == "android" ]]; then
  if [[ -z "$DEVICE" ]]; then
    DEVICE=$(adb devices 2>/dev/null | grep "device$" | head -1 | awk '{print $1}')
  fi

  if [[ -z "$DEVICE" ]]; then
    echo "❌ No Android device found via adb. Connect a device and retry."
    exit 1
  fi

  echo "📱 Android device: $DEVICE"
  DEVICE_VAR="DEVICE_NAME"

elif [[ "$PLATFORM" == "ios" ]]; then
  if [[ -z "$DEVICE" ]]; then
    DEVICE=$(xcrun xctrace list devices 2>/dev/null \
      | grep -v Simulator | grep -v "==" \
      | head -1 \
      | grep -Eo '\([0-9A-F-]{36}\)' | tr -d '()' || echo "")
  fi

  if [[ -z "$DEVICE" ]]; then
    echo "❌ No iOS device found. Connect via USB and trust the computer."
    exit 1
  fi

  echo "📱 iOS device UDID: $DEVICE"
  DEVICE_VAR="DEVICE_UDID"
else
  echo "❌ Unknown platform: $PLATFORM (must be: android | ios)"
  exit 1
fi

# ── Tags ──────────────────────────────────────────────────
TAGS_ARG=""
[[ -n "$TAGS" ]] && TAGS_ARG="--include $TAGS"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# ── Run ───────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════"
echo "  📱 Mobile Tests — $PLATFORM"
echo "  Suite : $SUITE"
echo "  Device: $DEVICE"
echo "  ENV   : $ENV"
echo "═══════════════════════════════════════"

robot \
  --outputdir "${OUTPUT_BASE}/${PLATFORM}" \
  --output    "output_${TIMESTAMP}.xml" \
  --log       "log_${TIMESTAMP}.html" \
  --report    "report_${TIMESTAMP}.html" \
  --variable  "ENV:${ENV}" \
  --variable  "PLATFORM:${PLATFORM}" \
  --variable  "${DEVICE_VAR}:${DEVICE}" \
  --variable  "APPIUM_SERVER:http://127.0.0.1:${APPIUM_PORT}" \
  --loglevel  INFO \
  --timestampoutputs \
  $TAGS_ARG \
  "tests/mobile/${SUITE}"

echo ""
echo "✅ Mobile tests done. Results: ${FRAMEWORK_DIR}/${OUTPUT_BASE}/${PLATFORM}"
