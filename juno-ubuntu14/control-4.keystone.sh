#!/bin/bash -ex
#
# Khoi tao bien
# TOKEN_PASS=a
# MYSQL_PASS=a
# ADMIN_PASS=a
source config.cfg

echo "##### Cai dat keystone #####"
apt-get install keystone -y

#/* Sao luu truoc khi sua file nova.conf
filekeystone=/etc/keystone/keystone.conf
test -f $filekeystone.orig || cp $filekeystone $filekeystone.orig

#Chen noi dung file /etc/keystone/keystone.conf
cat << EOF > $filekeystone
[DEFAULT]
admin_token = $TOKEN_PASS
log_dir = /var/log/keystone
[assignment]
[auth]
[cache]
[catalog]
[credential]
[database]
connection = mysql://keystone:$ADMIN_PASS@controller/keystone
[ec2]
[endpoint_filter]
[federation]
[identity]
[kvs]
[ldap]
[matchmaker_ring]
[memcache]
[oauth1]
[os_inherit]
[paste_deploy]
[policy]
[revoke]
[signing]
[ssl]
[stats]
[token]
[trust]
[extra_headers]
Distribution = Ubuntu
EOF
#
echo "##### Xoa DB mac dinh #####"
rm  /var/lib/keystone/keystone.db

echo "##### Khoi dong lai MYSQL #####"
service keystone restart
sleep 3
service keystone restart

echo "##### Dong bo cac bang trong DB #####"
sleep 3
keystone-manage db_sync

(crontab -l -u keystone 2>&1 | grep -q token_flush) || \
echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' >> /var/spool/cron/crontabs/keystone
