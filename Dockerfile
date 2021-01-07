FROM ruby:2.7.2 AS development

LABEL maintainer="nadircs11@gmail.co.il"

RUN dpkg --add-architecture i386

SHELL [ "/bin/bash", "-c" ]

RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt update -yqq && \
  apt install --no-install-recommends -yqq nodejs yarn npm nano apt-utils locales && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

RUN gem install bundler
RUN bundle config --global jobs 8

RUN mkdir -pv /app
WORKDIR /app

RUN mkdir -pv ./lib/serviceworker/rails/
COPY *.gemspec ./
COPY Gemfile* ./
COPY lib/serviceworker/rails/version.rb ./lib/serviceworker/rails/
RUN bundle install

COPY Appraisals ./
COPY gemfiles ./gemfiles
RUN bundle exec appraisal bundle install

RUN mkdir -pv ./test/sample
COPY ./test/sample/. ./test/sample/
WORKDIR /app/test/sample
RUN yarn install --frozen-lockfile

WORKDIR /app

COPY . .

ENTRYPOINT ["/bin/bash", "-c", "/bin/bash"]

FROM development AS testing

RUN bundle exec appraisal rake test || exit 0

ENTRYPOINT ["/bin/bash", "-c", "/bin/bash"]
