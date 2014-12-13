HDCD - OpenStack Icehouse - Multi node
===
**MỤC LỤC**  *được tạo bởi [DocToc](http://doctoc.herokuapp.com/)*

- [HDCD - OpenStack Icehouse - Multi node](#user-content-hdcd---openstack-icehouse---multi-node)
	- [- KÊT THÚC](#user-content---k%C3%8At-th%C3%9Ac)
		- [A. Thông tin LAB](#user-content-a-th%C3%B4ng-tin-lab)
			- [A.0. Chuẩn bị trên VMware Workstation](#user-content-a0-chu%E1%BA%A9n-b%E1%BB%8B-tr%C3%AAn-vmware-workstation)
			- [A.1. Mô hình triển khai trong môi trường VMware Workstation](#user-content-a1-m%C3%B4-h%C3%ACnh-tri%E1%BB%83n-khai-trong-m%C3%B4i-tr%C6%B0%E1%BB%9Dng-vmware-workstation)
			- [A.2. Thiết lập cho từng node](#user-content-a2-thi%E1%BA%BFt-l%E1%BA%ADp-cho-t%E1%BB%ABng-node)
				- [A.2.1. Cấu hình tối hiểu cho máy CONTROLLER](#user-content-a21-c%E1%BA%A5u-h%C3%ACnh-t%E1%BB%91i-hi%E1%BB%83u-cho-m%C3%A1y-controller)
				- [A.2.2. Cấu hình tối thiểu cho NETWORK NODE](#user-content-a22-c%E1%BA%A5u-h%C3%ACnh-t%E1%BB%91i-thi%E1%BB%83u-cho-network-node)
				- [A.2.3. Cấu hình tối thiểu cho COMPUTE NODE (COMPUTE1)](#user-content-a23-c%E1%BA%A5u-h%C3%ACnh-t%E1%BB%91i-thi%E1%BB%83u-cho-compute-node-compute1)
		- [B. Các bước thực hiện chung](#user-content-b-c%C3%A1c-b%C6%B0%E1%BB%9Bc-th%E1%BB%B1c-hi%E1%BB%87n-chung)
			- [B.1. Thao tác trên tất cả các máy chủ](#user-content-b1-thao-t%C3%A1c-tr%C3%AAn-t%E1%BA%A5t-c%E1%BA%A3-c%C3%A1c-m%C3%A1y-ch%E1%BB%A7)
			- [B.2. Sửa file khai báo các thông số trước khi thực thi shell](#user-content-b2-s%E1%BB%ADa-file-khai-b%C3%A1o-c%C3%A1c-th%C3%B4ng-s%E1%BB%91-tr%C6%B0%E1%BB%9Bc-khi-th%E1%BB%B1c-thi-shell)
		- [C. Thực hiện trên CONTROLLER NODE](#user-content-c-th%E1%BB%B1c-hi%E1%BB%87n-tr%C3%AAn-controller-node)
			- [C.1. Thực thi script thiết lập IP, hostname ...](#user-content-c1-th%E1%BB%B1c-thi-script-thi%E1%BA%BFt-l%E1%BA%ADp-ip-hostname-)
			- [C.2. Cài đặt các gói MYSQL, NTP cho Controller Node](#user-content-c2-c%C3%A0i-%C4%91%E1%BA%B7t-c%C3%A1c-g%C3%B3i-mysql-ntp-cho-controller-node)
			- [C.3. Tạo Database cho các thành phần](#user-content-c3-t%E1%BA%A1o-database-cho-c%C3%A1c-th%C3%A0nh-ph%E1%BA%A7n)
			- [C.4 Cài đặt và cấu hình keystone](#user-content-c4-c%C3%A0i-%C4%91%E1%BA%B7t-v%C3%A0-c%E1%BA%A5u-h%C3%ACnh-keystone)
			- [C.5. Tạo user, role, tenant, phân quyền cho user và tạo các endpoint](#user-content-c5-t%E1%BA%A1o-user-role-tenant-ph%C3%A2n-quy%E1%BB%81n-cho-user-v%C3%A0-t%E1%BA%A1o-c%C3%A1c-endpoint)
			- [C.6. Cài đặt thành phần GLANCE](#user-content-c6-c%C3%A0i-%C4%91%E1%BA%B7t-th%C3%A0nh-ph%E1%BA%A7n-glance)
			- [C.7 Cài đặt NOVA](#user-content-c7-c%C3%A0i-%C4%91%E1%BA%B7t-nova)
			- [C.8 Cài đặt NEUTRON](#user-content-c8-c%C3%A0i-%C4%91%E1%BA%B7t-neutron)
		- [D. CÀI ĐẶT TRÊN NETWORK NODE](#user-content-d-c%C3%80i-%C4%90%E1%BA%B6t-tr%C3%8An-network-node)
			- [D.1. Thiết lập IP, Hostname cho NETWORK NODE](#user-content-d1-thi%E1%BA%BFt-l%E1%BA%ADp-ip-hostname-cho-network-node)
			- [D.2. Thực thi việc cài đặt NEUTRON và cấu hình](#user-content-d2-th%E1%BB%B1c-thi-vi%E1%BB%87c-c%C3%A0i-%C4%91%E1%BA%B7t-neutron-v%C3%A0-c%E1%BA%A5u-h%C3%ACnh)
		- [E. CÀI ĐẶT TRÊN COMPUTE NODE (COMPUTE1)](#user-content-e-c%C3%80i-%C4%90%E1%BA%B6t-tr%C3%8An-compute-node-compute1)
			- [E.1. Đặt hostname, IP và các gói bổ trợ](#user-content-e1-%C4%90%E1%BA%B7t-hostname-ip-v%C3%A0-c%C3%A1c-g%C3%B3i-b%E1%BB%95-tr%E1%BB%A3)
			- [E.2. Cài đặt các gói của NOVA cho COMPUTE NODE](#user-content-e2-c%C3%A0i-%C4%91%E1%BA%B7t-c%C3%A1c-g%C3%B3i-c%E1%BB%A7a-nova-cho-compute-node)
		- [F. CÀI HORIZON, tạo các network trên CONTROLLER NODE](#user-content-f-c%C3%80i-horizon-t%E1%BA%A1o-c%C3%A1c-network-tr%C3%AAn-controller-node)
			- [F.1. Cài đặt Horizon](#user-content-f1-c%C3%A0i-%C4%91%E1%BA%B7t-horizon)
			- [F.2. Tạo PUBLIC NET, PRIVATE NET, ROUTER](#user-content-f2-t%E1%BA%A1o-public-net-private-net-router)
			- [Khởi động lại các node](#user-content-kh%E1%BB%9Fi-%C4%91%E1%BB%99ng-l%E1%BA%A1i-c%C3%A1c-node)

### A. Thông tin LAB
#### A.0. Chuẩn bị trên VMware Workstation
<b> Cấu hình các vmnet trong vmware workdstation như hình dưới. (Đảm bảo các dải thiết lập đúng với từng vmnet)</b>
- VMNET0 - Chế độ bridge (mặc định). Nhận cùng dải IP card mạng trong laptop, 192.168.1.0/24
- VMNET2 - Chế độ VMNET 2. Đặt dải IP 10.10.10.0/24
- VMNET3 - Chế độ VMNET 3. Đặt dải IP 10.10.20.0/24
Vào tab "Edit" ==> Virtual Network Editor.
![Alt text](http://i.imgur.com/qQkp9EE.png)

#### A.1. Mô hình triển khai trong môi trường VMware Workstation
Mô hình 3 node cài đặt OpenStack bên trong một máy LAPTOP

![Alt text](http://i.imgur.com/1htxCxz.png)

#### A.2. Thiết lập cho từng node

- Khi cài đặt UBUNTU trong Vmware Workstation đảm bảo đúng thứ tự network
- Địa chỉ IP của các NICs để động, các shell sẽ tự động gán IP tĩnh sau (khai báo trong file <b><i> config.cfg </i></b>

##### A.2.1. Cấu hình tối hiểu cho máy CONTROLLER
- HDD: 20GB trở lên
- RAM: 2GB trở lên
- CPU: 02 (Có tích vào các chế độ ảo hóa)
- NIC: 02 NICs (eth0 - chế độ vmnet2 ) (eth1 - chế độ brige). Đặt IP động 

Minh họa bằng hình như sau:
![Alt text](http://i.imgur.com/tlk95hq.png)

##### A.2.2. Cấu hình tối thiểu cho NETWORK NODE
- HDD: 20GB 
- RAM: 2GB
- CPU 01 (có lựa chọn chế độ ảo hóa)
- NICs: 03. eth0 chế độ vmnet2. eth1 chế chộ bridge . eth2 chế độ vmnet3. Đặt IP động.
- Hostname: network

Minh họa bằng hình:

![Alt text](http://i.imgur.com/AeXsglg.png)

##### A.2.3. Cấu hình tối thiểu cho COMPUTE NODE (COMPUTE1)
- HDD: 60GB
- RAM: 3GB 
- CPU 2x2 (Có lựa chọn ảo hóa)
- NICs: 03. eth0 chế độ vmnet2. eth1 chế chộ bridge . eth2 chế độ vmnet3. Đặt IP động.
- Hostname: compute1 

Minh họa bằng hình:

![Alt text](http://i.imgur.com/zuNIVIE.png)

### B. Các bước thực hiện chung

#### B.1. Thao tác trên tất cả các máy chủ
Truy cập bằng tài khoản root vào máy các máy chủ và tải các gói, script chuẩn bị cho quá trình cài đặt
```sh
apt-get update

apt-get install git -y
	
git clone https://github.com/vietstacker/openstack-icehouse-multinode-ubuntu-v1.git
	
mv /root/openstack-icehouse-multinode-ubuntu-v1/script-ubuntu1204/ script-ubuntu1204
	
cd script-ubuntu1204
	
chmod +x *.sh
```
#### B.2. Sửa file khai báo các thông số trước khi thực thi shell
Trước lúc chỉnh sửa, KHÔNG cần gán IP tĩnh cho các NICs trên từng máy chủ.
Dùng vi để sửa file config.cfg nằm trong thư mục script-ubuntu1204 với các IP theo ý bạn hoặc giữ nguyên các IP và đảm bảo chúng chưa được gán cho máy nào trong mạng của bạn.
File gốc như sau: (tốt nhất đặt giống file gốc)

	# Khai bao IP cho CONTROLLER NODE
	CON_MGNT_IP=10.10.10.71
	CON_EXT_IP=192.168.1.71

	# Khai bao IP cho NETWORK NODE
	NET_MGNT_IP=10.10.10.72
	NET_EXT_IP=192.168.1.72
	NET_DATA_VM_IP=10.10.20.72

	# Khai bao IP cho COMPUTE1 NODE
	COM1_MGNT_IP=10.10.10.73
	COM1_EXT_IP=192.168.1.73
	COM1_DATA_VM_IP=10.10.20.73

	# Khai bao IP cho COMPUTE2 NODE
	COM2_MGNT_IP=10.10.10.74
	COM2_EXT_IP=192.168.1.74
	COM2_DATA_VM_IP=10.10.20.74

	GATEWAY_IP=192.168.1.1
	NETMASK_ADD=255.255.255.0

	# Set password
	DEFAULT_PASS='Welcome123'


Sau khi thay đổi xong chuyển qua thực thi các file dưới trên từng node

### C. Thực hiện trên CONTROLLER NODE
#### C.1. Thực thi script thiết lập IP, hostname ...

    bash control-1.ipadd.sh
	
Sau khi thực hiện script trên, máy Controller sẽ khởi động lại và có thông số như sau:

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
    <td>Để trống</td>
    <td>Để trống</td>
    <td>Chế độ VMNET2</td>
  </tr>
  <tr>
    <td>eth1</td>
    <td>192.168.1.71</td>
    <td>255.255.255.0</td>
    <td>192.168.1.1</td>
    <td>8.8.8.8</td>
    <td>Chế độ brige</td>
  </tr>
</table>

#### C.2. Cài đặt các gói MYSQL, NTP cho Controller Node
Đăng nhập vào Controller bằng địa chỉ <b>CON_EXT_IP</b> khai báo trong file <b><i>config.cfg</i></b> là 192.168.1.71 bằng tài khoản root.
Sau đó di chuyển vào thư mục script-ubuntu1204 bằng lệnh cd và thực thi bằng lệnh bash

    cd script-ubuntu1204
    bash control-2.prepare.sh
    
#### C.3. Tạo Database cho các thành phần 
Thực thi shell dưới để tạo các database, user của database cho các thành phần

    bash control-3.create-db.sh
	
#### C.4 Cài đặt và cấu hình keystone

    bash control-4.keystone.sh

#### C.5. Tạo user, role, tenant, phân quyền cho user và tạo các endpoint
Shell dưới thực hiện việc tạo user, tenant và gán quyền cho các user. 
<br>Tạo ra các endpoint cho các dịch vụ. Các biến trong shell được lấy từ file config.cfg

    bash control-5-creatusetenant.sh

Thực thi file admin-openrc.sh để khai báo biến môi trường.

    source admin-openrc.sh

Và kiểm tra lại dịch vụ keystone xem đã hoạt động tốt chưa bằng lệnh dưới.

    keystone user-list

Kết quả của lệnh keystone user-list như sau 

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

Chuyển qua cài các dịch vụ tiếp theo
    
#### C.6. Cài đặt thành phần GLANCE
GLANCE dùng để cung cấp image template để khởi tạo máy ảo

    bash control-6.glance.sh

- Shell thực hiện việc cài đặt GLANCE và tạo image với hệ điều hành Cirros (Bản Ubuntu thu gọn) dùng để kiểm tra GLANCE và tạo máy ảo sau này.
    
#### C.7 Cài đặt NOVA


    bash control-7.nova.sh
    
#### C.8 Cài đặt NEUTRON


    bash control-8.neutron.sh
    

Tạm dừng việc cài đặt trên CONTROLLER NODE, sau khi cài xong NETWORK NODE và COMPUTE1 NODE sẽ quay lại để cài HORIZON và tạo các network, router.

### D. CÀI ĐẶT TRÊN NETWORK NODE
- Cài đặt NEUTRON, ML2 và cấu hình GRE, sử dụng use case per-router per-tenant.
- Lưu ý: Cần thực hiện bước tải script từ github về như hướng dẫn ở bước B.1 và B.2 (nếu có thay đổi IP)

#### D.1. Thiết lập IP, Hostname cho NETWORK NODE
Script thực hiện việc cài đặt OpenvSwitch và khai báo br-int & br-ex cho OpenvSwitch

    bash net-ipadd.sh

- NETWORK NODE sẽ khởi động lại, cần phải đăng nhập lại sau khi khởi động xong bằng tài khoản root.
- Thông số về IP và hostname trên NETWORK NODE như sau:

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
    <td>Để trống</td>
    <td>Để trống</td>
    <td>Chế độ VMNET2</td>
  </tr>
  <tr>
    <td>br-ex</td>
    <td>192.168.1.72</td>
    <td>255.255.255.0</td>
    <td>192.168.1.1</td>
    <td>8.8.8.8</td>
    <td>Chế độ bridge</td>
  </tr>
  <tr>
    <td>eth2</td>
    <td>10.10.20.72</td>
    <td>255.255.255.0</td>
    <td>Để trống</td>
    <td>Để trống</td>
    <td>Chế độ VMNET3</td>
  </tr>
</table>

Chú ý: Shell sẽ chuyển eth1 sang chế độ promisc và đặt IP cho br-ex được tạo ra sau khi cài OpenvSwitch

#### D.2. Thực thi việc cài đặt NEUTRON và cấu hình
- Dùng putty ssh vào NETWORK NODE bằng IP 192.168.1.172 với tài khoản root
- Di chuyển vào thư mục script-ubuntu1204 và thực thi shell dưới
```sh
cd script-ubuntu1204
bash net-prepare.sh
```
Kết thúc cài đặt trên NETWORK NODE và chuyển sang cài đặt COMPUTE NODE

### E. CÀI ĐẶT TRÊN COMPUTE NODE (COMPUTE1)
Lưu ý: Cần thực hiện bước tải script từ github về như hướng dẫn ở bước B.1 và B.2 (nếu có thay đổi IP)
Thực hiện các shell dưới để thiết lập hostname, gán ip và cài đặt các thành phần của nove trên máy COMPUTE NODE

#### E.1. Đặt hostname, IP và các gói bổ trợ

    bash com1-ipdd.sh

Sau khi thực hiện xong shell trên các NICs của COMPUTE NODE sẽ như sau: (giống với khai báo trong file <b><i>config.cfg</i></b>)

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
    <td>Để trống</td>
    <td>Để trống</td>
    <td>Chế độ VMNET2</td>
  </tr>
  <tr>
    <td>br-ex</td>
    <td>192.168.1.73</td>
    <td>255.255.255.0</td>
    <td>192.168.1.1</td>
    <td>8.8.8.8</td>
    <td>Chế độ bridge</td>
  </tr>
  <tr>
    <td>eth2</td>
    <td>10.10.20.73</td>
    <td>255.255.255.0</td>
    <td>Để trống</td>
    <td>Để trống</td>
    <td>Chế độ VMNET3</td>
  </tr>
</table>


COMPUTE node sẽ khởi động lại, cần phải đăng nhập bằng tải khoản root để thực hiện shell dưới
    
#### E.2. Cài đặt các gói của NOVA cho COMPUTE NODE
Đăng nhập bằng tài khoản root và thực thi các lệnh dưới để tiến hành cài đặt nova

    cd script-ubuntu1204
	
    bash com1-prepare.sh

Chọn YES ở màn hình trên trong quá trình cài đặt

![Alt text](http://i.imgur.com/jlRegTI.png)

Kết thúc bước cài đặt trên COMPUTE NODE, chuyển về CONTROLLER NODE.



### F. CÀI HORIZON, tạo các network trên CONTROLLER NODE

#### F.1. Cài đặt Horizon
Đăng nhập bằng tài khoản root và đứng tại thư mục /root/script-ubuntu1204

    cd /root/script-ubuntu1204
	
    bash control-horizon.sh

Sau khi thực hiện xong việc cài đặt HORIZON, màn hình sẽ trả về IP ADD, User và Password để đăng nhập vào horizon    
    
#### F.2. Tạo PUBLIC NET, PRIVATE NET, ROUTER
Tạo các policy để cho phép các máy ở ngoài có thể truy cập vào máy ảo (Instance) qua IP PUBLIC được floating.
Thực hiện script dưới để tạo các loại network cho OpenStack
Tạo router, gán subnet cho router, gán gateway cho router
Khởi tạo một máy ảo với image là cirros để test

    bash creat-network.sh

#### Khởi động lại các node
Khởi động lần lượt các node
- CONTROLLER 
- NETWORK NODE 
- COMPUTE NODE 
Và đăng nhập vào HORIZON ở bước F.1 và sử dụng OpenStack
### KÊT THÚC
 CHÚC VUI !











