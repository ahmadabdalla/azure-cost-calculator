FROM ubuntu:latest

# Prevent interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y -qq \
    curl \
    jq \
    git \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Pin bats-core to match CI (see .github/scripts/test/install-bats.sh)
RUN npm install -g bats@1.11.1

# Configure git so commands inside the container don't error
RUN git config --global user.email "testbed@local" && \
    git config --global user.name "Testbed"

WORKDIR /repo
