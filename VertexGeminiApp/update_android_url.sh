#!/bin/bash

# Script to update Android app with Cloud Run URL after deployment

if [ -z "$1" ]; then
    echo "Usage: $0 <cloud-run-url>"
    echo "Example: $0 https://flask-chat-app-902882112756.asia-northeast3.run.app/"
    exit 1
fi

CLOUD_RUN_URL="$1"

echo "🔄 Updating Android app to use Cloud Run URL: $CLOUD_RUN_URL"

# Update build.gradle with the actual Cloud Run URL
sed -i "s|https://flask-chat-app-902882112756.asia-northeast3.run.app/|${CLOUD_RUN_URL}/|g" android/app/build.gradle

echo "✅ Android app updated successfully!"
echo "📱 Release builds will now use: ${CLOUD_RUN_URL}/"
echo "🐛 Debug builds will still use: http://10.0.2.2:8080/ (for local testing)"
echo ""
echo "📝 Next steps:"
echo "1. Rebuild your Android app"
echo "2. Create a release build to use the Cloud Run URL"
echo "3. Or modify the debug URL if needed for testing"
