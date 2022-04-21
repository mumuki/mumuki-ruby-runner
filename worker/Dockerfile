FROM ruby:2.6-alpine
MAINTAINER Franco Leonardo Bulgarelli
RUN gem install rspec --version '=3.5'

RUN adduser mumuki --home /home/mumuki -D
RUN chmod o-x -R /bin/
RUN chmod o-x -R /sbin/
RUN chmod o-x -R /usr/bin/
RUN chmod o-x -R /usr/sbin/

RUN chmod o-x /usr/local/bin/*
RUN chmod o+x /usr/local/bin/ruby

WORKDIR /home/mumuki/
USER mumuki