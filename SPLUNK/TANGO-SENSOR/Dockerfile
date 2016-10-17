# TANGO SENSOR
#
# VERSION 0.5
#

FROM nicoloko/ubuntu:14.04
MAINTAINER Nicoloko <dev@nicoloko.com>

ENV SENSOR_NAME sensor1
ENV SPLUNK_SRV splunk

RUN \ 
  apt-get install -y git wget python-dev python-openssl python-pyasn1 authbind git libcurl4-gnutls-dev libssl-dev python-twisted python-configparser python-crypto python-pyasn1 python-gmpy2 python-mysqldb python-zope.interface && \
  apt-get clean

RUN  \
  wget -O /tmp/splunkforwarder-6.5.0-59c8927def0f-linux-2.6-amd64.deb https://download.splunk.com/products/universalforwarder/releases/6.5.0/linux/splunkforwarder-6.5.0-59c8927def0f-linux-2.6-amd64.deb && \
  wget -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && \
  python /tmp/get-pip.py && \
  pip install pycrypto service_identity requests ipwhois twisted

RUN \
  groupadd -r splunk && \
  useradd -g splunk splunk -d /home/splunk -s /bin/false && \
  mkdir /home/splunk && \
  chown -R splunk:splunk /home/splunk && \
  dpkg -i /tmp/splunkforwarder-6.5.0-59c8927def0f-linux-2.6-amd64.deb

# Install cowrie
RUN \
  cd /opt && \
  git clone https://github.com/micheloosterhof/cowrie.git && \
  cd cowrie && \
  cp cowrie.cfg.dist cowrie.cfg  && \
  groupadd -r cowrie && \
  useradd -g cowrie cowrie -d /opt/cowrie -s /bin/false && \
  cd data && \
  ssh-keygen -t dsa -b 1024 -f ssh_host_dsa_key && \
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
