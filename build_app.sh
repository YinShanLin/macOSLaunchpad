#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BINARY_NAME="ApplicationsCenter"
APP_NAME="启动台"
BUILD_DIR="$PROJECT_DIR/.build"
BUNDLE_PATH="$PROJECT_DIR/$APP_NAME.app"

echo "==> 编译 Release 版本..."
swift build -c release --product "$BINARY_NAME"

BINARY="$BUILD_DIR/release/$BINARY_NAME"
if [ ! -f "$BINARY" ]; then
    echo "错误：编译产物未找到 $BINARY"
    exit 1
fi

echo "==> 生成 App 图标..."
ICONSET_DIR="$BUILD_DIR/AppIcon.iconset"
ICNS_PATH="$BUILD_DIR/AppIcon.icns"
rm -rf "$ICONSET_DIR" "$ICNS_PATH"
mkdir -p "$ICONSET_DIR"

swift "$PROJECT_DIR/Scripts/generate_icon.swift" "$ICONSET_DIR" > /dev/null 2>&1

iconutil -c icns "$ICONSET_DIR" -o "$ICNS_PATH" 2>&1

echo "==> 创建 .app bundle..."
rm -rf "$BUNDLE_PATH"
mkdir -p "$BUNDLE_PATH/Contents/MacOS"
mkdir -p "$BUNDLE_PATH/Contents/Resources"

cp "$BINARY" "$BUNDLE_PATH/Contents/MacOS/$BINARY_NAME"
cp "$ICNS_PATH" "$BUNDLE_PATH/Contents/Resources/AppIcon.icns"

cat > "$BUNDLE_PATH/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$BINARY_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.appcenter.launchpad</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSMultipleInstancesProhibited</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026. All rights reserved.</string>
</dict>
</plist>
EOF

cat > "$BUNDLE_PATH/Contents/PkgInfo" <<EOF
APPL????
EOF

echo "==> Ad-hoc 签名..."
codesign --force --deep --sign - "$BUNDLE_PATH" 2>/dev/null || true

echo ""
echo "✅ 构建成功: $BUNDLE_PATH"

case "${1:-}" in
    -o|--open)
        open "$BUNDLE_PATH"
        echo "  已启动"
        ;;
    -i|--install)
        cp -R "$BUNDLE_PATH" "/Applications/"
        echo "  已安装到 /Applications/$APP_NAME.app"
        open "$BUNDLE_PATH"
        ;;
esac
