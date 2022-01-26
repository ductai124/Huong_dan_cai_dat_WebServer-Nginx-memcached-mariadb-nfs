#! /bin/bash

echo "Update và upgrade và cài Wget, unzip, tar, epel, remi"
echo ""
dnf upgrade --refresh -y
dnf update -y
yum -y install wget
yum -y install unzip
yum -y install tar
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

echo "Cài đặt NFS"
dnf -y install nfs-utils

#echo -e "/home/nfsshare 192.168.1.0/24(rw,no_root_squash)" >> /etc/exports

echo "tạo file exports và ghi thông số thư mục dùng để chia sẻ và lưu trữ"
echo -e "/home/nfsshare $1/24(rw,no_root_squash)" >> /etc/exports

echo "Tạo file lưu trữ chia sẻ"
mkdir /home/nfsshare

echo "Khởi động NFS"
systemctl enable --now rpcbind nfs-server

echo "Hoàn tất cài đặt NFS server"


exit 0