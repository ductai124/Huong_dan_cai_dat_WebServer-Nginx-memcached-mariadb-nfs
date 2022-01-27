#! /bin/bash

#Nhập ip cho máy chủ nfs server ví dụ ip_server_nfs="192.168.1.23"
ip_server_nfs="192.168.1.23"

if systemctl is-active --quiet nginx; then
    echo "Nginx Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi

# Config Selinux
se_status=$(getenforce)
if [ "${se_status}" != "Disabled" ]; then
    read -r -p "Enter de khoi dong lai OS do Selinux dang bat"
	sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/sysconfig/selinux
	sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config

	dnf update -y
	sleep 5
	reboot
else
	sestatus
fi

echo "Tiếp tục quá trình cài đặt"	

echo "Update và upgrade"
dnf upgrade --refresh -y
dnf update -y
yum -y install wget unzip tar
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
#dnf install epel-release -y
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

echo "Cài đặt nginx" 
dnf -y install nginx
echo "Khởi động nginx" 
systemctl enable --now nginx

echo "Kích hoạt tường lửa cho dịch vụ nginx"
firewall-cmd --add-service=http
firewall-cmd --runtime-to-permanent

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
mount -t nfs $ip_server_nfs:/home/nfsshare /usr/share/nginx/html/

echo "Kiểm tra"
df -hT

echo "Mount nfsv3"
mount -t nfs -o vers=3 $ip_server_nfs:/home/nfsshare /usr/share/nginx/html/
echo "Kiểm tra"
df -hT /mnt

echo "Thiết lập auto mount"

echo "$ip_server_nfs:/home/nfsshare /usr/share/nginx/html/               nfs     defaults        0 0" >> /etc/fstab

echo "Gán liên kết động"
dnf -y install autofs

echo "/-    /etc/auto.mount" >> /etc/auto.master

echo "/usr/share/nginx/html/   -fstype=nfs,rw  $ip_server_nfs:/home/nfsshare" >> /etc/auto.mount

echo "Khởi động autofs"
systemctl enable --now autofs

echo "Hoàn thành cài đặt"

exit 0