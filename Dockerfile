FROM foltia:6.1.14

# install jq
RUN yum install -y jq

# install nodejs for rivarun
RUN rpm -Uvh https://rpm.nodesource.com/pub_8.x/el/6/x86_64/nodejs-8.9.4-1nodesource.x86_64.rpm

# install rivarun
RUN npm install rivarun -g
RUN ln -sf /usr/bin/rivarun /home/foltia/perl/tool/rivarun

# disable shutdown script
RUN ln -sf /bin/true /home/foltia/perl/tool/shutdown

# disable pam_loginuid.so for atd, crond
RUN sed -i '/pam_loginuid/s/^/#/g' /etc/pam.d/atd
RUN sed -i '/pam_loginuid/s/^/#/g' /etc/pam.d/crond

# disable oom_adj for postgresql
RUN sed -i '/oom_adj/s/^/#/g' /etc/init.d/rh-postgresql95-postgresql

# output syslog to docker log
RUN echo "*.info;mail.none;authpriv.none;cron.none /proc/1/fd/1" >> /etc/rsyslog.conf

# foltia firmware update (6.1.15, 6.1.16)
COPY updater/foltia_ANIME_LOCKER_6115_updater.tar.gz /home/foltia/firmware/
COPY updater/foltia_ANIME_LOCKER_6116_updater.tar.gz /home/foltia/firmware/

RUN /etc/init.d/rh-postgresql95-postgresql start; cd /home/foltia/firmware/; sudo -u foltia tar xvzf foltia_ANIME_LOCKER_6115_updater.tar.gz; sudo -u foltia /home/foltia/firmware/update/update.sh; /etc/init.d/rh-postgresql95-postgresql stop
RUN rm -rf /home/foltia/firmware/update
RUN sed -i '/shutdown/s/^/#/g' /etc/rc.local
RUN /etc/init.d/rh-postgresql95-postgresql start; /etc/rc.local; /etc/init.d/rh-postgresql95-postgresql stop

RUN /etc/init.d/rh-postgresql95-postgresql start; cd /home/foltia/firmware/; sudo -u foltia tar xvzf foltia_ANIME_LOCKER_6116_updater.tar.gz; sudo -u foltia /home/foltia/firmware/update/update.sh; /etc/init.d/rh-postgresql95-postgresql stop
RUN rm -rf /home/foltia/firmware/update
RUN sed -i '/shutdown/s/^/#/g' /etc/rc.local
RUN /etc/init.d/rh-postgresql95-postgresql start; /etc/rc.local; /etc/init.d/rh-postgresql95-postgresql stop

# copy PostgreSQL DB, crontab, atq (for persistent volume copy)
RUN cp -a /var/opt/rh/rh-postgresql95/lib/pgsql/data /var/opt/rh/rh-postgresql95/lib/pgsql/data.orig
RUN cp -a /var/spool/at /var/spool/at.orig
RUN cp -a /var/spool/cron /var/spool/cron.orig

# disable local console setting.
RUN sed -i '/setterm/s/^/#/g' /etc/rc.local

# mirakurun patch
COPY patch/foltia-mirakurun-6.1.16.patch /home/foltia/
RUN cd /home/foltia/; patch -p1 < foltia-mirakurun-6.1.16.patch

# setup entrypoint
COPY foltia-start.sh /
ENTRYPOINT ["/foltia-start.sh"]

EXPOSE 80 
