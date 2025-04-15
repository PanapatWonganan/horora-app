#!/bin/bash

# Get the path to the built app
APP_PATH="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

# Create privacy manifest template
PRIVACY_MANIFEST_CONTENT='{
  "NSPrivacyAccessedAPITypes": [
    {
      "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryUserDefaults",
      "NSPrivacyAccessedAPITypeReasons": ["CA92.1"]
    }
  ],
  "NSPrivacyTracking": false
}'

# List of third-party frameworks that need privacy manifests
FRAMEWORKS=("share_plus")

# Add privacy manifest to each framework
for FRAMEWORK in "${FRAMEWORKS[@]}"; do
  FRAMEWORK_DIR="${APP_PATH}/${FRAMEWORK}.framework"
  
  if [ -d "$FRAMEWORK_DIR" ]; then
    echo "Adding privacy manifest to ${FRAMEWORK}.framework"
    echo "$PRIVACY_MANIFEST_CONTENT" > "${FRAMEWORK_DIR}/PrivacyInfo.xcprivacy"
  else
    echo "Framework ${FRAMEWORK}.framework not found"
  fi
done 