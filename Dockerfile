FROM --platform=linux/arm/v7 ubuntu:16.04

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
    && gem install bundler -v \
    && bundle -v
