#! /bin/bash

#Vui lòng nhập địa chỉ ip của 2 máy web server vào dòng phía bên dưới 
#Ví dụ ip_web_server_1="192.168.1.1"
ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"

if systemctl is-active --quiet nginx; then
    echo "Nginx Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi

echo "Máy tính đã đủ yêu cầu để cài đặt"

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
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y


echo "INSTALL nginx" 
dnf -y install nginx
echo "config nginx Loadbalancing"

cp /etc/nginx/nginx.conf /etc/nginx/nginx_backup_config

#echo "xóa từ dòng 37 đến cuối để tạo sau đó thiết lập như sau để thành cân bằng tải"
echo "Config nginx"
sed -i '37,$d' /etc/nginx/nginx.conf
echo -e "\t upstream backend {" >> /etc/nginx/nginx.conf
echo -e "\t\t least_conn;" >> /etc/nginx/nginx.conf
echo -e "\t\t server $ip_web_server_1 max_fails=3 fail_timeout=30 weight=2;" >> /etc/nginx/nginx.conf
echo -e "\t\t server $ip_web_server_2 max_fails=3 fail_timeout=30 weight=2;" >> /etc/nginx/nginx.conf
echo -e "\t}" >> /etc/nginx/nginx.conf

echo -e "\t server {" >> /etc/nginx/nginx.conf
echo -e "\t\t listen 80;" >> /etc/nginx/nginx.conf
echo -e "" >> /etc/nginx/nginx.conf
echo -e "\t\t location / {" >> /etc/nginx/nginx.conf
echo -e "\t\t proxy_next_upstream http_404;" >> /etc/nginx/nginx.conf
echo -e "\t\t proxy_pass http://backend;" >> /etc/nginx/nginx.conf
echo -e "\t\t }" >> /etc/nginx/nginx.conf
echo -e "\t }" >> /etc/nginx/nginx.conf
echo -e "}" >> /etc/nginx/nginx.conf


systemctl enable --now nginx
systemctl status nginx

echo "Thiết lập tường lửa"
firewall-cmd --add-service=http
firewall-cmd --runtime-to-permanent

exit 0