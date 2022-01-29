#! /bin/bash
source /root/Baitap_tonghop-main/CODE/setup.conf.sh


if systemctl is-active --quiet nginx; then
    echo "Nginx Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi


telnet_output_mariadb="$({ sleep 1; echo $'\e'; } | telnet $ip_server_mariadb 11211 2>&1)"
telnet_output_memcached="$({ sleep 1; echo $'\e'; } | telnet $ip_server_memcached 11211 2>&1)"
telnet_output_nfs_1="$({ sleep 1; echo $'\e'; } | telnet $ip_server_nfs 2049 2>&1)"
telnet_output_nfs_2="$({ sleep 1; echo $'\e'; } | telnet $ip_server_nfs 20048 2>&1)"

check_maria="Connected to $ip_server_mariadb"
check_memcached="Connected to $ip_server_memcached"
check_nfs="Connected to $ip_server_nfs"
i=0

echo "Kiểm tra cổng dịch vụ mariadb trên server có cho phép máy chủ này kết nối không"
echo ""
if [[ "$telnet_output_mariadb" == *"$check_maria"* ]]; then
  	echo "Dịch vụ mariadb đã được mở cho máy này trên server, có thể tiến hành cài đặt"
	else
	echo "Kiểm tra server đã add source và mở cổng 3306 cho máy web server này chưa do chưa kết nối được dịch vụ mariadb"
	i=`expr $i + 1`
fi
echo ""
echo "Kiểm tra cổng dịch vụ memcached trên server có cho phép máy chủ này kết nối không"
echo ""
if [[ "$telnet_output_memcached" == *"$check_memcached"* ]]; then
  	echo "Dịch vụ memcached đã được mở cho máy này trên server, có thể tiến hành cài đặt"
	else
	echo "Kiểm tra server đã add source và mở cổng 11211 cho máy web server này chưa do chưa kết nối được dịch vụ memcached"
	i=`expr $i + 1`
fi
echo ""
echo "Kiểm tra cổng dịch vụ NFS trên server có cho phép máy chủ này kết nối không"
echo ""
if [[ "$telnet_output_nfs_1" == *"$check_nfs"* ]] && [[ "$telnet_output_nfs_2" == *"$check_nfs"* ]]
	then
  	echo "Dịch vụ nfs đã được mở cho máy này trên server, có thể tiến hành cài đặt"
	else
	echo "Kiểm tra server đã add source và mở cổng 2049 và 20048 cho máy web server này chưa do chưa kết nối được dịch vụ nfs"
	i=`expr $i + 1`
fi
echo ""
if [ $i -gt 0 ]
	then
	exit
	else
	echo "Đã đủ điểu kiện cài đặt"
fi
echo ""

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