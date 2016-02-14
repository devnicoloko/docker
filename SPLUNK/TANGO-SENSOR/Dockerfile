# TANGO SENSOR
#
# VERSION 0.5
#

FROM nicoloko/ubuntu
MAINTAINER Nicoloko <dev@nicoloko.com>

ENV SENSOR_NAME sensor1
ENV SPLUNK_SRV 172.17.0.1

RUN \ 
  apt-get install -y git wget python-dev python-openssl python-pyasn1 authbind git libcurl4-gnutls-dev libssl-dev && \
  apt-get clean

RUN  \
  wget -O /tmp/splunkforwarder-6.3.2-aaff59bb082c-linux-2.6-amd64.deb http://download.splunk.com/products/splunk/releases/6.3.2/universalforwarder/linux/splunkforwarder-6.3.2-aaff59bb082c-linux-2.6-amd64.deb && \
  wget -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && \
  python /tmp/get-pip.py && \
  pip install pycrypto service_identity requests ipwhois twisted

RUN \
  groupadd -r splunk && \
  useradd -g splunk splunk -d /home/splunk -s /bin/false && \
  mkdir /home/splunk && \
  chown -R splunk:splunk /home/splunk && \
  dpkg -i /tmp/splunkforwarder-6.3.2-aaff59bb082c-linux-2.6-amd64.deb

# Install cowrie
RUN \
  cd /opt && \
  git clone https://github.com/micheloosterhof/cowrie.git && \
  cd cowrie && \
  cp cowrie.cfg.dist cowrie.cfg  && \
  groupadd -r cowrie && \
  useradd -g cowrie cowrie -d /opt/cowrie -s /bin/false && \
  chown -R cowrie:cowrie /opt/cowrie

# install TANGO
RUN \
  cd /tmp && \
  git clone https://github.com/aplura/Tango.git && \
  cd /tmp/Tango && \
  cp -r ./tango_input /opt/splunkforwarder/etc/apps

RUN \
  cd /opt/splunkforwarder/etc/apps/tango_input/default  && \
  chown -R splunk:splunk /opt/splunkforwarder  

RUN \
  apt-get install -y supervisor 

ADD supervisor.cowrie.conf /etc/supervisor/conf.d/cowrie.conf

EXPOSE 2222

ADD run.sh /run.sh
RUN chmod 755 /run.sh

CMD ["/run.sh"]
