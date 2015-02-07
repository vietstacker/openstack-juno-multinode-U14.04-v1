#!/bin/bash -ex
#

source config.cfg

# Config for file /etc/hosts
iphost=/etc/hosts
test -f $iphost.orig || cp $iphost $iphost.orig
rm $iphost
touch $iphost
cat << EOF >> $iphost
127.0.0.1       localhost
127.0.1.1		network
$CON_MGNT_IP    controller
$COM1_MGNT_IP  	compute1
$COM2_MGNT_IP  	compute2
$NET_MGNT_IP   	network
EOF

#
echo "############ Configuring net forward for all VMs ############"
sleep 7 
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
sysctl -p 

echo "############ Install packages in network node ############ "
sleep 7 
apt-get -y install neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent

#
echo "############  Configuring for NETWORK NODE ############ "
sleep 7 
#
echo "############ Configuring neutron.conf ############"
sleep 7 
#
netneutron=/etc/neutron/neutron.conf
test -f $netneutron.orig || cp $netneutron $netneutron.orig
rm $netneutron
touch $netneutron

cat << EOF >> $netneutron
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
# connection = sqlite:////var/lib/neutron/neutron.sqlite
[service_providers]
service_provider=LOADBALANCER:Haproxy:neutron.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
service_provider=VPN:openswan:neutron.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default
EOF
#
echo "############ Configuring L3 AGENT ############"
sleep 7 
#
netl3agent=/etc/neutron/l3_agent.ini

test -f $netl3agent.orig || cp $netl3agent $netl3agent.orig
rm $netl3agent
touch $netl3agent
cat << EOF >> $netl3agent
[DEFAULT]
verbose = True
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
use_namespaces = True
external_network_bridge = br-ex
EOF
#
echo "############  Configuring DHCP AGENT ############ "
sleep 7 
#
netdhcp=/etc/neutron/dhcp_agent.ini

test -f $netdhcp.orig || cp $netdhcp $netdhcp.orig
rm $netdhcp
touch $netdhcp

cat << EOF >> $netdhcp
[DEFAULT]
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
use_namespaces = True
verbose = True
dnsmasq_config_file = /etc/neutron/dnsmasq-neutron.conf
EOF
#

echo "Fix loi MTU"
sleep 3
echo "dhcp-option-force=26,1454" > /etc/neutron/dnsmasq-neutron.conf
killall dnsmasq

echo "############  Configuring METADATA AGENT ############"
sleep 7 
#
netmetadata=/etc/neutron/metadata_agent.ini

test -f $netmetadata.orig || cp $netmetadata $netmetadata.orig
rm $netmetadata
touch $netmetadata

cat << EOF >> $netmetadata
[DEFAULT]
verbose = True

auth_url = http://$CON_MGNT_IP:5000/v2.0
auth_region = regionOne
admin_tenant_name = service
admin_user = neutron
admin_password = $NEUTRON_PASS

nova_metadata_ip = $CON_MGNT_IP

metadata_proxy_shared_secret = $METADATA_SECRET
EOF
#

echo "############ Configuring ML2 AGENT ############"
sleep 7 
#
netml2=/etc/neutron/plugins/ml2/ml2_conf.ini

test -f $netml2.orig || cp $netml2 $netml2.orig
rm $netml2
touch $netml2

cat << EOF >> $netml2
[ml2]
type_drivers = flat,gre
tenant_network_types = gre
mechanism_drivers = openvswitch

[ml2_type_flat]
flat_networks = external

[ml2_type_vlan]
tunnel_id_ranges = 1:1000

[ml2_type_gre]
[ml2_type_vxlan]
[securitygroup]
enable_security_group = True
enable_ipset = True
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

[ovs]
local_ip = $NET_DATA_VM_IP
enable_tunneling = True
bridge_mappings = external:br-ex
 
[agent]

tunnel_types = gre


EOF

echo "############  Restarting OpenvSwitch ############"
sleep 7

service openvswitch-switch restart
service neutron-plugin-openvswitch-agent restart
service neutron-l3-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart

# Starting up with OS
sed -i "s/exit 0/# exit 0/g" /etc/rc.local
echo "service openvswitch-switch restart" >> /etc/rc.local
echo "service neutron-plugin-openvswitch-agent restart" >> /etc/rc.local
echo "service neutron-l3-agent restart" >> /etc/rc.local
echo "service neutron-dhcp-agent restart" >> /etc/rc.local
echo "service neutron-metadata-agent restart" >> /etc/rc.local
echo "service neutron-lbaas-agent restart" >> /etc/rc.local
#echo "service neutron-vpn-agent restart" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local


echo "########## Creating environment script ##########"
sleep 5
echo "export OS_USERNAME=admin" > admin-openrc.sh
echo "export OS_PASSWORD=$ADMIN_PASS" >> admin-openrc.sh
echo "export OS_TENANT_NAME=admin" >> admin-openrc.sh
echo "export OS_AUTH_URL=http://$CON_MGNT_IP:35357/v2.0" >> admin-openrc.sh

echo "############ Testing all agent ############ "
sleep 1 


