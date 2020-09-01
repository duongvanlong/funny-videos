FROM ruby:2.5
WORKDIR /funnyvideos
RUN echo 'alias ll="ls --color=auto -alF"' >> ~/.bashrc
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN gem install rails
RUN bundle install
