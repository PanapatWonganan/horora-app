#!/bin/bash

# Create temporary directory
mkdir -p tmp_ipa
cd tmp_ipa

# Extract the IPA file
unzip -q ../build/ios/ipa/*.ipa

# Find the share_plus.framework directory
SHARE_PLUS_DIR=$(find Payload -name "share_plus.framework")

if [ -z "$SHARE_PLUS_DIR" ]; then
  echo "Error: share_plus.framework not found in the IPA file"
  exit 1
fi

echo "Found share_plus.framework at: $SHARE_PLUS_DIR"

# Create the privacy manifest file
cat > "$SHARE_PLUS_DIR/PrivacyInfo.xcprivacy" << 'EOF'
{
  "NSPrivacyAccessedAPITypes": [
    {
      "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryUserDefaults",
      "NSPrivacyAccessedAPITypeReasons": ["CA92.1"]
    }
  ],
  "NSPrivacyTracking": false
}
EOF

echo "Added privacy manifest to share_plus.framework"

# Repackage the IPA
rm -f ../build/ios/ipa/modified.ipa
zip -qr ../build/ios/ipa/modified.ipa Payload

echo "Modified IPA created at build/ios/ipa/modified.ipa"

# Clean up
cd ..
rm -rf tmp_ipa 