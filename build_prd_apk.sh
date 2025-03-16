#!/bin/bash

# Flutter APK Build Script
# Automatically increment version and build APK

# Exit on error
set -e

echo "===== Flutter APK Build Script ====="

# Read current version from pubspec.yaml
CURRENT_VERSION=$(grep -o "version: [0-9]*\.[0-9]*\.[0-9]*" pubspec.yaml | cut -d ' ' -f 2)
echo "Current version: $CURRENT_VERSION"

# Split into major, minor, patch
MAJOR=$(echo $CURRENT_VERSION | cut -d. -f1)
MINOR=$(echo $CURRENT_VERSION | cut -d. -f2)
PATCH=$(echo $CURRENT_VERSION | cut -d. -f3)

# Increment patch version
NEW_PATCH=$((PATCH + 1))
NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH"
echo "New version: $NEW_VERSION"

# Update pubspec.yaml with new version
sed -i.bak "s/version: $CURRENT_VERSION/version: $NEW_VERSION/g" pubspec.yaml
rm pubspec.yaml.bak

echo "Updated pubspec.yaml to version $NEW_VERSION"

# Clean and get packages
echo "Cleaning project..."
flutter clean

echo "Getting packages..."
flutter pub get

# Build APK
echo "Building release APK..."
flutter build apk --release

# Copy and rename APK
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
NEW_APK_NAME="vynthra-$NEW_VERSION.apk"
RELEASE_DIR="release/android/apk"

# Create release directory if it doesn't exist
mkdir -p "$RELEASE_DIR"

if [ -f "$APK_PATH" ]; then
    cp "$APK_PATH" "$RELEASE_DIR/$NEW_APK_NAME"
    echo "✅ Build successful!"
    echo "APK created: $RELEASE_DIR/$NEW_APK_NAME"
else
    echo "❌ Build failed: APK not found at $APK_PATH"
    exit 1
fi

# Show file info
if [ -f "$RELEASE_DIR/$NEW_APK_NAME" ]; then
    echo "File size: $(du -h "$RELEASE_DIR/$NEW_APK_NAME" | cut -f1)"
    echo "======================================"
    echo "APK is ready for distribution in $RELEASE_DIR folder"
fi