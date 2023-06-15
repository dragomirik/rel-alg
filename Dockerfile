FROM ruby:3.0

WORKDIR /rel-alg
COPY Gemfile Gemfile.lock .
RUN bundle install

COPY . .

CMD ruby main.rb
