#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT="${1:-$ROOT/.build/visual-assets}"
ICONSET="$OUTPUT/MacBoard.iconset"
MASTER_ICON="$OUTPUT/app-icon-1024.png"

rm -rf "$OUTPUT"
mkdir -p "$ICONSET"

sips -s format png "$ROOT/assets/app-icon.svg" --out "$MASTER_ICON" >/dev/null

make_icon() {
  pixels="$1"
  name="$2"
  sips -z "$pixels" "$pixels" "$MASTER_ICON" --out "$ICONSET/$name" >/dev/null
}

make_icon 16 icon_16x16.png
make_icon 32 icon_16x16@2x.png
make_icon 32 icon_32x32.png
make_icon 64 icon_32x32@2x.png
make_icon 128 icon_128x128.png
make_icon 256 icon_128x128@2x.png
make_icon 256 icon_256x256.png
make_icon 512 icon_256x256@2x.png
make_icon 512 icon_512x512.png
make_icon 1024 icon_512x512@2x.png

iconutil -c icns "$ICONSET" -o "$OUTPUT/MacBoard.icns"
sips -s format png "$ROOT/assets/dmg-background.svg" --out "$OUTPUT/dmg-background.png" >/dev/null

echo "$OUTPUT"
