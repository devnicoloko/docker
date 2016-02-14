#!/bin/bash

set -e

# Set MYSQL_ROOT_PASSWORD
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "MYSQL_ROOT_PASSWORD is not set, use default value 'root'"
  MYSQL_ROOT_PASSWORD=misp
else
  echo "MYSQL_ROOT_PASSWORD is set to '$MYSQL_ROOT_PASSWORD'" 
fi

## Sleep until DB start complete
sleep 30

## 6/Create a database and user  

echo "Connecting to database ..."
ret=`echo 'SHOW DATABASES;' | mysql -u root --password="$MYSQL_ROOT_PASSWORD" -h db -P 3306 2>&1`

if [ $? -eq 0 ]; then
  echo "Connected to database successfully"
  found=0
  for db in $ret; do
    if [ "$db" == "misp" ]; then
      found=1
    fi    
  done
  if [ $found -eq 1 ]; then
    echo "Database misp found"
  else
    echo "Database misp not found, creating now one ..."
	sed -i "s/0X9uqJeiww7mJua1nx9SP1sqHqVl4Z/`tr -cd '[:alnum:]' < /dev/urandom | fold -w64 | head -n1`/" /var/www/MISP/app/Config/config.php
	cat > /tmp/create_misp_database.sql <<-EOSQL
		create database misp;
		grant usage on *.* to misp identified by 'misp';
		grant all privileges on misp.* to misp;
	EOSQL
    ret=`mysql -u root --password="$MYSQL_ROOT_PASSWORD" -h $MYSQL_PORT_3306_TCP_ADDR -P $MYSQL_PORT_3306_TCP_PORT 2>&1 < /tmp/create_misp_database.sql`
    if [ $? -eq 0 ]; then
      echo "Created database misp successfully"

      echo "Importing /var/www/MISP/INSTALL/MYSQL.sql"
      ret=`mysql -u misp --password="misp" misp -h $MYSQL_PORT_3306_TCP_ADDR -P $MYSQL_PORT_3306_TCP_PORT 2>&1 < /var/www/MISP/INSTALL/MYSQL.sql`
      if [ $? -eq 0 ]; then
        echo "Imported /var/www/MISP/INSTALL/MYSQL.sql successfully"

	echo "Appling patch"
	ret=`mysql -u misp --password="misp" misp -h $MYSQL_PORT_3306_TCP_ADDR -P $MYSQL_PORT_3306_TCP_PORT 2>&1 < /tmp/patch.sql`
	if [ $? -eq 0 ]; then
		echo "Pacth applied successfully"
	else
		echo "ERROR: PATCH /patch.sql failed:"
		echo $ret
	fi
      else
        echo "ERROR: Importing /var/www/MISP/INSTALL/MYSQL.sql failed:"
        echo $ret
      fi
    else
      echo "ERROR: Creating database misp failed:"
      echo $ret
    fi    
  fi
else
  echo "ERROR: Connecting to database failed:"
  echo $ret
fi

# 8/ MISP configuration
cd /var/www/MISP/app/Config
sed -i "s/localhost/db/" database.php
sed -i "s/db\ login/misp/" database.php
sed -i "s/8889/3306/" database.php
sed -i "s/db\ password/misp/" database.php
chown www-data: /var/www/MISP/app/Config/database.php

# Start supervisord 
cd /
exec /usr/bin/supervisord
