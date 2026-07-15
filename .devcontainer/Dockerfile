FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    bash \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/microsoft/waza/releases/download/v0.38.0/waza-linux-amd64 \
    -o /usr/local/bin/waza && chmod +x /usr/local/bin/waza
