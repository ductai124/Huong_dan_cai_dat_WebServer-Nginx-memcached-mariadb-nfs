#! /bin/bash
source /root/Baitap_tonghop-main/CODE/setup.conf.sh

if systemctl is-active --quiet nfs-*; then
    echo "NFS Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi

echo "Máy chủ đạt yêu cầu để cài đặt dịch vụ nfs"

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




echo "Dải ip của bạn nhập là $ip_range"

echo "Hãy chắc chắn rằng dải ip trên của bạn là đúng"

bash setup_NFS.sh $ip_range

echo "Tiến hành thiết lập firewall"

echo "Tạo zone mới mang tên dichvu"
firewall-cmd --permanent --new-zone=dichvu

echo "Thêm dịch vụ nfs"  
firewall-cmd --zone=dichvu --add-service=nfs --permanent 

echo "Thêm dịch vụ nfs3, mountd và rpc-bind"  
firewall-cmd --zone=dichvu --add-service={nfs3,mountd,rpc-bind} --permanent

echo "Thêm source vào zone dichvu cho máy có ip $ip_web_server_1"
firewall-cmd --zone=dichvu --add-source="$ip_web_server_1" --permanent

echo "Thêm source vào zone dichvu cho máy có ip $ip_web_server_2"
firewall-cmd --zone=dichvu --add-source="$ip_web_server_2" --permanent


echo "Reload lại tường lửa"
firewall-cmd --reload

echo "Kiểm tra các zones"
firewall-cmd --list-all-zones

exit 0