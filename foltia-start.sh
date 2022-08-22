#!/bin/bash

sigterm_handler(){
  /etc/init.d/rh-postgresql95-postgresql stop
  /etc/init.d/atd stop
  /etc/init.d/crond stop
  /etc/init.d/httpd stop
  /etc/init.d/smb stop
  /ect/init.d/nmb stop
  /etc/init.d/minidlna stop
  /etc/init.d/shellinabox stop
  /etc/init.d/rsyslog stop
}

if [ -e /var/opt/rh/rh-postgresql95/lib/pgsql/data/postgresql.conf ]; then
  echo "PostgreSQL settings found. Skip setupwizerd."
  rm -f /home/foltia/php/index.php
else
  echo "No PostgreSQL settings found, copying template to persistent volume."
  cp -a /var/opt/rh/rh-postgresql95/lib/pgsql/data.orig/* /var/opt/rh/rh-postgresql95/lib/pgsql/data/
  chown postgres:postgres /var/opt/rh/rh-postgresql95/lib/pgsql/data
  chmod 700 /var/opt/rh/rh-postgresql95/lib/pgsql/data
fi

if [ ! -d /home/foltia/php/tv/live ]; then
  echo "Create /home/foltia/php/tv persistent volume."
  mkdir /home/foltia/php/tv/live
  mkdir /home/foltia/php/tv/mita
  chown -R foltia:foltia  /home/foltia/php/tv
  chmod -R 755 /home/foltia/php/tv
fi

# start services
/etc/init.d/rsyslog start
/etc/init.d/rh-postgresql95-postgresql start
/etc/init.d/atd start
/etc/init.d/crond start
/etc/init.d/wine start
/etc/init.d/httpd start

sleep 10

# update Mirakurun host
if [ -n "${MIRAKURUN}" ]; then
  echo "Set Mirakurun host: ${MIRAKURUN}"
  source scl_source enable rh-postgresql95
  psql -U foltia foltia -c "INSERT INTO foltia_config VALUES ('mirakurun', '${MIRAKURUN}');"
fi

# option services
if [ "${ENABLE_PHPPGADMIN}" = "true" ]; then
  echo "phpPgAdmin enabled."
else
  rm -rf /home/foltia/php/phppgadmin
fi

if [ ${ENABLE_SHELLINABOX} -eq 1 ]; then
  /etc/init.d/shellinaboxd start
fi

if [ "${ENABLE_MINIDLNA}" -eq 1 ]; then
  /etc/init.d/minidlna start
fi

if [ "${ENABLE_SAMBA}" -eq 1 ]; then
  /etc/init.d/smb start
  /etc/init.d/nmb start
fi

/etc/rc.local

trap sigterm_handler SIGTERM

while :; do sleep 10; done
