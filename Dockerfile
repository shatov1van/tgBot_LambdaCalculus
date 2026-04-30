FROM ruby:3.4

RUN apt-get update -qq && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

CMD ["bundle", "exec", "ruby", "bot.rb"]