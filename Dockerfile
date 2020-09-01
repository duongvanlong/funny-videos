FROM rails:latest
WORKDIR /funnyvideos
RUN echo 'alias ll="ls --color=auto -alF"' >> ~/.bashrc
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install
