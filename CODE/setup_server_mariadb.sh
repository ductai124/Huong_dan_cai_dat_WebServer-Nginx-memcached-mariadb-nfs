#! /bin/bash
if systemctl is-active --quiet mariadb; then
    echo "Mysql Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi
if systemctl is-active --quiet mysql; then
    echo "Mysql Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi

echo "Update và upgrade và cài Wget, unzip, tar, epel, remi"
dnf upgrade --refresh -y
dnf update -y
yum -y install wget unzip tar
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

echo "Máy chủ đạt yêu cầu để cài đặt dịch vụ mariadb"
#Vui lòng nhập địa chỉ ip của 2 máy web server vào dòng phía bên dưới Ví dụ ip_web_server_1="192.168.1.21"

ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"

echo "Ip máy web server số 1 là $ip_web_server_1"
echo "Ip máy web server số 2 là $ip_web_server_2"

echo "Hãy chắc chắn rằng các địa chỉ ip trên của bạn là đúng"

echo "Tiến hành cài đặt"

bash setup_mariadb.sh

echo "Tiến hành thiết lập firewall"

echo "Tạo zone mới mang tên dichvu"
firewall-cmd --permanent --new-zone=dichvu

echo "Thêm dịch vụ mysql"
firewall-cmd --zone=dichvu --add-service=mysql --permanent 

echo "Thêm source vào zone dichvu cho máy có ip $ip_web_server_1"
firewall-cmd --zone=dichvu --add-source="$ip_web_server_1" --permanent

echo "Thêm source vào zone dichvu cho máy có ip $ip_web_server_2"
firewall-cmd --zone=dichvu --add-source="$ip_web_server_2" --permanent

echo "Reload lại tường lửa"
firewall-cmd --reload

echo "Kiểm tra các zones"
firewall-cmd --list-all-zones

exit 0