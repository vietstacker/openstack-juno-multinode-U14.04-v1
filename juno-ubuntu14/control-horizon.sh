#!/bin/bash -ex

source config.cfg

###################
echo "########## CAI DAT DASHBOARD ##########"
###################
sleep 5

echo "########## Cài đặt Dashboard ##########"
apt-get -y install openstack-dashboard memcached && dpkg --purge openstack-dashboard-ubuntu-theme


echo "########## Cau hinh fix loi cho apache2 ##########"
sleep 5
# Fix loi apache cho ubuntu 14.04
# echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf
# sudo a2enconf servername 
echo "ServerName localhost" >> /etc/apache2/httpd.conf


echo "########## Tao trang redirect ##########"

filehtml=/var/www/index.html
test -f $filehtml.orig || cp $filehtml $filehtml.orig
rm $filehtml
touch $filehtml
cat << EOF >> $filehtml
<html>
<head>
<META HTTP-EQUIV="Refresh" Content="0.5; URL=http://$CON_EXT_IP/horizon">
</head>
<body>
<center> <h1>Dang chuyen den Dashboard cua OpenStack</h1> </center>
</body>
</html>
EOF

# Cho phep chen password tren dashboad ( chi ap dung voi image tu dong )
sed -i "s/'can_set_password': False/'can_set_password': True/g" /etc/openstack-dashboard/local_settings.py

## /* Khởi động lại apache và memcached
service apache2 restart
service memcached restart
echo "########## Hoan thanh cai dat Horizon ##########"

echo "########## THONG TIN DANG NHAP VAO HORIZON ##########"
echo "URL: http://$CON_EXT_IP/horizon"
echo "User: admin hoac demo"
echo "Password:" $ADMIN_PASS