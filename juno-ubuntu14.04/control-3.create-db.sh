#!/bin/bash -ex

#Khai bao bien
source config.cfg
 
echo "##### Cai dat MYSQL #####"
sleep 3

echo mysql-server mysql-server/root_password password $MYSQL_ADMIN_PASS | debconf-set-selections
echo mysql-server mysql-server/root_password_again password $MYSQL_ADMIN_PASS | debconf-set-selections
apt-get update
apt-get install mysql-server python-mysqldb -y

echo "##### Cau hinh cho MYSQL #####"
sleep 3

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
sed -i "/bind-address/a\default-storage-engine = innodb\n\
collation-server = utf8_general_ci\n\
init-connect = 'SET NAMES utf8'\n\
character-set-server = utf8" /etc/mysql/my.cnf
#
service mysql restart

echo "##### Tao DATABASE #####"
sleep 3

cat << EOF | mysql -uroot -p$MYSQL_PASS
DROP DATABASE IF EXISTS keystone;
DROP DATABASE IF EXISTS glance;
DROP DATABASE IF EXISTS nova;
DROP DATABASE IF EXISTS cinder;
DROP DATABASE IF EXISTS neutron;
#
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'controller' IDENTIFIED BY '$MYSQL_PASS';
CREATE DATABASE glance;
#
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'controller' IDENTIFIED BY '$MYSQL_PASS';
#
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'controller' IDENTIFIED BY '$MYSQL_PASS';
#
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'controller' IDENTIFIED BY '$MYSQL_PASS';
#
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'controller' IDENTIFIED BY '$MYSQL_PASS';
#
FLUSH PRIVILEGES;
EOF
#
echo "##### KET THUC QUA TRINH CAI VA TAO DB #####"
exit;