#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/MacBoard.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

cd "$ROOT"
swift build -c release --product fanmenu
swift build -c release --product fanctl
swift build -c release --product fanhelper

rm -rf "$APP"
mkdir -p "$MACOS" "$RESOURCES"
cp "$ROOT/.build/release/fanmenu" "$MACOS/MacBoard"
cp "$ROOT/.build/release/fanctl" "$MACOS/fanctl"
cp "$ROOT/.build/release/fanhelper" "$MACOS/fanhelper"
"$ROOT/scripts/generate-visual-assets.sh" "$ROOT/.build/visual-assets" >/dev/null
cp "$ROOT/.build/visual-assets/MacBoard.icns" "$RESOURCES/MacBoard.icns"

cat > "$CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>MacBoard</string>
  <key>CFBundleIdentifier</key>
  <string>local.fan-controller.menu</string>
  <key>CFBundleName</key>
  <string>MacBoard</string>
  <key>CFBundleIconFile</key>
  <string>MacBoard.icns</string>
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
  <string>0.2.1</string>
  <key>CFBundleVersion</key>
  <string>6</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

echo "$APP"
