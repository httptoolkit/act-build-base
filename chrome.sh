#!/bin/bash

# Based on https://github.com/nektos/act-environments/blob/cc63076/images/linux/scripts/installers/google-chrome.sh and
# https://github.com/actions/runner-images/blob/845c5ee8/images/ubuntu/scripts/build/install-google-chrome.sh

wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
apt-get update
apt-get install -y google-chrome-stable
echo "CHROME_BIN=/usr/bin/google-chrome" | tee -a /etc/environment

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
if ! command -v google-chrome; then
    echo "google-chrome was not installed"
    exit 1
fi

FULL_CHROME_VERSION=$(google-chrome --product-version)
CHROME_VERSION=${FULL_CHROME_VERSION%.*}

echo "Installed Chrome version is $CHROME_VERSION"

# Determine latest release of chromedriver
# Compatibility of Google Chrome and Chromedriver: https://developer.chrome.com/docs/chromedriver/downloads/version-selection
CHROME_PLATFORM="linux64"
CHROME_VERSIONS_URL="https://googlechromelabs.github.io/chrome-for-testing/latest-patch-versions-per-build-with-downloads.json"
CHROME_VERSIONS_JSON=$(curl -fsSL "${CHROME_VERSIONS_URL}")

CHROMEDRIVER_VERSION=$(echo "${CHROME_VERSIONS_JSON}" | jq -r '.builds["'"$CHROME_VERSION"'"].version')
CHROMEDRIVER_URL=$(echo "${CHROME_VERSIONS_JSON}" | jq -r '.builds["'"$CHROME_VERSION"'"].downloads.chromedriver[] | select(.platform=="'"${CHROME_PLATFORM}"'").url')

# Download and unpack latest release of chromedriver
echo "Downloading chromedriver v$CHROMEDRIVER_VERSION..."
wget "$CHROMEDRIVER_URL"
unzip chromedriver-linux64.zip
rm chromedriver-linux64.zip

CHROMEDRIVER_DIR="/usr/local/share/chrome-driver"
CHROMEDRIVER_BIN="$CHROMEDRIVER_DIR/chromedriver"

mkdir -p $CHROMEDRIVER_DIR
mv "chromedriver-linux64/chromedriver" $CHROMEDRIVER_BIN
chmod +x $CHROMEDRIVER_BIN
ln -s "$CHROMEDRIVER_BIN" /usr/bin/
echo "CHROMEWEBDRIVER=$CHROMEDRIVER_DIR" | tee -a /etc/environment

# Run tests to determine that the chromedriver installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
if ! command -v chromedriver; then
    echo "chromedriver was not installed"
    exit 1
fi