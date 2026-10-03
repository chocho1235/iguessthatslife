#!/bin/bash
# Archives LifeSim with Xcode and uploads it straight to TestFlight.
#
# Run on a Mac with Xcode, signed in to your Apple ID under
# Xcode > Settings > Accounts:
#
#   TEAM_ID=ABCDE12345 ./scripts/testflight.sh
#
# Your team ID is on developer.apple.com > Account > Membership details.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -z "${TEAM_ID:-}" ]; then
  echo "Set TEAM_ID first, for example: TEAM_ID=ABCDE12345 ./scripts/testflight.sh"
  exit 1
fi

BUILD_DIR="build/testflight"
ARCHIVE="$BUILD_DIR/LifeSim.xcarchive"
# TestFlight refuses a build number it has already seen, so use the time.
BUILD_NUMBER="$(date +%Y%m%d%H%M)"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cat > "$BUILD_DIR/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>destination</key>
    <string>upload</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
PLIST

echo "Archiving build $BUILD_NUMBER..."
xcodebuild archive \
  -project LifeSim.xcodeproj \
  -scheme LifeSim \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE" \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CURRENT_PROJECT_VERSION="$BUILD_NUMBER"

echo "Uploading to TestFlight..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" \
  -exportPath "$BUILD_DIR/export" \
  -allowProvisioningUpdates

echo "Done. Build $BUILD_NUMBER is uploading to App Store Connect and will show up in TestFlight once Apple finishes processing it."
