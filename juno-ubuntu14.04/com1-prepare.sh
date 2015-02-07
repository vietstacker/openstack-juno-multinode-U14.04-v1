#!/bin/bash -ex
#

source config.cfg

#
iphost=/etc/hosts
test -f $iphost.orig || cp $iphost $iphost.orig
rm $iphost
touch $iphost
cat << EOF >> $iphost
127.0.0.1       localhost
127.0.0.1        compute1
$CON_MGNT_IP    controller
$COM1_MGNT_IP      compute1
$COM2_MGNT_IP	compute2
$NET_MGNT_IP     network
EOF

# Update repos

apt-get -y update
apt-get -y install nova-compute sysfsutils
# apt-get -y install nova-compute-kvm python-guestfs 
apt-get install libguestfs-tools -y

echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
sysctl -p
#
dpkg-statoverride --update --add root root 0644 /boot/vmlinuz-$(uname -r)

#
touch /etc/kernel/postinst.d/statoverride

#
cat << EOF >> /etc/kernel/postinst.d/statoverride
"#!/bin/sh"
echoversion="$1"
# passing the kernel version is required
[ -z "${version}" ] && exit 0
dpkg-statoverride --update --add root root 0644 /boot/vmlinuz-${version}
EOF

chmod +x /etc/kernel/postinst.d/statoverride
########
echo "############ Configuring in nova.conf ...############"
sleep 5
########
#/* Sao luu truoc khi sua file nova.conf
filenova=/etc/nova/nova.conf
test -f $filenova.orig || cp $filenova $filenova.orig

#Chen noi dung file /etc/nova/nova.conf vao 
cat << EOF > $filenova
[DEFAULT]
verbose = True

dhcpbridge_flagfile=/etc/nova/nova.conf
dhcpbridge=/usr/bin/nova-dhcpbridge
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/var/lock/nova
force_dhcp_release=True
libvirt_use_virtio_for_bridges=True
verbose=True
ec2_private_dns_show_ip=True
api_paste_config=/etc/nova/api-paste.ini
enabled_apis=ec2,osapi_compute,metadata

rpc_backend = rabbit
rabbit_host = $CON_MGNT_IP
rabbit_password = $RABBIT_PASS

auth_strategy = keystone

my_ip = $COM1_MGNT_IP

vnc_enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = $COM1_MGNT_IP
novncproxy_base_url = http://$CON_EXT_IP:6080/vnc_auto.html

network_api_class = nova.network.neutronv2.api.API
security_group_api = neutron
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver = nova.virt.firewall.NoopFirewallDriver

# Cho phep thay doi kich thuoc may ao
allow_resize_to_same_host=True
scheduler_default_filters=AllHostsFilter

# Cho phep chen password khi khoi tao
libvirt_inject_password = True
enable_instance_password = True
libvirt_inject_key = true
libvirt_inject_partition = -1

[glance]
host = $CON_MGNT_IP

[neutron]
url = http://$CON_MGNT_IP:9696
auth_strategy = keystone
admin_auth_url = http://$CON_MGNT_IP:35357/v2.0
admin_tenant_name = service
admin_username = neutron
admin_password = $NEUTRON_PASS

[keystone_authtoken]
auth_uri = http://$CON_MGNT_IP:5000/v2.0
identity_uri = http://$CON_MGNT_IP:35357
admin_tenant_name = service
admin_user = nova
admin_password = $NOVA_PASS
EOF

# Remove default nova db
rm /var/lib/nova/nova.sqlite


# fix bug libvirtError: internal error: no supported architecture for os type 'hvm'
echo 'kvm_intel' >> /etc/modules

# Restarting nova service
service nova-compute restart
service nova-compute restart

########
echo "############ Installing neutron agent ############"
sleep 5
########
# Install neutron agent
apt-get install neutron-common neutron-plugin-ml2 neutron-plugin-openvswitch-agent openvswitch-datapath-dkms -y

##############################
echo "############ Configuring neutron.conf ############"
sleep 5
#############################
comfileneutron=/etc/neutron/neutron.conf
test -f $comfileneutron.orig || cp $comfileneutron $comfileneutron.orig
rm $comfileneutron
#Update config file /etc/neutron/neutron.conf
 
cat << EOF > $comfileneutron
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
connection = sqlite:////var/lib/neutron/neutron.sqlite
[service_providers]
service_provider=LOADBALANCER:Haproxy:neutron.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
service_provider=VPN:openswan:neutron.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default
EOF
#

########
echo "############ Configuring ml2_conf.ini ############"
sleep 5
########
comfileml2=/etc/neutron/plugins/ml2/ml2_conf.ini
test -f $comfileml2.orig || cp $comfileml2 $comfileml2.orig
rm $comfileml2
touch $comfileml2
#Update ML2 config file /etc/neutron/plugins/ml2/ml2_conf.ini
cat << EOF > $comfileml2
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

[ovs]
local_ip = $COM1_DATA_VM_IP
enable_tunneling = True

[agent]
tunnel_types = gre

EOF

# Restarting OpenvSwitch
########
echo "############ Restarting OpenvSwitch ############"
sleep 5
########
service openvswitch-switch restart


########
echo "############ Create Integration Bridge ############"
sleep 5
########
# Create Integration Bridge
# ovs-vsctl add-br br-int


# fix bug libvirtError: internal error: no supported architecture for os type 'hvm'
echo 'kvm_intel' >> /etc/modules

##########
echo "############ Restarting Nova Compute service ############"
sleep 5

########
# Restarting Nova Compute service
service nova-compute restart
service nova-compute restart

########
echo "############ Restarting OpenvSwitch agent ############"
sleep 5
########
# Restarting OpenvSwitch agent
service neutron-plugin-openvswitch-agent restart
service neutron-plugin-openvswitch-agent restart

echo "########## Creating Environment script file ##########"
sleep 5
echo "export OS_USERNAME=admin" > admin-openrc.sh
echo "export OS_PASSWORD=$ADMIN_PASS" >> admin-openrc.sh
echo "export OS_TENANT_NAME=admin" >> admin-openrc.sh
echo "export OS_AUTH_URL=http://$CON_MGNT_IP:35357/v2.0" >> admin-openrc.sh

########
# echo "############ Testing nova and neutron ############"
# sleep 5
########
# source admin-openrc.sh
# nova-manage service list
# neutron agent-list
