FROM ruby:2.6.2-alpine

ENV RUNTIME_PACKAGES="linux-headers libxml2-dev make gcc libc-dev tzdata mysql-client mariadb-dev" \
    DEV_PACKAGES="build-base curl-dev" \
    HOME="/app" \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo
RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache ${RUNTIME_PACKAGES} && \
    apk add --update --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
    apk add curl && \
    apk del build-dependencies

# install yarn nodejs
RUN apk add bash curl nodejs
RUN touch ~/.bashrc \
    && curl -o- -L https://yarnpkg.com/install.sh | bash \
    && ln -s "$HOME/.yarn/bin/yarn" /usr/local/bin/yarn

# headless chrome install
RUN apk add --update \
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
