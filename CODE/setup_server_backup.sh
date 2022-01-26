#! /bin/bash
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

#Vui lòng nhập dải ip vào dòng phía bên dưới ví dụ A="192.168.1.0"
#Vui lòng nhập địa chỉ ip của 2 máy web server vào dòng phía bên dưới Ví dụ B="192.168.1.1"
#Ta có A là dải ip
#B và C là địa chỉ ip của 2 máy web server
A="192.168.1.0"
B="192.168.1.21"
C="192.168.1.22"
#Vui lòng nhập địa chỉ ip của 2 máy web server vào dòng phía bên dưới Ví dụ B = "192.168.1.1



echo "Dải ip của bạn nhập là $A"
echo "Ip máy web server số 1 là $B"
echo "Ip máy web server số 2 là $C"

echo "Hãy chắc chắn rằng các địa chỉ ip trên của bạn là đúng"
echo "Hãy xác nhận lại nếu địa chỉ ip của bạn là đúng hay bấm (Y) để tiếp tục không hay bấm (N)"	
read D


if [ "$D" == "Y" ]
then

echo "Tiến hành cài đặt"

bash setup_mariadb
bash setup_memcache

echo "Dải ip được cấp cho NFS là là : $A"

bash setup_NFS $A

echo "Thiết lập firewall"

bash firewall_setup $B $C

else
	if [ "$D" == "N" ]
	then 
	echo "Bạn có muốn dừng hẳn quá trình cài đặt lại không hay chỉ muốn sửa lại địa chỉ ip và dải ip mà thôi ?"
	echo "Nhập (Y) để chỉnh sửa ip và dải ip hoặc Nhập bất kỳ để thoát chương trình"
	read E
		if [ "$E" == "Y" ]
		then
		vi setup_server_mariadb_nfs_memcache.sh
		echo "IP và dải ip đã được thay đổi"
		bash setup_server_mariadb_nfs_memcache.sh
		else
		echo "Tắt file cài đặt quá trình cài đặt sẽ không được diễn ra"
		fi
	fi
fi





exit 0