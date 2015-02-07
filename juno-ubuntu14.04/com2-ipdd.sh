#!/bin/bash -ex

source config.cfg

echo "##### Configuring hostname for COMPUTE2 node #####"
sleep 3
echo "compute2" > /etc/hostname
hostname -F /etc/hostname


ifaces=/etc/network/interfaces
test -f $ifaces.orig || cp $ifaces $ifaces.orig
rm $ifaces
touch $ifaces
cat << EOF >> $ifaces
#Setup IP for $CON_MGNT_IP node

# LOOPBACK NET 
auto lo
iface lo inet loopback

# MGNT NETWORK
auto eth0
iface eth0 inet static
address $COM2_MGNT_IP
netmask $NETMASK_ADD


# EXT NETWORK
auto eth1
iface eth1 inet static
address $COM2_EXT_IP
netmask $NETMASK_ADD
gateway $GATEWAY_IP
dns-nameservers 8.8.8.8

# DATA NETWORK
auto eth2
iface eth2 inet static
address $COM2_DATA_VM_IP
netmask $NETMASK_ADD

EOF

#Restart network service
#service networking restart

#service networking restart
# ifdown eth0 && ifup eth0
# ifdown eth1 && ifup eth1
# ifdown eth2 && ifup eth2

#sleep 5

init 6
#




