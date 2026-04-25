FROM ruby:3.2.3-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  git \
  pkg-config \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

CMD ["bash"]
