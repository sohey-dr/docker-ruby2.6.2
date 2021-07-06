FROM ruby:2.6.2

ENV RUNTIME_PACKAGES="linux-headers libxml2-dev make gcc libc-dev nodejs tzdata postgresql-dev postgresql" \
    DEV_PACKAGES="build-base curl-dev" \
    HOME="/app" \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo
RUN apt-get update && \
    apt-get upgrade && \
    apt-get --update --no-cache ${RUNTIME_PACKAGES} && \
    apt-get --update --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
    apt-get curl && \
    apt-get remove build-dependencies
# headless chrome install
RUN apt-get --update \
            udev \
            ttf-freefont \
            chromium \
            chromium-chromedriver
# font install for chrome
RUN mkdir /noto
ADD https://noto-website.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip /noto
WORKDIR /noto
RUN unzip NotoSansCJKjp-hinted.zip && \
    mkdir -p /usr/share/fonts/noto && \
    cp *.otf /usr/share/fonts/noto && \
    chmod 644 -R /usr/share/fonts/noto/ && \
    fc-cache -fv
WORKDIR /
RUN rm -rf /noto
