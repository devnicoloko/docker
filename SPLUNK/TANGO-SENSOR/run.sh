#!/bin/bash

# START COWRIE
cd /opt/splunkforwarder/etc/apps/tango_input/default 
sed -i "s/test/${SENSOR_NAME}/" inputs.conf 
sed -i "s/test/${SPLUNK_SRV}\:9997/" outputs.conf 

chmod 755 /opt/cowrie/log/cowrie.json

# START SPLUNK FORWARDER
sudo -u splunk /opt/splunkforwarder/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt

cd /
exec /usr/bin/supervisord
