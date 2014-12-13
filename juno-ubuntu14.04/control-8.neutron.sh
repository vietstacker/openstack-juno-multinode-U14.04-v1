#!/bin/bash -ex
#
# RABBIT_PASS=a
# ADMIN_PASS=a

source config.cfg

SERVICE_ID=`keystone tenant-get service | awk '$2~/^id/{print $4}'`


echo "########## CAI DAT NEUTRON TREN CONTROLLER################"
sleep 5
apt-get -y install neutron-server neutron-plugin-ml2

######## SAO LUU CAU HINH NEUTRON.CONF CHO CONTROLLER##################"
echo "########## SUA FILE CAU HINH  NEUTRON CHO CONTROLLER ##########"
sleep 7

#
controlneutron=/etc/neutron/neutron.conf
test -f $controlneutron.orig || cp $controlneutron $controlneutron.orig
rm $controlneutron
touch $controlneutron
cat << EOF >> $controlneutron
[DEFAULT]
rpc_backend = neutron.openstack.common.rpc.impl_kombu
rabbit_host = controller
rabbit_password = $RABBIT_PASS
state_path = /var/lib/neutron
lock_path = \$state_path/lock
core_plugin = neutron.plugins.ml2.plugin.Ml2Plugin
notification_driver = neutron.openstack.common.notifier.rpc_notifier

verbose = True
auth_strategy = keystone
notify_nova_on_port_status_changes = True
notify_nova_on_port_data_changes = True
nova_url = http://controller:8774/v2
nova_admin_username = nova
#Thay ID trong lenh "keystone tenant-get service" vao dong duoi
nova_admin_tenant_id = $SERVICE_ID
nova_admin_password = $ADMIN_PASS
nova_admin_auth_url = http://controller:35357/v2.0
core_plugin = ml2
service_plugins = router
allow_overlapping_ips = True


[quotas]

[agent]
root_helper = sudo /usr/bin/neutron-rootwrap /etc/neutron/rootwrap.conf

[keystone_authtoken]
auth_uri = http://controller:5000
auth_host = controller
auth_protocol = http
auth_port = 35357
admin_tenant_name = service
admin_user = neutron
admin_password = $ADMIN_PASS
signing_dir = \$state_path/keystone-signing

[database]
connection = mysql://neutron:$ADMIN_PASS@controller/neutron

[service_providers]
service_provider=LOADBALANCER:Haproxy:neutron.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
service_provider=VPN:openswan:neutron.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default

EOF


######## SAO LUU CAU HINH ML2 CHO CONTROLLER##################"
echo "########## SUA FILE CAU HINH  ML2 CHO CONTROLLER ##########"
sleep 7

controlML2=/etc/neutron/plugins/ml2/ml2_conf.ini
test -f $controlML2.orig || cp $controlML2 $controlML2.orig
rm $controlML2
touch $controlML2

cat << EOF >> $controlML2
[ml2]
type_drivers = gre
tenant_network_types = gre
mechanism_drivers = openvswitch

[ml2_type_flat]

[ml2_type_vlan]

[ml2_type_gre]
tunnel_id_ranges = 1:1000

[ml2_type_vxlan]

[securitygroup]
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
enable_security_group = True
EOF



echo "########## KHOI DONG LAI NOVA ##########"
sleep 7 
service nova-api restart
service nova-scheduler restart
service nova-conductor restart

echo "########## KHOI DONG LAI NEUTRON ##########"
sleep 7 
service neutron-server restart
