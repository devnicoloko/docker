# MISP
#
# VERSION 2.4
#

FROM nicoloko/ubuntu:latest
MAINTAINER Nicoloko

# installation de Postfix etc ...
RUN echo "postfix postfix/main_mailer_type string Local only" | debconf-set-selections 
RUN echo "postfix postfix/mailname string localhost.localdomain" | debconf-set-selections
RUN \ 
  apt-get install -y apache2 php5 libapache2-mod-php5 php5-mysql gcc zip php-pear git redis-server make python-dev python-pip libxml2-dev libxslt1-dev zlib1g-dev php5-dev libapache2-mod-php5 curl gcc zip php-pear git redis-server make python-dev python-pip libxml2-dev libxslt1-dev zlib1g-dev php5-dev libapache2-mod-php5 curl python-dev python-pip libxml2-dev libxslt-dev zlib1g-dev openssl supervisor && \
  apt-get clean

RUN pear install Crypt_GPG && \ 
  pear install Net_GeoIP

# 3/ MISP code
RUN \
  cd /var/www && \
  git clone https://github.com/MISP/MISP.git && \
  cd /var/www/MISP && \
  git config core.filemode false && \
  cd /var/www/MISP/app/files/scripts && \
  git clone https://github.com/CybOXProject/python-cybox.git && \
  git clone https://github.com/STIXProject/python-stix.git && \
  cd /var/www/MISP/app/files/scripts/python-cybox && \
  git checkout v2.1.0.10 && \
  python setup.py install && \
  cd /var/www/MISP/app/files/scripts/python-stix && \
  git checkout v1.1.1.4 && \
  python setup.py install

ADD UsersController.php /var/www/MISP/app/Controller/UsersController.php

# 4/ CakePHP
RUN \
  cd /var/www/MISP && \
  git submodule init && \
  git submodule update && \
  cd /var/www/MISP/app && \
  curl -s https://getcomposer.org/installer | php && \
  php composer.phar require kamisama/cake-resque:4.1.2 && \
  php composer.phar config vendor-dir Vendor && \
  php composer.phar install &&\
  pecl install redis && \
  apt-get install php5-redis && \
  echo "extension=redis.so" >> /etc/php5/apache2/php.ini &&\
  cp -fa /var/www/MISP/INSTALL/setup/config.php /var/www/MISP/app/Plugin/CakeResque/Config/config.php

# 5/ Set the permissions
RUN \
  chown -R www-data:www-data /var/www/MISP && \
  chmod -R 750 /var/www/MISP && \
  chmod -R g+ws /var/www/MISP/app/tmp && \
  chmod -R g+ws /var/www/MISP/app/files && \
  chmod -R g+ws /var/www/MISP/app/files/scripts/tmp && \
  chmod -R 750 /var/www/MISP && \
  chmod -R g+ws /var/www/MISP/app/tmp && \
  chmod -R g+ws /var/www/MISP/app/files && \
  chmod -R g+ws /var/www/MISP/app/files/scripts/tmp

# 6/ Create a database and user
#
# WILL BE DONE in compose
#

# 7/ Apache configuration
RUN cp /var/www/MISP/INSTALL/apache.misp.ubuntu /etc/apache2/sites-available/misp.conf && \
  a2ensite misp && \
  a2dissite 000-default && \
  a2enmod rewrite

# 8/ MISP configuration
RUN cd /var/www/MISP/app/Config && \
  cp -a bootstrap.default.php bootstrap.php && \
  echo "\nCakePlugin::loadAll(array( \n 'CakeResque' => array('bootstrap' => true) \n ));" >> bootstrap.php && \
  cp -a database.default.php database.php && \
  cp -a core.default.php core.php && \
  cp -a config.default.php config.php && \
  echo "\nrequire_once dirname(__DIR__) . '/Vendor/autoload.php';" >> core.php && \
  sed -i "s/Rooraenietu8Eeyo<Qu2eeNfterd-dd+/`openssl rand -base64 32 | tr -d /=+ | cut -c -30`/" config.php && \
  chown -R www-data:www-data /var/www/MISP/app/Config && \
  chmod -R 750 /var/www/MISP/app/Config

ADD .gnupg /var/www/MISP/.gnupg
RUN \
  chown -R www-data:www-data /var/www/MISP/.gnupg && \
  chmod 700 /var/www/MISP/.gnupg && \
  chmod 0600 /var/www/MISP/.gnupg/*

# Configure supervisord
RUN \
  echo '' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo "[supervisord]" > /etc/supervisor/conf.d/supervisord.conf && \
  echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf && \
  echo '[program:postfix]' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo 'process_name = master' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo 'directory = /etc/postfix' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo 'command = /usr/sbin/postfix -c /etc/postfix start' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo 'startsecs = 0' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo 'autorestart = false' >> /etc/supervisor/conf.d/supervisord.conf

RUN \
  echo '' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo '[program:redis-server]' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo 'command=redis-server /etc/redis/redis.conf' >> /etc/supervisor/conf.d/supervisord.conf

RUN \
  echo '' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo '[program:apache2]' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo 'command=/bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -D FOREGROUND"' >> /etc/supervisor/conf.d/supervisord.conf

RUN \
  echo '' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo '[program:resque]' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo 'command=/bin/bash /var/www/MISP/app/Console/worker/start.sh' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo 'user=www-data' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo 'startsecs = 0' >> /etc/supervisor/conf.d/supervisord.conf && \
  echo 'autorestart = false' >> /etc/supervisor/conf.d/supervisord.conf

ADD run.sh /run.sh
ADD patch.sql /tmp/patch.sql

RUN apt-get install -y mysql-client

EXPOSE 80 
CMD /run.sh
