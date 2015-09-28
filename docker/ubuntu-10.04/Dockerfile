FROM ubuntu:10.04

MAINTAINER Mathieu Sauve-Frankel <msf@kisoku.net>

ENV DEBIAN_FRONTEND noninteractive

RUN && apt-get update -qq && apt-get upgrade -y \
    && apt-get install -y python-software-properties \
    && add-apt-repository ppa:git-core \
    && apt-get install -y \
          apt-transport-https \
          bash \
          curl \
          git-core \
          sudo \
          autoconf \
          bison \
          build-essential \
	  lsb-release \
	  libffi-dev \
          libssl-dev \
          libyaml-dev \
          libreadline6 \
          libreadline6-dev \
          zlib1g \
          zlib1g-dev

RUN git clone https://github.com/sstephenson/rbenv /usr/local/rbenv \
    && git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build \
    && git clone https://github.com/sstephenson/rbenv-gem-rehash.git /usr/local/rbenv/plugins/rbenv-gem-rehash \
    && echo '# rbenv setup' > /etc/profile.d/rbenv.sh \
    && echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh \
    && echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh \
    && echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh \
    && chmod +x /etc/profile.d/rbenv.sh \
    && bash -lc 'rbenv install -v 2.1.7 && rbenv global 2.1.7' \
    && ln -s /usr/local/rbenv/versions/2.1.7/bin/ruby /usr/bin/ruby

RUN bash -lc 'gem install --no-rdoc --no-ri --verbose bundler' \
    && ln -s /usr/local/rbenv/versions/2.1.7/bin/bundle /usr/bin/bundle \
    && bash -lc 'gem install --no-rdoc --no-ri --verbose fpm-cookery' \
    && bash -lc 'gem install --no-rdoc --no-ri --verbose mixlib-shellout' \
    && ln -s /usr/local/rbenv/versions/2.1.7/bin/fpm-cook /usr/bin/fpm-cook

VOLUME /helpers
VOLUME /build
VOLUME /repo

CMD '/helpers/cook'
