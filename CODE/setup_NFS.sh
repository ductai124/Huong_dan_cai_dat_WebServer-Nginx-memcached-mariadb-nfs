#! /bin/bash

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