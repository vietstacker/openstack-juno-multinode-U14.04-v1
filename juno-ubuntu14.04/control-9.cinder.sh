#!/bin/bash -ex
source config.cfg

apt-get install lvm2 -y

echo "########## Create Physical Volume and Volume Group (in sdb disk ) ##########"
fdisk -l
pvcreate /dev/sdb
vgcreate cinder-volumes /dev/sdb

#
echo "########## Install CINDER ##########"
sleep 3
apt-get install -y cinder-api cinder-scheduler cinder-volume iscsitarget open-iscsi iscsitarget-dkms python-cinderclient


echo "########## Configuring for cinder.conf ##########"

filecinder=/etc/cinder/cinder.conf
test -f $filecinder.orig || cp $filecinder $filecinder.orig
rm $filecinder
cat << EOF > $filecinder
[DEFAULT]
verbose = True

rootwrap_config = /etc/cinder/rootwrap.conf
api_paste_confg = /etc/cinder/api-paste.ini
iscsi_helper = tgtadm
volume_name_template = volume-%s
volume_group = cinder-volumes
verbose = True
auth_strategy = keystone
state_path = /var/lib/cinder
lock_path = /var/lock/cinder
volumes_dir = /var/lib/cinder/volumes

auth_strategy = keystone

rpc_backend = rabbit
rabbit_host = $CON_MGNT_IP
rabbit_password = $RABBIT_PASS

my_ip = $CON_MGNT_IP

[keystone_authtoken]
auth_uri = http://$CON_MGNT_IP:5000/v2.0
identity_uri = http://$CON_MGNT_IP:35357
admin_tenant_name = service
admin_user = cinder
admin_password = $CINDER_PASS

[database]
connection = mysql://cinder:$CINDER_DBPASS@$CON_MGNT_IP/cinder

EOF

sed  -r -e 's#(filter = )(\[ "a/\.\*/" \])#\1[ "a\/sda1\/", "a\/sdb\/", "r/\.\*\/"]#g' /etc/lvm/lvm.conf

# Grant permission for cinder
chown cinder:cinder $filecinder

echo "########## Syncing Cinder DB ##########"
sleep 3
cinder-manage db sync

echo "########## Restarting CINDER service ##########"
sleep 3
service cinder-api restart
service cinder-scheduler restart
service cinder-volume restart

echo "########## Finish setting up CINDER !!! ##########"
