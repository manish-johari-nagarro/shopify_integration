FROM rlister/ruby:2.1.2

MAINTAINER Gin Lane Media "devops@ginlanemedia.com" 

## set the locale so gems built for utf8
ENV LC_ALL C.UTF-8

## help docker cache bundle
WORKDIR /tmp

ADD ./Gemfile /tmp/
ADD ./Gemfile.lock /tmp/
ADD . /app

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential zlib1g-dev libreadline6-dev libyaml-dev libssl-dev \
    git && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    gem install bundler --no-rdoc --no-ri && \
    /bin/bash -l -c "bundle install" && \
    rm -f /tmp/Gemfile /tmp/Gemfile.lock && \
    mkdir pids && \
    chmod +w pids && \
    mkdir log && \
    chmod +w log && \
    chmod +x config/container/start-server.sh

CMD ["config/container/start-server.sh"]