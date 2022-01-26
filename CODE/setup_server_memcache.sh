#! /bin/bash
if systemctl is-active --quiet memcached; then
    echo "Memcached Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi

echo "Máy chủ đạt yêu cầu để cài đặt dịch vụ memcached"

#Vui lòng nhập địa chỉ ip của 2 máy web server vào dòng phía bên dưới Ví dụ B="192.168.1.1"

#B và C là địa chỉ ip của 2 máy web server

B="192.168.1.21"
C="192.168.1.22"

echo "Ip máy web server số 1 là $B"
echo "Ip máy web server số 2 là $C"

echo "Hãy chắc chắn rằng các địa chỉ ip trên của bạn là đúng"


echo "Tiến hành cài đặt"

bash setup_memcache

echo "Tiến hành thiết lập firewall"

echo "Tạo zone mới mang tên dichvu"
firewall-cmd --permanent --new-zone=dichvu

echo "Thêm dịch vụ memcache" 
firewall-cmd --zone=dichvu --add-service=memcache --permanent 

echo "Thêm source vào zone dichvu cho máy có ip $B"
firewall-cmd --zone=dichvu --add-source="$B" --permanent

echo "Thêm source vào zone dichvu cho máy có ip $C"
firewall-cmd --zone=dichvu --add-source="$C" --permanent

echo "Reload lại tường lửa"
firewall-cmd --reload

echo "Kiểm tra các zones"
firewall-cmd --list-all-zones


exit 0