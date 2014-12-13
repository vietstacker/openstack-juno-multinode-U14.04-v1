#!/bin/bash -ex
#
source config.cfg

echo "Cau hinh cho file /etc/hosts"
sleep 3
iphost=/etc/hosts
test -f $iphost.orig || cp $iphost $iphost.orig
rm $iphost
touch $iphost
cat << EOF >> $iphost
127.0.0.1       localhost
127.0.1.1       controller
$CON_MGNT_IP    controller
$COM1_MGNT_IP      compute1
# 10.10.10.74      compute2
$NET_MGNT_IP     network
EOF

# Cai dat repos va update
# Neu la ubuntu 12 chay 2 lenh duoi
apt-get install -y python-software-properties &&  add-apt-repository cloud-archive:icehouse -y 
apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade 

# Neu la ubuntu 14.04 chay 3 lenh duoi
# apt-get update -y
# apt-get upgrade -y
# apt-get dist-upgrade -y

echo "Cai dat NTP va cau hinh NTP"
sleep 3 
apt-get install ntp -y
cp /etc/ntp.conf /etc/ntp.conf.bka
rm /etc/ntp.conf
cat /etc/ntp.conf.bka | grep -v ^# | grep -v ^$ >> /etc/ntp.conf
#
sed -i 's/server/#server/' /etc/ntp.conf
echo "server controller" >> /etc/ntp.conf

echo "Cai dat RABBITMQ  va cau hinh RABBITMQ"
sleep 3
apt-get install rabbitmq-server -y
rabbitmqctl change_password guest $RABBIT_PASS
sleep 3

service rabbitmq-server restart
echo "Da cai dat xong cac goi chuan bi"
