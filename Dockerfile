FROM --platform=linux/arm64/v8 ubuntu:20.04

MAINTAINER sohey-dr

WORKDIR /tmp

# rubyとrailsのバージョンを指定
ENV ruby_ver="2.6.2" \
    LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    TZ="Asia/Tokyo"

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    build-essential \
    curl \
    git \
    ibus-mozc \
    imagemagick \
    language-pack-ja-base \
    language-pack-ja \
    libreadline-dev \
    libmysqlclient-dev \
    libssl-dev \
    mysql-client \
    tzdata \
    wget

# 日本語設定とタイムゾーン設定
RUN locale-gen ja_JP.UTF-8 \
    && echo export LANG=ja_JP.UTF-8 >> ~/.profile \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

# rubyとbundleをダウンロード & コマンドでrbenvが使えるように設定
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv \
    && git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build \
    && echo 'export RBENV_ROOT="/usr/local/rbenv"' >> /etc/profile.d/rbenv.sh \
    && echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh \
    && echo 'eval "$(rbenv init --no-rehash -)"' >> /etc/profile.d/rbenv.sh

ENV PATH="$RBENV_ROOT:/bin:/usr/local/rbenv/versions/${ruby_ver}/bin:$PATH"

# rubyとbundlerをインストール
RUN . /etc/profile.d/rbenv.sh \
    && rbenv install ${ruby_ver} \
    && rbenv global ${ruby_ver} \
    && rbenv rehash \
    && . /etc/profile.d/rbenv.sh \
    && gem update --system \
    && gem install bundler \
    && bundle -v

# chrome をインストール
RUN apt-get install -y libappindicator3-1 libappindicator1 libnss3 fonts-liberation libasound2 libxss1 lsb-release xdg-utils \
            && curl -L -o google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
            && dpkg -i google-chrome.deb \
            && sed -i 's|HERE/chrome\"|HERE/chrome\" --disable-setuid-sandbox|g' /opt/google/chrome/google-chrome \
            && rm google-chrome.deb

# yarnのインストール
RUN apt-get install -y nodejs npm  \
            && ln -s /usr/bin/nodejs /usr/bin/node \
            && npm cache clean \
            && npm install n -g \
            && n stable \
            && ln -sf /usr/local/bin/node /usr/bin/node \
            && node -v \
            && npm install -g yarn \
            && apt-get purge -y nodejs npm
