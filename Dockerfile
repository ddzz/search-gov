FROM ruby:3.0.6

RUN apt-get update -y && apt-get install -y --no-install-recommends \
  default-jre \
  default-mysql-client \
  imagemagick \
  libprotobuf-dev \
  protobuf-compiler \
  nodejs yarn
# Workaround for PhantomJS: https://github.com/DMOJ/online-judge/pull/1270
ENV OPENSSL_CONF /etc/ssl/
RUN gem install rails

COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app

ENV BUNDLE_PATH /gems

RUN bundle install

ENV NODE_VERSION=16.13.0
RUN apt install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN npm install -g yarn
RUN yarn install

COPY . /usr/src/app/

EXPOSE 3000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]
