#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────
# setup_device_farm.sh
# Setup self-hosted runner sebagai mobile device farm
#
# Jalankan SEKALI di Mac yang akan digunakan sebagai device farm.
# Script ini:
#   1. Checks & installs system dependencies (Homebrew, Node, ADB, Appium)
#   2. Installs Appium drivers (UiAutomator2 for Android, XCUITest for iOS)
#   3. Configures Appium as a launchd service (auto-start on boot)
#   4. Prints runner registration instructions for GitHub Actions
#
# Usage:
#   chmod +x ci_cd/scripts/setup_device_farm.sh
#   ./ci_cd/scripts/setup_device_farm.sh [--ios] [--android-only]
# ────────────────────────────────────────────────────────────

set -euo pipefail

APPIUM_PORT=4723
INSTALL_IOS=false
ANDROID_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ios)          INSTALL_IOS=true; shift ;;
    --android-only) ANDROID_ONLY=true; shift ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   Indodax QA — Device Farm Setup                ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# ── 1. Homebrew ───────────────────────────────────────────
echo "── [1/7] Homebrew ───────────────────────────────────"
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✅ Homebrew: $(brew --version | head -1)"
fi

# ── 2. Node.js (untuk Appium) ─────────────────────────────
echo ""
echo "── [2/7] Node.js ────────────────────────────────────"
if ! command -v node &>/dev/null; then
  echo "Installing Node.js via Homebrew..."
  brew install node
else
  echo "✅ Node.js: $(node --version)"
fi

# ── 3. Appium ─────────────────────────────────────────────
echo ""
echo "── [3/7] Appium ─────────────────────────────────────"
if ! command -v appium &>/dev/null; then
  echo "Installing Appium 2..."
  npm install -g appium
else
  echo "✅ Appium: $(appium --version)"
fi

# ── 4. Android platform tools ─────────────────────────────
echo ""
echo "── [4/7] Android platform-tools (ADB) ──────────────"
if ! command -v adb &>/dev/null; then
  echo "Installing android-platform-tools..."
  brew install android-platform-tools
else
  echo "✅ ADB: $(adb version | head -1)"
fi

# ── 5. Appium UiAutomator2 driver ─────────────────────────
echo ""
echo "── [5/7] Appium UiAutomator2 driver ─────────────────"
if ! appium driver list --installed 2>/dev/null | grep -q uiautomator2; then
  echo "Installing UiAutomator2 driver..."
  appium driver install uiautomator2
else
  echo "✅ UiAutomator2 driver installed"
fi

# ── 6. XCUITest driver (iOS) ──────────────────────────────
if [[ "$INSTALL_IOS" == true ]] && [[ "$ANDROID_ONLY" == false ]]; then
  echo ""
  echo "── [6/7] Appium XCUITest driver (iOS) ───────────────"
  if ! appium driver list --installed 2>/dev/null | grep -q xcuitest; then
    echo "Installing XCUITest driver..."
    appium driver install xcuitest
  else
    echo "✅ XCUITest driver installed"
  fi
else
  echo ""
  echo "── [6/7] iOS driver skipped (pass --ios to install) ─"
fi

# ── 7. Appium launchd service ─────────────────────────────
echo ""
echo "── [7/7] Appium auto-start service ──────────────────"
PLIST="$HOME/Library/LaunchAgents/com.indodax.appium.plist"
APPIUM_BIN=$(which appium)

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.indodax.appium</string>
  <key>ProgramArguments</key>
  <array>
    <string>${APPIUM_BIN}</string>
    <string>--port</string>
    <string>${APPIUM_PORT}</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/appium.stdout.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/appium.stderr.log</string>
</dict>
</plist>
EOF

launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "✅ Appium launchd service registered → auto-starts on login"

# ── Check connected devices ───────────────────────────────
echo ""
echo "── Android Devices ──────────────────────────────────"
adb devices

# ── Final instructions ────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║   ✅ Device Farm Setup Complete!                         ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║                                                          ║"
echo "║   Appium is now running on http://127.0.0.1:4723         ║"
echo "║                                                          ║"
echo "║   Next: Register this Mac as a GitHub Actions runner:    ║"
echo "║                                                          ║"
echo "║   1. Go to your repo → Settings → Actions → Runners      ║"
echo "║   2. Click 'New self-hosted runner' → macOS              ║"
echo "║   3. Follow the download + configure steps               ║"
echo "║   4. Add labels: device-farm, macOS                      ║"
echo "║   5. Run:  ./run.sh --labels 'self-hosted,macOS,device-farm' ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
