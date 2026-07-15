FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    bash \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/microsoft/waza/releases/download/v0.38.0/waza-linux-amd64 \
    -o /tmp/waza \
    && echo "9d274f563e0f05b50d56f0223c03bdc561180ffea13662583188ecc042a9fe15  /tmp/waza" | sha256sum -c - \
    && install -m 755 /tmp/waza /usr/local/bin/waza \
    && rm -f /tmp/waza
