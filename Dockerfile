FROM catthehacker/ubuntu:act-22.04

ENV DEBIAN_FRONTEND=noninteractive

COPY firefox-no-snap /etc/apt/preferences.d/firefox-no-snap

# Install basic prerequisites
RUN add-apt-repository -y ppa:mozillateam/ppa && \
    apt-get update && \
    apt-get -y install xvfb libxss1 build-essential firefox

# Google-chrome & ChromeDriver
COPY ./chrome.sh .
RUN bash ./chrome.sh

# Docker-compose
COPY ./docker-compose.sh .
RUN bash ./docker-compose.sh

# Required for AUFS images on DIND
VOLUME /var/lib/docker

# Clean up apt cache etc for a smaller final image (assuming squashing)
RUN apt-get clean autoclean && apt-get autoremove --yes && rm -rf /var/lib/apt/lists/*

# Fix annoying Yarn issue: https://github.com/yarnpkg/yarn/issues/7866
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -

# It seems that in GHA non-run steps always run as the default USER, while run steps always use UID 1001. We make the 1001 user the default
# here, so that everything runs as the same user, and we avoid permissions conflicts later on.
RUN adduser --system build-user --shell /bin/bash --group --uid 1001 && \
    usermod -aG sudo build-user && \
    echo 'Defaults !authenticate' >> /etc/sudoers && \
    usermod -aG docker build-user

USER build-user