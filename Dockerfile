FROM ruby:2.3.3

ENV INSTALL_PATH /usr/src/app/
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH
COPY . $INSTALL_PATH

RUN bundle install

CMD ["whenever", "-w"]
