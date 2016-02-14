# OPENVAS
#
# VERSION 0.1
#

FROM ubuntu
MAINTAINER nicoloko <dev@nicoloko.com>

ENV DEBIAN_FRONTEND noninteractive

# Use of specific mirror
ADD sources.list /etc/apt/sources.list
# Use of apt-cacher to save bandwidth
RUN echo "Acquire::http::Proxy \"http://172.17.42.1:3142\";" >> /etc/apt/apt.conf
# Do full up & clean etc...
RUN apt-get update && apt-get upgrade -y -q && apt-get dist-upgrade -y -q && apt-get -y -q autoclean && apt-get -y -q autoremove

