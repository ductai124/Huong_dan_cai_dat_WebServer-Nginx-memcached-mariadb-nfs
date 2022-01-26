#! /bin/bash
if systemctl is-active --quiet nfs-*; then
    echo "NFS Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi

echo "Máy chủ đạt yêu cầu để cài đặt dịch vụ nfs"
#Vui lòng nhập dải ip vào dòng phía bên dưới ví dụ A="192.168.1.0"
#Vui lòng nhập địa chỉ ip của 2 máy web server vào dòng phía bên dưới Ví dụ B="192.168.1.1"
#Ta có A là dải ip
#B và C là địa chỉ ip của 2 máy web server
A="192.168.1.0"
B="192.168.1.21"
C="192.168.1.22"
#Vui lòng nhập địa chỉ ip của 2 máy web server vào dòng phía bên dưới Ví dụ B = "192.168.1.1


echo "Dải ip của bạn nhập là $A"

echo "Hãy chắc chắn rằng dải ip trên của bạn là đúng"

bash setup_NFS $A

echo "Tiến hành thiết lập firewall"

echo "Tạo zone mới mang tên dichvu"
firewall-cmd --permanent --new-zone=dichvu

echo "Thêm dịch vụ nfs"  
firewall-cmd --zone=dichvu --add-service=nfs --permanent 

echo "Thêm dịch vụ nfs3, mountd và rpc-bind"  
firewall-cmd --zone=dichvu --add-service={nfs3,mountd,rpc-bind} --permanent

echo "Thêm source vào zone dichvu cho máy có ip $B"
firewall-cmd --zone=dichvu --add-source="$B" --permanent

echo "Thêm source vào zone dichvu cho máy có ip $C"
firewall-cmd --zone=dichvu --add-source="$C" --permanent


echo "Reload lại tường lửa"
firewall-cmd --reload

echo "Kiểm tra các zones"
firewall-cmd --list-all-zones

exit 0