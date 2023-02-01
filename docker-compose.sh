#!/bin/bash

# Based on https://github.com/nektos/act-environments/blob/940bf53/images/linux/scripts/installers/docker-compose.sh

DOCKER_COMPOSE_VERSION="v2.15.1"

# Install latest docker-compose from releases
curl --fail -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
if ! command -v docker-compose; then
    echo "docker-compose was not installed"
    exit 1
fi