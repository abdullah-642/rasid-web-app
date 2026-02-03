#!/bin/bash
set -e

# Define variables
FLUTTER_CHANNEL="stable"
FLUTTER_Git_URL="https://github.com/flutter/flutter.git"

echo "---------------------------------------------"
echo "🚀 Netlify Build Script for Flutter"
echo "---------------------------------------------"

# 1. Install Flutter
if [ -d "flutter" ]; then
    echo "✅ Flutter found in cache"
else
    echo "⬇️  Cloning Flutter $FLUTTER_CHANNEL..."
    git clone -b $FLUTTER_CHANNEL $FLUTTER_Git_URL flutter
fi

# 2. Add to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Diagnostics
echo "🔍 Flutter Version:"
flutter --version

# 4. Config
echo "⚙️  Enabling Web..."
flutter config --enable-web

# 5. Build
echo "📦 Building Web Release..."
flutter build web --release

echo "---------------------------------------------"
echo "✅ Build Completed Successfully"
echo "---------------------------------------------"
