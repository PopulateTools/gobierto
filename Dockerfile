FROM ruby:2.4.1
MAINTAINER Populate <lets@populate.tools>

RUN apt-get update && apt-get install -y -q nodejs

WORKDIR /app
