#! /bin/bash

if systemctl is-active --quiet nginx; then
    echo "Nginx Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi

echo "Nhập ip của máy chủ NFS-Memcached-mariadb"
read A

echo "Update và upgrade"
dnf upgrade --refresh -y
dnf update -y
yum -y install wget
yum -y install unzip
yum -y install tar
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

echo "Cài đặt nginx" 
dnf -y install nginx
echo "Khởi động nginx" 
systemctl enable --now nginx

echo "Kích hoạt tường lửa cho dịch vụ nginx"
firewall-cmd --add-service=http
firewall-cmd --runtime-to-permanent

echo "Cài đặt php"
dnf install epel-release -y
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

echo "Cài đặt php"
dnf module enable php:remi-7.4 -y
dnf install php-pecl-memcache php-pecl-memcached -y
dnf install nginx php php-cli -y
systemctl restart nginx
systemctl status php-fpm

echo "Kết nối với máy chủ nfs"
echo "Cài đặt NFS"
dnf -y install nfs-utils

echo "Mount đến máy chủ NFS"
mount -t nfs $A:/home/nfsshare /usr/share/nginx/html/

echo "Kiểm tra"
df -hT

echo "Mount nfsv3"
mount -t nfs -o vers=3 $A:/home/nfsshare /usr/share/nginx/html/
echo "Kiểm tra"
df -hT /mnt


echo "Thiết lập auto mount"
#vi /etc/fstab
echo "$A:/home/nfsshare /usr/share/nginx/html/               nfs     defaults        0 0" >> /etc/fstab

echo "Gán liên kết động"
dnf -y install autofs

#vi /etc/auto.master
echo "/-    /etc/auto.mount" >> /etc/auto.master

#vi /etc/auto.mount
echo "/usr/share/nginx/html/   -fstype=nfs,rw  $A:/home/nfsshare" >> /etc/auto.mount

echo "Khởi động autofs"
systemctl enable --now autofs


echo "Kiểm tra"
grep /usr/share/nginx/html/ /proc/mounts

exit 0