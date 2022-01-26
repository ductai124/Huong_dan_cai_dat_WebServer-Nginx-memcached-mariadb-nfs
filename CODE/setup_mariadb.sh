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
yum -y install wget
yum -y install unzip
yum -y install tar
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y


echo "Chỉnh sửa lại repo của mariadb về server Việt Nam đường dẫn file repo là /etc/yum.repos.d/MariaDB.repo"
echo "[mariadb]" >> /etc/yum.repos.d/MariaDB.repo
echo "name = MariaDB" >> /etc/yum.repos.d/MariaDB.repo
echo "baseurl = https://mirrors.bkns.vn/mariadb/yum/10.3/rhel8-amd64" >> /etc/yum.repos.d/MariaDB.repo
echo "module_hotfixes=1" >> /etc/yum.repos.d/MariaDB.repo
echo "gpgkey=https://mirrors.bkns.vn/mariadb/yum/RPM-GPG-KEY-MariaDB" >> /etc/yum.repos.d/MariaDB.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/MariaDB.repo

echo "Cài đặt mariadb"
#dnf module -y install mariadb:10.3

dnf install -y MariaDB-server

echo "Khởi động mariadb"
systemctl enable --now mariadb
systemctl start mariadb
echo "Vui lòng nhập thiết mật khẩu và các thiết lập của mariadb"
mysql_secure_installation

echo "Cài đặt mariadb hoàn thành"

exit 0