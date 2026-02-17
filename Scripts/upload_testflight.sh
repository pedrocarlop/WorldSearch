#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${REPO_ROOT}/build/TestFlight"
ARCHIVE_PATH="${BUILD_DIR}/WorldCrush.xcarchive"
EXPORT_OPTIONS_PLIST="${BUILD_DIR}/ExportOptions.plist"
PROJECT_PATH="${REPO_ROOT}/WorldCrush.xcodeproj"
SCHEME="WorldCrush"
TEAM_ID="MM9BHDUA97"

if [[ "${SKIP_TESTFLIGHT_UPLOAD:-0}" == "1" ]]; then
  echo "Skipping TestFlight upload because SKIP_TESTFLIGHT_UPLOAD=1."
  exit 0
fi

mkdir -p "${BUILD_DIR}"

cat > "${EXPORT_OPTIONS_PLIST}" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>destination</key>
    <string>upload</string>
    <key>method</key>
    <string>app-store-connect</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>uploadSymbols</key>
    <true/>
    <key>testFlightInternalTestingOnly</key>
    <false/>
</dict>
</plist>
PLIST

echo "[TestFlight] Archiving ${SCHEME}..."
xcodebuild \
  -project "${PROJECT_PATH}" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "${ARCHIVE_PATH}" \
  -allowProvisioningUpdates \
  clean archive

echo "[TestFlight] Uploading archive to App Store Connect..."
xcodebuild \
  -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}" \
  -allowProvisioningUpdates

echo "[TestFlight] Upload finished."
