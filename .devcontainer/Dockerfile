FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y -qq \
    ca-certificates \
    curl \
    jq \
    git \
    nodejs \
    npm \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Pin bats-core to match CI (see .github/scripts/test/install-bats.sh)
RUN npm install -g bats@1.11.1
