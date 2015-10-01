FROM ubuntu
MAINTAINER Shaun Keenan

WORKDIR /encode

ADD app.rb ./
ADD Gemfile* ./
ADD views ./

RUN apt-get -y update && \
    apt-get -y install bundler libav-tools ruby-sinatra && \
    mkdir media && \
    bundle install

EXPOSE 4567

VOLUME /encode/media

CMD cd /encode && bundle exec ruby app.rb
