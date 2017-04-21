FROM ruby:2.4.0

ENV SEMESTER 201701

ENV INSTALL_PATH /usr/src/app/
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH
COPY . $INSTALL_PATH

# RUN apt-get install ruby-dev build-base openssl openssl-dev ca-certificates 

RUN bundle install

CMD ["ruby", "app.rb"]
