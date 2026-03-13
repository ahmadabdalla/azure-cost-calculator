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

# Add a non-root user (UID/GID 1000 — matches the default Linux host user).
# Dev Containers remaps this to the host UID/GID automatically on Linux via
# updateRemoteUserUID, avoiding bind-mount permission issues.
RUN groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home vscode
