#!/bin/sh
# Runs the package's tests on an iOS simulator. Pass a device name to pick a
# different simulator; the default is the first available iPhone.
set -eu
cd "$(dirname "$0")/.."

device="${1:-$(xcrun simctl list devices available | grep -m1 -o 'iPhone [^(]*' | sed 's/ *$//')}"
if [ -z "$device" ]; then
    echo "No available iPhone simulator. Install one in Xcode > Settings > Components." >&2
    exit 1
fi

exec xcodebuild test \
    -scheme SwiftLanguageGuideExtended \
    -destination "platform=iOS Simulator,name=$device" \
    -quiet
