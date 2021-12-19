FROM ruby:3.0.2-alpine

ENV APP_HOME /app

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN gem install bundler -v '2.2.22' \
    && bundle install

CMD ["bundle", "exec", "ruby", "--version"]
