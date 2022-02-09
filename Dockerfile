FROM buildpack-deps:18.04

ENV ACT_ENV_COMMIT=940bf53b
ENV METADATA_FILE=/dev/null
ENV DEBIAN_FRONTEND=noninteractive

# Install standard Act helpers
RUN mkdir /tmp/helpers/
ADD https://raw.githubusercontent.com/nektos/act-environments/$ACT_ENV_COMMIT/images/linux/scripts/helpers/document.sh /tmp/helpers/document.sh
ADD https://raw.githubusercontent.com/nektos/act-environments/$ACT_ENV_COMMIT/images/linux/scripts/helpers/apt.sh /tmp/helpers/apt.sh
ENV HELPER_SCRIPTS /tmp/helpers

# Install basic prerequisites
RUN apt-get update && apt-get -y install sudo lsb-release unzip xvfb libxss1 git software-properties-common

# --- Manually run just the installers we need, rather than using the full 18GB base image: ---

# Install new Git - without this the outdated version causes problems with GH
RUN sh -c "curl -s https://raw.githubusercontent.com/nektos/act-environments/$ACT_ENV_COMMIT/images/linux/scripts/installers/git.sh | bash"

# Native build essentials
RUN sh -c "curl -s https://raw.githubusercontent.com/nektos/act-environments/$ACT_ENV_COMMIT/images/linux/scripts/installers/build-essential.sh | bash"

# Node.js
RUN sh -c "curl -s https://raw.githubusercontent.com/nektos/act-environments/$ACT_ENV_COMMIT/images/linux/scripts/installers/nodejs.sh | bash"

# Python, required for node-gyp builds
RUN sh -c "curl -s https://raw.githubusercontent.com/nektos/act-environments/$ACT_ENV_COMMIT/images/linux/scripts/installers/python.sh | bash"

# Google-chrome & ChromeDriver
RUN sh -c "curl -s https://raw.githubusercontent.com/nektos/act-environments/$ACT_ENV_COMMIT/images/linux/scripts/installers/google-chrome.sh | bash"

# Docker & docker-compose. Installed manually, because script tests with 'docker info', and docker doesn't work in the build (needs --privileged)
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - &&\
    curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/microsoft-prod.list &&\
    apt-get update &&\
    apt-get install -y moby-engine moby-cli
RUN sh -c "curl -s https://raw.githubusercontent.com/nektos/act-environments/$ACT_ENV_COMMIT/images/linux/scripts/installers/docker-compose.sh | bash"

# Required for AUFS images on DIND
VOLUME /var/lib/docker

# Firefox (standard scripts don't work due to geckodriver release changes, doesn't matter - we don't use it)
RUN apt-get -y install firefox

# Clean up apt cache etc for a smaller final image
RUN apt-get clean autoclean && apt-get autoremove --yes && rm -rf /var/lib/apt/lists/*

# It seems that in GHA non-run steps always run as the default USER, while run steps always use UID 1001. We make the 1001 user the default
# here, so that everything runs as the same user, and we avoid permissions conflicts later on.
RUN adduser --system build-user --shell /bin/bash --group --uid 1001 && \
    usermod -aG sudo build-user && \
    echo 'Defaults !authenticate' >> /etc/sudoers && \
    usermod -aG docker build-user

USER build-user