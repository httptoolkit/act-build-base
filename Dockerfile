FROM node:12.6-buster-slim

# Hack to make it possible to use setup-python
# See https://github.com/nektos/act/issues/251
RUN echo "DISTRIB_RELEASE=18.04" > /etc/lsb-release

ENV ACT_ENV_COMMIT=940bf53b
ENV METADATA_FILE=/dev/null

# Install standard Act helpers
RUN mkdir /tmp/helpers/
ADD https://raw.githubusercontent.com/nektos/act-environments/$ACT_ENV_COMMIT/images/linux/scripts/helpers/apt.sh /tmp/helpers/apt.sh
ADD https://raw.githubusercontent.com/nektos/act-environments/$ACT_ENV_COMMIT/images/linux/scripts/helpers/document.sh /tmp/helpers/document.sh
ENV HELPER_SCRIPTS /tmp/helpers

# Install basic prerequisites
RUN apt-get update && apt-get -y install sudo lsb-release unzip xvfb libxss1

# --- Manually run just the installers we need, rather than using the full 18GB base image: ---

# Native build essentials
RUN sh -c "curl -s https://raw.githubusercontent.com/nektos/act-environments/$ACT_ENV_COMMIT/images/linux/scripts/installers/build-essential.sh | bash"

# Google-chrome & ChromeDriver
RUN sh -c "curl -s https://raw.githubusercontent.com/nektos/act-environments/$ACT_ENV_COMMIT/images/linux/scripts/installers/google-chrome.sh | bash"

# Firefox (for some reason the standard scripts don't work - they use 'firefox', with no ESR).
RUN apt-get -y install firefox-esr