FROM ruby:3.0.6-alpine3.16

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
    sudo

ARG uid
ARG gid

# add user
RUN addgroup -g $gid docker && \
    adduser -S -u $uid -G docker docker && \
    echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo 'docker:docker' | chpasswd

USER docker
