Hướng dẫn chạy script cài đặt OpenStack Juno trên nhiều máy chủ
===
# Mục lục

[A. Thông tin LAB](#thongtinlab)

[A.0 Chuẩn bị trên VMware Workstation](#chuanbitrenvmware)

[A.1. Mô hình triển khai trong môi trường VMware Workstation] (#mohinhtrienkhai)

[A.2 Thiết lập cho từng node](#thietlapchotungnode)

[B. Các bước thực hiện chung](#B)

[C. Thực hiện trên CONTROLLER NODE](#C)

[D. CÀI ĐẶT TRÊN NETWORK NODE](#D)

[ E. CÀI ĐẶT TRÊN COMPUTE NODE](#E)

[F. CÀI HORIZON, tạo các network trên CONTROLLER NODE](#F)

[KÊT THÚC](#ketthuc)


<a name="thongtinlab"></a>
### A. Thông tin LAB
<a name="chuanbitrenvmware"></a>
#### A.0. Chuẩn bị trên VMware Workstation
<b> Cấu hình các vmnet trong vmware workdstation như hình dưới. (Đảm bảo các dải thiết lập đúng với từng vmnet)</b>
- VMNET0 - Chế độ bridge (mặc định). Nhận cùng dải IP card mạng trong laptop, 192.168.1.0/24
- VMNET2 - Chế độ VMNET 2. Đặt dải IP 10.10.10.0/24
- VMNET3 - Chế độ VMNET 3. Đặt dải IP 10.10.20.0/24
Vào tab "Edit" ==> Virtual Network Editor.
![Alt text](http://i.imgur.com/qQkp9EE.png)

<a name="mohinhtrienkhai"></a>
#### A.1. Mô hình triển khai trong môi trường VMware Workstation
Mô hình 3 node cài đặt OpenStack bên trong một máy LAPTOP

![Alt text](http://i.imgur.com/1htxCxz.png)

<a name="thietlapchotungnode"></a>
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

<a name="B"></a>
### B. Các bước thực hiện chung

#### B.1. Thao tác trên tất cả các máy chủ
Truy cập bằng tài khoản root vào máy các máy chủ và tải các gói, script chuẩn bị cho quá trình cài đặt
```sh
apt-get update

apt-get install git -y
	
git clone https://github.com/vietstacker/openstack-juno-multinode-U14.04-v1.git
	
mv /root/openstack-juno-multinode-U14.04-v1/juno-ubuntu14.04/ juno-ubuntu14.04

rm -rf openstack-juno-multinode-U14.04-v1

cd juno-ubuntu14.04/

chmod +x *.sh
```
#### B.2. Sửa file khai báo các thông số trước khi thực thi shell
Trước lúc chỉnh sửa, KHÔNG cần gán IP tĩnh cho các NICs trên từng máy chủ.
Dùng vi để sửa file config.cfg nằm trong thư mục juno-ubuntu14.04 với các IP theo ý bạn hoặc giữ nguyên các IP và đảm bảo chúng chưa được gán cho máy nào trong mạng của bạn.
File gốc như sau: (tốt nhất đặt giống file gốc)
....
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
.....

Sau khi thay đổi xong chuyển qua thực thi các file dưới trên từng node

<a name="C"></a>
### C. Thực hiện trên CONTROLLER NODE
#### C.1. Thực thi script thiết lập IP, hostname ...
```sh
bash control-1.ipadd.sh
```	
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
Sau đó di chuyển vào thư mục juno-ubuntu14.04 bằng lệnh cd và thực thi bằng lệnh bash
```sh
cd juno-ubuntu14.04
bash control-2.prepare.sh
```
    
#### C.3. Tạo Database cho các thành phần 
Thực thi shell dưới để tạo các database, user của database cho các thành phần
```sh
bash control-3.create-db.sh
```	
#### C.4 Cài đặt và cấu hình keystone
```sh
bash control-4.keystone.sh
```
#### C.5. Tạo user, role, tenant, phân quyền cho user và tạo các endpoint
Shell dưới thực hiện việc tạo user, tenant và gán quyền cho các user. 
<br>Tạo ra các endpoint cho các dịch vụ. Các biến trong shell được lấy từ file config.cfg

```sh
bash control-5-creatusetenant.sh
```

Thực thi file admin-openrc.sh để khai báo biến môi trường.

```sh
source admin-openrc.sh
```

Và kiểm tra lại dịch vụ keystone xem đã hoạt động tốt chưa bằng lệnh dưới.

```sh
keystone user-list
```
	
Kết quả của lệnh keystone user-list như sau 

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

Chuyển qua cài các dịch vụ tiếp theo
    
#### C.6. Cài đặt thành phần GLANCE
GLANCE dùng để cung cấp image template để khởi tạo máy ảo

```sh
bash control-6.glance.sh
```
	
- Shell thực hiện việc cài đặt GLANCE và tạo image với hệ điều hành Cirros (Bản Ubuntu thu gọn) dùng để kiểm tra GLANCE và tạo máy ảo sau này.
    
#### C.7 Cài đặt NOVA
```sh
bash control-7.nova.sh
```

#### C.8 Cài đặt NEUTRON
```sh
bash control-8.neutron.sh
```

#### C.9 Cài đặt CINDER
```sh
bash control-9.cinder.sh
```

Tạm dừng việc cài đặt trên CONTROLLER NODE, sau khi cài xong NETWORK NODE và COMPUTE1 NODE sẽ quay lại để cài HORIZON và tạo các network, router.

<a name="D"></a>
### D. CÀI ĐẶT TRÊN NETWORK NODE
- Cài đặt NEUTRON, ML2 và cấu hình GRE, sử dụng use case per-router per-tenant.
- Lưu ý: Cần thực hiện bước tải script từ github về như hướng dẫn ở bước B.1 và B.2 (nếu có thay đổi IP)

Truy cập bằng tài khoản root vào máy các máy chủ và tải các gói, script chuẩn bị cho quá trình cài đặt
```sh
apt-get update

apt-get install git -y
	
git clone https://github.com/vietstacker/openstack-juno-multinode-U14.04-v1.git
	
mv /root/openstack-juno-multinode-U14.04-v1/juno-ubuntu14.04/ juno-ubuntu14.04

rm -rf openstack-juno-multinode-U14.04-v1

cd juno-ubuntu14.04/

chmod +x *.sh
```

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
- Di chuyển vào thư mục juno-ubuntu14.04 và thực thi shell dưới
```sh
cd juno-ubuntu14.04
bash net-prepare.sh
```
Kết thúc cài đặt trên NETWORK NODE và chuyển sang cài đặt COMPUTE NODE

<a name="E"></a>
### E. CÀI ĐẶT TRÊN COMPUTE NODE (COMPUTE1)
- Lưu ý: Cần thực hiện bước tải script từ github về như hướng dẫn ở bước B.1 và B.2 (nếu có thay đổi IP)
- Thực hiện các shell dưới để thiết lập hostname, gán ip và cài đặt các thành phần của nove trên máy COMPUTE NODE
- Truy cập bằng tài khoản root vào máy các máy chủ và tải các gói, script chuẩn bị cho quá trình cài đặt

```sh
apt-get update

apt-get install git -y
	
git clone https://github.com/vietstacker/openstack-juno-multinode-U14.04-v1.git
	
mv /root/openstack-juno-multinode-U14.04-v1/juno-ubuntu14.04/ juno-ubuntu14.04

rm -rf openstack-juno-multinode-U14.04-v1

cd juno-ubuntu14.04/

chmod +x *.sh
```
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

```sh
cd juno-ubuntu14.04
bash com1-prepare.sh
```

Chọn YES ở màn hình trên trong quá trình cài đặt

![Alt text](http://i.imgur.com/jlRegTI.png)

Kết thúc bước cài đặt trên COMPUTE NODE, chuyển về CONTROLLER NODE.

<a name="F"></a>
### F. CÀI HORIZON, tạo các network trên CONTROLLER NODE

#### F.1. Cài đặt Horizon
Đăng nhập bằng tài khoản root và đứng tại thư mục /root/juno-ubuntu14.04

```sh
    cd /root/juno-ubuntu14.04
	
    bash control-horizon.sh
```

Sau khi thực hiện xong việc cài đặt HORIZON, màn hình sẽ trả về IP ADD, User và Password để đăng nhập vào horizon    
    
#### F.2. Tạo PUBLIC NET, PRIVATE NET, ROUTER
Tạo các policy để cho phép các máy ở ngoài có thể truy cập vào máy ảo (Instance) qua IP PUBLIC được floating.
Thực hiện script dưới để tạo các loại network cho OpenStack
Tạo router, gán subnet cho router, gán gateway cho router
Khởi tạo một máy ảo với image là cirros để test

```sh
    bash creat-network.sh
``` 

#### Khởi động lại các node
Khởi động lần lượt các node
- CONTROLLER 
- NETWORK NODE 
- COMPUTE NODE 
Và đăng nhập vào HORIZON ở bước F.1 và sử dụng OpenStack

<a name="ketthuc"></a>
### KÊT THÚC
 CHÚC VUI !











