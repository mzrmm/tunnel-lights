#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/build/VPN Menu Bar.app"
SDK="$(xcrun --sdk macosx --show-sdk-path)"
SWIFTC="$(xcrun --sdk macosx --find swiftc)"
mkdir -p "$APP/Contents/MacOS"
"$SWIFTC" -parse-as-library -sdk "$SDK" -target arm64-apple-macosx13.0 -O -framework AppKit -framework ServiceManagement "$ROOT/Sources/main.swift" -o "$APP/Contents/MacOS/VPNMenuBar"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>VPNMenuBar</string>
<key>CFBundleIdentifier</key><string>de.local.vpnmenubar</string>
<key>CFBundleName</key><string>VPN Menu Bar</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>6.1</string>
<key>CFBundleVersion</key><string>61</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign --force --deep --sign - "$APP"
echo "App erstellt: $APP"
echo "Kopiere sie für Autostart nach /Applications und starte sie dort."
open "$APP"
