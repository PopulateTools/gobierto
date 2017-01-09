FROM gobierto_web
MAINTAINER Populate <lets@populate.tools>

ENV PHANTOMJS_VERSION=2.1.1

RUN mkdir -p /opt/bin
RUN curl --output /opt/bin/phantomjs https://s3.amazonaws.com/circle-downloads/phantomjs-$PHANTOMJS_VERSION
RUN chmod a+x /opt/bin/phantomjs
RUN ln -s --force /opt/bin/phantomjs /usr/bin/phantomjs
