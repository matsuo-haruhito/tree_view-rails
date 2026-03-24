FROM ruby:3.2.3-alpine

RUN echo 'Set disable_coredump false' >> /etc/sudo.conf

RUN apk update && \
    apk add \
    # nokogiri
    build-base \
    # postgresql
    postgresql-dev \
    # image_processingに必要
    imagemagick \
    # others
    nodejs \
    yarn \
    tzdata \
    git \
    vim \
    bash \
    sudo \
    # system spec / screenshots
    chromium \
    chromium-chromedriver \
    font-noto-cjk \
    ttf-freefont

ARG uid
ARG gid

# add user
RUN addgroup -g $gid docker && \
    adduser -S -u $uid -G docker docker && \
    echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo 'docker:docker' | chpasswd

USER docker
