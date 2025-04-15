#!/bin/bash

# Create directory for the temporary files
mkdir -p tmp_ipa
cd tmp_ipa

# Extract the IPA file
unzip -q ../build/ios/ipa/*.ipa

# Create the privacy manifest file
cat > PrivacyInfo.xcprivacy << 'EOF'
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

# Add the privacy manifest to the share_plus framework
cp PrivacyInfo.xcprivacy Payload/*.app/Frameworks/share_plus.framework/

# Repackage the IPA
rm -f ../build/ios/ipa/modified.ipa
zip -qr ../build/ios/ipa/modified.ipa Payload

# Clean up
cd ..
rm -rf tmp_ipa

echo "Modified IPA created at build/ios/ipa/modified.ipa" 