#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/Fan Controller.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"

cd "$ROOT"
swift build -c release --product fanmenu
swift build -c release --product fanctl
swift build -c release --product fanhelper

rm -rf "$APP"
mkdir -p "$MACOS"
cp "$ROOT/.build/release/fanmenu" "$MACOS/Fan Controller"
cp "$ROOT/.build/release/fanctl" "$MACOS/fanctl"
cp "$ROOT/.build/release/fanhelper" "$MACOS/fanhelper"

cat > "$CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>Fan Controller</string>
  <key>CFBundleIdentifier</key>
  <string>local.fan-controller.menu</string>
  <key>CFBundleName</key>
  <string>Fan Controller</string>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleLocalizations</key>
  <array>
    <string>en</string>
    <string>zh-Hans</string>
    <string>zh-Hant</string>
    <string>ja</string>
    <string>ko</string>
    <string>es</string>
    <string>fr</string>
    <string>de</string>
    <string>pt</string>
    <string>ru</string>
  </array>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.2</string>
  <key>CFBundleVersion</key>
  <string>3</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

echo "$APP"
