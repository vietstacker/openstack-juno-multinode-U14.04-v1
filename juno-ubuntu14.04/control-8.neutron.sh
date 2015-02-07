#!/bin/bash -ex
#
# RABBIT_PASS=a
# ADMIN_PASS=a

source config.cfg

SERVICE_TENANT_ID=`keystone tenant-get service | awk '$2~/^id/{print $4}'`


echo "########## Install NEUTRON in $CON_MGNT_IP or NETWORK node ################"
sleep 5
apt-get -y install neutron-server neutron-plugin-ml2 python-neutronclient

######## Backup configuration NEUTRON.CONF in $CON_MGNT_IP##################"
echo "########## Config NEUTRON in $CON_MGNT_IP/NETWORK node ##########"
sleep 7

#
controlneutron=/etc/neutron/neutron.conf
test -f $controlneutron.orig || cp $controlneutron $controlneutron.orig
rm $controlneutron
touch $controlneutron
cat << EOF >> $controlneutron
[DEFAULT]
verbose = True
lock_path = \$state_path/lock

core_plugin = ml2
service_plugins = router
allow_overlapping_ips = True

rpc_backend = rabbit
rabbit_host = $CON_MGNT_IP
rabbit_password = $RABBIT_PASS

auth_strategy = keystone

notify_nova_on_port_status_changes = True
notify_nova_on_port_data_changes = True
nova_url = http://$CON_MGNT_IP:8774/v2
nova_admin_auth_url = http://$CON_MGNT_IP:35357/v2.0
nova_region_name = regionOne
nova_admin_username = nova
nova_admin_tenant_id = $SERVICE_TENANT_ID
nova_admin_password = $NOVA_PASS

[matchmaker_redis]
[matchmaker_ring]

[quotas]
[agent]
root_helper = sudo /usr/bin/neutron-rootwrap /etc/neutron/rootwrap.conf

[keystone_authtoken]
auth_uri = http://$CON_MGNT_IP:5000/v2.0
identity_uri = http://$CON_MGNT_IP:35357
admin_tenant_name = service
admin_user = neutron
admin_password = $NEUTRON_PASS

[database]
connection = mysql://neutron:$NEUTRON_DBPASS@$CON_MGNT_IP/neutron

[service_providers]
service_provider=LOADBALANCER:Haproxy:neutron.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
service_provider=VPN:openswan:neutron.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default

EOF


######## Backup configuration of ML2 in $CON_MGNT_IP##################"
echo "########## Configuring ML2 in $CON_MGNT_IP/NETWORK node ##########"
sleep 7

controlML2=/etc/neutron/plugins/ml2/ml2_conf.ini
test -f $controlML2.orig || cp $controlML2 $controlML2.orig
rm $controlML2
touch $controlML2

cat << EOF >> $controlML2
[ml2]
type_drivers = flat,gre
tenant_network_types = gre
mechanism_drivers = openvswitch

[ml2_type_flat]
[ml2_type_vlan]
[ml2_type_gre]
tunnel_id_ranges = 1:1000

[ml2_type_vxlan]

[securitygroup]
enable_security_group = True
enable_ipset = True
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
EOF


su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
--config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade juno" neutron
  
echo "########## Restarting NOVA service ##########"
sleep 7 
service nova-api restart
service nova-scheduler restart
service nova-conductor restart

echo "########## Restarting NEUTRON service ##########"
sleep 7 
service neutron-server restart
