#! /bin/bash
if systemctl is-active --quiet memcached; then
    echo "Memcached Đã được cài đặt, Không đạt yêu cầu..."
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
	
read -r -p "Enter Tiep tuc"
chattr -ai /etc/resolv.conf
cat > "/etc/resolv.conf" <<END

echo "Update và upgrade và cài Wget, unzip, tar, epel, remi"
dnf upgrade --refresh -y
dnf update -y
yum -y install wget unzip tar
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
echo "Máy chủ đạt yêu cầu để cài đặt dịch vụ memcached"

#Vui lòng nhập địa chỉ ip của 2 máy web server vào dòng phía bên dưới Ví dụ B="192.168.1.1"

#B và C là địa chỉ ip của 2 máy web server

ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"

echo "Ip máy web server số 1 là $ip_web_server_1"
echo "Ip máy web server số 2 là $ip_web_server_2"

echo "Hãy chắc chắn rằng các địa chỉ ip trên của bạn là đúng"


echo "Tiến hành cài đặt"

bash setup_memcache.sh

echo "Tiến hành thiết lập firewall"

echo "Tạo zone mới mang tên dichvu"
firewall-cmd --permanent --new-zone=dichvu

echo "Thêm dịch vụ memcache" 
firewall-cmd --zone=dichvu --add-service=memcache --permanent 

echo "Thêm source vào zone dichvu cho máy có ip $ip_web_server_1"
firewall-cmd --zone=dichvu --add-source="$ip_web_server_1" --permanent

echo "Thêm source vào zone dichvu cho máy có ip $ip_web_server_2"
firewall-cmd --zone=dichvu --add-source="$ip_web_server_2" --permanent

echo "Reload lại tường lửa"
firewall-cmd --reload

echo "Kiểm tra các zones"
firewall-cmd --list-all-zones


exit 0