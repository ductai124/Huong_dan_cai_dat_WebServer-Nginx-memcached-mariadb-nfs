#! /bin/bash

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