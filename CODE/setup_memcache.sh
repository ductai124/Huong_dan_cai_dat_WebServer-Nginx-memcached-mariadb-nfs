#! /bin/bash

echo "Update và upgrade và cài Wget, unzip, tar, epel, remi"
dnf upgrade --refresh -y
dnf update -y
yum -y install wget
yum -y install unzip
yum -y install tar
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y


echo "Cài đặt memcached"
dnf install memcached libmemcached -y
echo "Thông số memcached"
rpm -qi memcached
echo "Thay đổi options của memcached để các máy có thể truy cập"

sed -i 's/OPTIONS="-l 127.0.0.1,::1"/OPTIONS=""/g' /etc/sysconfig/memcached

echo "Khởi động memcached"
systemctl enable memcached.service
systemctl start memcached.service

echo "Kiểm tra memcached"
systemctl status memcached

echo "Hoàn thành cài đặt memcached"

exit 0