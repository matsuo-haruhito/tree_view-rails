FROM ruby:3.2.3-slim

ARG NODE_MAJOR=22

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  gnupg \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
  && apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  git \
  nodejs \
  pkg-config \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

CMD ["bash"]
