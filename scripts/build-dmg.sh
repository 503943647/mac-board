#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VOLUME_NAME="MacBoard"
VERSION="0.2.3"
FINAL_DMG="$ROOT/dist/MacBoard-$VERSION-universal.dmg"
RW_DMG="$ROOT/dist/.MacBoard-$VERSION-rw.dmg"
STAGE="$(mktemp -d /tmp/macboard-stage.XXXXXX)"
MOUNT="/Volumes/$VOLUME_NAME"

cleanup() {
  hdiutil detach "$MOUNT" >/dev/null 2>&1 || true
  rm -rf "$STAGE" "$RW_DMG"
}
trap cleanup EXIT INT TERM

cd "$ROOT"
"$ROOT/scripts/build-app.sh" >/dev/null
swift build -c release --arch x86_64 --scratch-path .build-x86_64 --product fanmenu
swift build -c release --arch x86_64 --scratch-path .build-x86_64 --product fanctl
swift build -c release --arch x86_64 --scratch-path .build-x86_64 --product fanhelper

APP="$STAGE/MacBoard.app"
cp -R "$ROOT/dist/MacBoard.app" "$APP"
lipo -create "$ROOT/.build/release/fanmenu" "$ROOT/.build-x86_64/release/fanmenu" -output "$APP/Contents/MacOS/MacBoard"
lipo -create "$ROOT/.build/release/fanctl" "$ROOT/.build-x86_64/release/fanctl" -output "$APP/Contents/MacOS/fanctl"
lipo -create "$ROOT/.build/release/fanhelper" "$ROOT/.build-x86_64/release/fanhelper" -output "$APP/Contents/MacOS/fanhelper"

codesign --force --sign - --timestamp=none "$APP/Contents/MacOS/fanctl"
codesign --force --sign - --timestamp=none "$APP/Contents/MacOS/fanhelper"
codesign --force --sign - --timestamp=none "$APP"
codesign --verify --deep --strict "$APP"

mkdir -p "$STAGE/.background"
cp "$ROOT/.build/visual-assets/dmg-background.png" "$STAGE/.background/background.png"
cp "$ROOT/.build/visual-assets/MacBoard.icns" "$STAGE/.VolumeIcon.icns"
ln -s /Applications "$STAGE/Applications"

rm -f "$RW_DMG" "$FINAL_DMG"
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$STAGE" -ov -format UDRW "$RW_DMG" >/dev/null
hdiutil detach "$MOUNT" >/dev/null 2>&1 || true
hdiutil attach "$RW_DMG" -readwrite -noverify -noautoopen -mountpoint "$MOUNT" >/dev/null

SetFile -a V "$MOUNT/.background" "$MOUNT/.VolumeIcon.icns"
SetFile -a C "$MOUNT"

osascript <<APPLESCRIPT
set backgroundFile to POSIX file "$MOUNT/.background/background.png" as alias
tell application "Finder"
  tell disk "$VOLUME_NAME"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set pathbar visible of container window to false
    set bounds of container window to {120, 120, 780, 520}
    set viewOptions to the icon view options of container window
    set arrangement of viewOptions to not arranged
    set icon size of viewOptions to 104
    set text size of viewOptions to 14
    set background picture of viewOptions to backgroundFile
    set position of item "MacBoard.app" of container window to {160, 215}
    set position of item "Applications" of container window to {500, 215}
    update without registering applications
    delay 2
    close
    delay 1
  end tell
end tell
APPLESCRIPT

sync
sleep 2
hdiutil detach "$MOUNT" >/dev/null
hdiutil convert "$RW_DMG" -format UDZO -imagekey zlib-level=9 -o "$FINAL_DMG" >/dev/null

echo "$FINAL_DMG"
