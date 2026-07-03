#!/bin/bash

# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Build web with environment variables
flutter build web --release \
--dart-define=OPENAI_API_KEY=${OPENAI_API_KEY} \
--dart-define=OPENAI_API_URL=https://api.openai.com/v1

echo "Build completed! Files are in build/web/" 