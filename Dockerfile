FROM ruby:alpine

ENV BUILD_PACKAGES="curl-dev ruby-dev build-base bash git" \
    DEV_PACKAGES="libgcrypt-dev zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev postgresql-dev" \
    RUBY_PACKAGES="ruby-json yaml nodejs" \
    RAILS_ENV="development"

RUN adduser -h /var/www/app -D rails
RUN mkdir -p /var/www/app/ && chown rails:rails /var/www/app/

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --virtual build-dependencies --update\
    $BUILD_PACKAGES \
    $DEV_PACKAGES \
    $RUBY_PACKAGES

USER rails

COPY Gemfile /var/www/app/
COPY Gemfile.lock /var/www/app/

WORKDIR /var/www/app/

RUN echo 'gem: --no-document' >> .gemrc && \
    bundle config --global frozen 1 && \
    bundle config build.nokogiri \
           --use-system-libraries && \
    bundle install --clean -j4

ONBUILD COPY . /var/www/app/
ONBUILD USER root
ONBUILD RUN  chown -R rails:rails /var/www/app/
ONBUILD USER rails

EXPOSE 5000
CMD ([ -f "/var/www/app/tmp/pids/server.pid" ] && \
    (rm -f /var/www/app/tmp/pids/server.pid && echo "START Rails") || \
    echo "START Rails" ) && \
    foreman start -f Procfile.$RAILS_ENV
