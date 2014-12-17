Openstack Juno installation guide on multinode
===
# Content
[A. Lab information](#Labinformation)

[A.0 Preparations on VMware Workstation](#vmwarepreparation)

[A.1. Deployment model on VMware Workstation] (#deployment)

[A.2 Nodes configuration](#nodeconfig)

[B. General execution steps](#B)

[C. Installation on CONTROLLER NODE ](#C)

[D. Installation on NETWORK NODE](#D)

[ E. Installation on COMPUTE NODE](#E)

[F. Installing HORIZON, creating networks on CONTROLLER NODE](#F)

[End](#end)


<a name="Labinformation"></a>
### A. LAB information
<a name="vmwarepreparation"></a>
#### A.0. Preparations on VMware Workstation
<b> Configurations of vmnets on vmware workdstation in the following figures.</b>
- VMNET0 - Bridge mode, 192.168.1.0/24
- VMNET2 - VMNET 2. IP range: 10.10.10.0/24
- VMNET3 - VMNET 3. IP range: 10.10.20.0/24
Go to "Edit" tab ==> Virtual Network Editor.
![Alt text](http://i.imgur.com/qQkp9EE.png)

<a name="deployment"></a>
#### A.1. Deployment model in VMware Workstation
3 nodes model of Openstack deployment in a laptop.

![Alt text](http://i.imgur.com/1htxCxz.png)

<a name="nodeconfig"></a>
#### A.2. Configuration of each node

- Ubuntu installation in Vmware Workstation must be ensured by the order of network.
- Ip addresses of NICs are dynamic, shell scripts will automatically assign static IPs later.(written in files<b><i> config.cfg </i></b>

##### A.2.1. Minimum config of CONTROLLER
- HDD: 20GB
- RAM: 2GB 
- CPU: 02 (Virtualization support)
- NIC: 02 NICs (eth0 - vmnet2 ) (eth1 - brige). Dynamic IP. 

As showed as following figure:
![Alt text](http://i.imgur.com/tlk95hq.png)

##### A.2.2. Minimum config of NETWORK NODE
- HDD: 20GB 
- RAM: 2GB
- CPU 01 (Virtualization support)
- NICs: 03. eth0-vmnet2. eth1-bridge . eth2-vmnet3. Dynamic IP.
- Hostname: network

As showed as following figure:

![Alt text](http://i.imgur.com/AeXsglg.png)

##### A.2.3. Minimum config of COMPUTE NODE (COMPUTE1)
- HDD: 60GB
- RAM: 3GB 
- CPU 2x2 (Virtualization support)
- NICs: 03. eth0-vmnet2. eth1-bridge . eth2-vmnet3. Dynamic IP.
- Hostname: compute1 

As showed as following figure:

![Alt text](http://i.imgur.com/zuNIVIE.png)

<a name="B"></a>
### B. General execution steps

#### B.1. Manipulations on host machines.
Access under the "root" user into host machines and install packages, preparation scripts for installing process.  
```sh
apt-get update

apt-get install git -y
	
git clone https://github.com/vietstacker/openstack-juno-multinode-U14.04-v1.git
	
mv /root/openstack-juno-multinode-U14.04-v1/juno-ubuntu14.04/ juno-ubuntu14.04

rm -rf openstack-juno-multinode-U14.04-v1

cd juno-ubuntu14.04/

chmod +x *.sh
```
#### B.2. Modifying configurations before executing the shells.
Before modifying, no need to assign static IP to NICs on each host machine.
Modify the file config.cfg lying in the repo juno-ubuntu14.04 with your own IPs or remain IPs and ensure that they are not used by other machines
in your network.

Here is initial file :
....
	# IP assignment in CONTROLLER NODE
	CON_MGNT_IP=10.10.10.71
	CON_EXT_IP=192.168.1.71

	# IP assignment in NETWORK NODE
	NET_MGNT_IP=10.10.10.72
	NET_EXT_IP=192.168.1.72
	NET_DATA_VM_IP=10.10.20.72

	# IP assignment in COMPUTE1 NODE
	COM1_MGNT_IP=10.10.10.73
	COM1_EXT_IP=192.168.1.73
	COM1_DATA_VM_IP=10.10.20.73

	# IP assignment in COMPUTE2 NODE
	COM2_MGNT_IP=10.10.10.74
	COM2_EXT_IP=192.168.1.74
	COM2_DATA_VM_IP=10.10.20.74

	GATEWAY_IP=192.168.1.1
	NETMASK_ADD=255.255.255.0

	# Set password
	DEFAULT_PASS='Welcome123'
.....

Execution in each node

<a name="C"></a>
### C. Execution on the CONTROLLER NODE
#### C.1. Scripts execution
```sh
bash control-1.ipadd.sh
```	
After executing scripts, the Controller will restart and has the following parameters:

<table>
  <tr>
    <th>Hostname</th>
    <th>NICs</th>
    <th>IP ADDRESS</th>
    <th>SUBNET MASK</th>
    <th>GATEWAY</th>
    <th>DNS</th>
    <th>Note</th>
  </tr>
  <tr>
    <td rowspan="2"> controller</td>
    <td>eth0</td>
    <td>10.10.10.71</td>
    <td>255.255.255.0</td>
    <td>    </td>
    <td>    </td>
    <td>VMNET2</td>
  </tr>
  <tr>
    <td>eth1</td>
    <td>192.168.1.71</td>
    <td>255.255.255.0</td>
    <td>192.168.1.1</td>
    <td>8.8.8.8</td>
    <td>brige</td>
  </tr>
</table>

#### C.2. MYSQL, NTP installations on the Controller Node
Access to the controller node with the address of <b>CON_EXT_IP</b> declared in the file <b><i>config.cfg</i></b> 192.168.1.71 under the "root" user.
```sh
cd juno-ubuntu14.04
bash control-2.prepare.sh
```
    
#### C.3. Creating Database 
```sh
bash control-3.create-db.sh
```	
#### C.4 Configuring and installing keystone
```sh
bash control-4.keystone.sh
```
#### C.5. Creating user, role, tenant, endpoint and  privilege for user

<br>Creates endpoints to the services. The parameters in shell are get from config.cfg

```sh
bash control-5-creatusetenant.sh
```
Executing the openrc file

```sh
source admin-openrc.sh
```

Checking again keystone service

```sh
keystone user-list
```
	
Result of keystone user-list 

```sh
    +----------------------------------+---------+---------+-----------------------+
    |                id                |   name  | enabled |         email         |
    +----------------------------------+---------+---------+-----------------------+
    | eda2f227988a45fcbc9ffb0abd405c6c |  admin  |   True  |  congtt@teststack.com |
    | 07f996af33f14415adaf8d6aa6b8be83 |  cinder |   True  |  cinder@teststack.com |
    | 6a198132f715468e860fa25d8163888e |   demo  |   True  |  congtt@teststack.com |
    | 4fa14e44dafb48f09b2febaa2a665311 |  glance |   True  |  glance@teststack.com |
    | 5f345c4a266d4c7691831924e1eec1f5 | neutron |   True  | neutron@teststack.com |
    | d4b7c90da1c148be8741168c916cf149 |   nova  |   True  |   nova@teststack.com  |
    | ddcb21870b4847b4b72853cfe7badd07 |  swift  |   True  |  swift@teststack.com  |
    +----------------------------------+---------+---------+-----------------------+
```

Installation of other services
    
#### C.6. GLANCE installation

```sh
bash control-6.glance.sh
```
	
    
#### C.7 NOVA installation
```sh
bash control-7.nova.sh
```

#### C.8 NEUTRON installation
```sh
bash control-8.neutron.sh
```

#### C.9 CINDER installation
```sh
bash control-9.cinder.sh
```


<a name="D"></a>
### D. Installation on the NETWORK NODE
- Installing NEUTRON, ML2 and GRE config, using use case per-router per-tenant.

Access to the NETWORK NODE under the "root" user 

```sh
apt-get update

apt-get install git -y
	
git clone https://github.com/vietstacker/openstack-juno-multinode-U14.04-v1.git
	
mv /root/openstack-juno-multinode-U14.04-v1/juno-ubuntu14.04/ juno-ubuntu14.04

rm -rf openstack-juno-multinode-U14.04-v1

cd juno-ubuntu14.04/

chmod +x *.sh
```

#### D.1. Configuring IP, Hostname for NETWORK NODE
Script for OpenvSwitch installtion and declaring  br-int & br-ex for OpenvSwitch

    bash net-ipadd.sh

- NETWORK NODE will restart, access again under the "root" user.
- IP và hostname parameters on the NETWORK NODE:

<table>
  <tr>
    <th>Hostname</th>
    <th>NICs</th>
    <th>IP ADDRESS</th>
    <th>SUBNET MASK</th>
    <th>GATEWAY</th>
    <th>DNS</th>
    <th>NOTE</th>
  </tr>
  <tr>
    <td rowspan="3">network</td>
    <td>eth0</td>
    <td>10.10.10.72</td>
    <td>255.255.255.0</td>
    <td>   </td>
    <td>   </td>
    <td>VMNET2</td>
  </tr>
  <tr>
    <td>br-ex</td>
    <td>192.168.1.72</td>
    <td>255.255.255.0</td>
    <td>192.168.1.1</td>
    <td>8.8.8.8</td>
    <td>bridge</td>
  </tr>
  <tr>
    <td>eth2</td>
    <td>10.10.20.72</td>
    <td>255.255.255.0</td>
    <td>   </td>
    <td>   </td>
    <td>VMNET3</td>
  </tr>
</table>

Note: Shell will move eth1 to the promisc mode and assign IP for br-ex created after OpenvSwitch installation.

#### D.2. NEUTRON installation and configuration
- Using putty to ssh to the NETWORK NODE through IP 192.168.1.172 with "root" user

```sh
cd juno-ubuntu14.04
bash net-prepare.sh
```
End of installing on the NETWORK NODE and move to COMPUTE NODE

<a name="E"></a>
### E. Installing on the COMPUTE NODE (COMPUTE1)

```sh
apt-get update

apt-get install git -y
	
git clone https://github.com/vietstacker/openstack-juno-multinode-U14.04-v1.git
	
mv /root/openstack-juno-multinode-U14.04-v1/juno-ubuntu14.04/ juno-ubuntu14.04

rm -rf openstack-juno-multinode-U14.04-v1

cd juno-ubuntu14.04/

chmod +x *.sh
```
#### E.1. Assigning hostname, IP and support packages

    bash com1-ipdd.sh

NICs of COMPUTE NODE will be following:

<table>
  <tr>
    <th>Hostname</th>
    <th>NICs</th>
    <th>IP ADDRESS</th>
    <th>SUBNET MASK</th>
    <th>GATEWAY</th>
    <th>DNS</th>
    <th>NOTE</th>
  </tr>
  <tr>
    <td rowspan="3">compute1</td>
    <td>eth0</td>
    <td>10.10.10.73</td>
    <td>255.255.255.0</td>
    <td>   </td>
    <td>   </td>
    <td>VMNET2</td>
  </tr>
  <tr>
    <td>br-ex</td>
    <td>192.168.1.73</td>
    <td>255.255.255.0</td>
    <td>192.168.1.1</td>
    <td>8.8.8.8</td>
    <td>bridge</td>
  </tr>
  <tr>
    <td>eth2</td>
    <td>10.10.20.73</td>
    <td>255.255.255.0</td>
    <td>   </td>
    <td>   </td>
    <td>VMNET3</td>
  </tr>
</table>


COMPUTE node will restart, access again to execute the following scripts
    
#### E.2. Installing NOVA packages for COMPUTE NODE
Access to the compute node
```sh
cd juno-ubuntu14.04
bash com1-prepare.sh
```

Choose "YES" 

![Alt text](http://i.imgur.com/jlRegTI.png)

End of COMPUTE NODE installing, move back to the CONTROLLER NODE.

<a name="F"></a>
### F. Installation on the CONTROLLER NODE

#### F.1. Installing Horizon
Access to the controller node

```sh
    cd /root/juno-ubuntu14.04
	
    bash control-horizon.sh
```

    
#### F.2. Creating PUBLIC NET, PRIVATE NET, ROUTER
Create policies to allow external machines to access to the instances via IP PUBLIC.
Execute the following scripts to create networks for Openstack
Create router, assign subnet to router, gateway to router
Initiate a virtual machine with cirros image to test

```sh
    bash creat-network.sh
``` 

#### Restarting nodes
Restart nodes in order:
- CONTROLLER 
- NETWORK NODE 
- COMPUTE NODE 

<a name="end"></a>
### The end
 Have fun!











