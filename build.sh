#!/bin/bash

# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Build web with environment variables
flutter build web --release \
--dart-define=SUPABASE_URL=https://njqfiogesszlxfcseioj.supabase.co \
--dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qcWZpb2dlc3N6bHhmY3NlaW9qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE4Njc1ODQsImV4cCI6MjA1NzQ0MzU4NH0.KSq0DDQhnuuzTHMdQA6VePV2xfPIJnbr-ohgffzMfcQ \
--dart-define=OPENAI_API_KEY=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 \
--dart-define=OPENAI_API_URL=https://api.openai.com/v1

echo "Build completed! Files are in build/web/" 