ARG BASE
FROM ${BASE}
MAINTAINER Rui Carmo https://github.com/rcarmo

# Update the system and set up Python 3
RUN apt-get update && apt-get dist-upgrade -y && apt-get install \
    apt-transport-https \
    curl \
    git \
    libavahi-compat-libdnssd-dev \
    wget \
    -y --force-yes  \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && pip --no-cache install virtualenv

RUN adduser --disabled-password --gecos "" -u 1001 user
USER user
VOLUME /home/user/.homeassistant
RUN virtualenv /home/user/.venv \
 && . /home/user/.venv/bin/activate \
 && pip --no-cache install --upgrade \
    aiohttp_cors \
    homeassistant \
    home-assistant-frontend \
    paho-mqtt \
    pyatv \
    sqlalchemy
EXPOSE 8123
ADD start.sh /start.sh
CMD /start.sh

ARG VCS_REF
ARG VCS_URL
ARG BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.build-date=$BUILD_DATE
