#! /bin/bash
#Vui lòng nhập dải ip vào dòng phía bên dưới ví dụ ip_range="192.168.1.0"
#Vui lòng nhập địa chỉ ip của 2 máy web server vào dòng phía bên dưới 
#Ví dụ ip_web_server_1="192.168.1.1"
ip_range="192.168.1.0"
ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"

echo "Dải ip của bạn nhập là $ip_range"
echo "Ip máy web server số 1 là $ip_web_server_1"
echo "Ip máy web server số 2 là $ip_web_server_2"

echo "Hãy chắc chắn rằng các địa chỉ ip trên của bạn là đúng"

if systemctl is-active --quiet memcached; then
    echo "Memcached Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi
if systemctl is-active --quiet nfs-*; then
    echo "NFS Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi
if systemctl is-active --quiet mariadb; then
    echo "Mysql Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi
if systemctl is-active --quiet mysql; then
    echo "Mysql Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi

echo "Máy chủ đạt yêu cầu để cài đặt 3 dịch vụ nfs, mariadb và memcached"

# Config Selinux
#se_status=$(getenforce)
#if [ "${se_status}" != "Disabled" ]; then
#    read -r -p "Enter de khoi dong lai OS do Selinux dang bat"
#	sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/sysconfig/selinux
#	sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
#
#	dnf update -y
#	sleep 5
#	reboot
#else
#	sestatus
#fi

echo "Tiếp tục quá trình cài đặt"	

echo "Update và upgrade và cài Wget, unzip, tar, epel, remi"
dnf upgrade --refresh -y
dnf update -y
yum -y install wget unzip tar
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

echo "Tiến hành cài đặt"

bash setup_mariadb.sh
bash setup_memcache.sh

echo "Dải ip được cấp cho NFS là là : $ip_range"

bash setup_NFS.sh $ip_range

echo "Thiết lập firewall"

bash setup_firewall.sh $ip_web_server_1 $ip_web_server_2

exit 0