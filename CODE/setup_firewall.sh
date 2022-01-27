#! /bin/bash

echo "Tiến hành thiết lập firewall"

echo "Tạo zone mới mang tên dichvu"
firewall-cmd --permanent --new-zone=dichvu

echo "Thêm dịch vụ mysql"
firewall-cmd --zone=dichvu --add-service=mysql --permanent 

echo "Thêm dịch vụ memcache" 
firewall-cmd --zone=dichvu --add-service=memcache --permanent 

echo "Thêm dịch vụ nfs"  
firewall-cmd --zone=dichvu --add-service=nfs --permanent 

echo "Thêm dịch vụ nfs3, mountd và rpc-bind"  
firewall-cmd --zone=dichvu --add-service={nfs3,mountd,rpc-bind} --permanent

echo "Thêm source vào zone dichvu cho máy có ip $1"
firewall-cmd --zone=dichvu --add-source="$1" --permanent

echo "Thêm source vào zone dichvu cho máy có ip $2"
firewall-cmd --zone=dichvu --add-source="$2" --permanent

echo "Reload lại tường lửa"
firewall-cmd --reload

echo "Kiểm tra các zones"
firewall-cmd --list-all-zones


echo "Hoàn tất thiết lập Firewall"

exit 0