#!/bin/bash -ex
source config.cfg

ifaces=/etc/network/interfaces
test -f $ifaces.orig || cp $ifaces $ifaces.orig
rm $ifaces
touch $ifaces
cat << EOF >> $ifaces
#Assign IP for Controller node

# LOOPBACK NET 
auto lo
iface lo inet loopback

# MGNT NETWORK
auto eth0
iface eth0 inet static
address $CON_MGNT_IP
netmask $NETMASK_ADD


# EXT NETWORK
auto eth1
iface eth1 inet static
address $CON_EXT_IP
netmask $NETMASK_ADD
gateway $GATEWAY_IP
dns-nameservers 8.8.8.8
EOF


echo "Configuring hostname in CONTROLLER node"
sleep 3
echo "controller" > /etc/hostname
hostname -F /etc/hostname

#Khoi dong lai cac card mang vua dat
# service networking restart

#service networking restart
# ifdown eth0 && ifup eth0
# ifdown eth1 && ifup eth1
# ifdown eth2 && ifup eth2


#sleep 5
init 6
#




