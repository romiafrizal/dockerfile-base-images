FROM ubuntu:22.04 AS base
ENV OS_LOCALE="en_US.UTF-8"
ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update 
RUN curl -sL https://deb.nodesource.com/setup_14.x  | bash -
RUN apt-get update && apt-get install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install yarn
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
ENV YARN_VERSION 1.22.19
ENV NODE_VERSION 14.19.2
EXPOSE 80 3000


