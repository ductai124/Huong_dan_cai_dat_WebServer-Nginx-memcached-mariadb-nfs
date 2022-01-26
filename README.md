<!--
# h1
## h2
### h3
#### h4
##### h5
###### h6

*in nghiêng*

**bôi đậm**

***vừa in nghiêng vừa bôi đậm***

`inlide code`

```php

echo ("highlight code");

```

[Link test](https://viblo.asia/helps/cach-su-dung-markdown-bxjvZYnwkJZ)

![markdown](https://images.viblo.asia/518eea86-f0bd-45c9-bf38-d5cb119e947d.png)

* mục 3
* mục 2
* mục 1

1. item 1
2. item 2
3. item 3

***
horizonal rules

> text

{@youtube: https://www.youtube.com/watch?v=HndN6P9ke6U}
* Cài đặt nginx bằng câu lệnh sau
```php
dnf -y install nginx
```
*	Cấu hình nginx như sau
```php
vi /etc/nginx/nginx.conf

 Server{
     ...
     server_name www.srv.world;
     ...
 }
 
-->

# TÀI LIỆU HƯỚNG DẪN CÀI ĐĂT 1 MÔ HÌNH HỆ THỐNG CƠ BẢN 
## Người viết : Phạm Đức Tài
## SDT : 0837686717
## Mail : phamductai12345678

***
# Mục lục
[1. Giới thiệu mô hình](https://github.com/ductai124/Baitap_tonghop#1gi%E1%BB%9Bi-thi%E1%BB%87u-m%C3%B4-h%C3%ACnh)

[2. Tiến hành cài đặt](https://github.com/ductai124/Baitap_tonghop#2ti%E1%BA%BFn-h%C3%A0nh-c%C3%A0i-%C4%91%E1%BA%B7t)

[3. Xử lý trong trường hợp phát sinh thêm server web]()

***
## 1.	Giới thiệu mô hình
* Do giới hạn về mặt tài nguyên nên mô hình sẽ gồm:
    * Load balancing 192.168.1.20

    * Web server 1: 192.168.1.21

    * Web server 2: 192.168.1.22

    * Mấy 192.168.1.23 sẽ đóng vai trò làm 3 máy
        * Mariadb(mysql)

        * NFS server

        * memcached server
## 2.	Tiến hành cài đặt
* Đầu tiên sẽ tiến hành cài đặt 4 con máy ảo với ip tương tự như trên
* Việc đầu tiên ở tất cả các máy chúng ta sẽ tiến hành tắt SELINUX và reboot lại hệ thống
```php
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/sysconfig/selinux
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
reboot
```
* Sau đó ta sẽ tiến hành cài đặt bắt đầu từ máy 192.168.1.23 đầu tiên
* Ta hãy sử dụng những file sau trên kho code 
```php
#Copy Code của các file code sau hoặc tải các file code sau về và để chúng tại thư mục root
#Xóa đuổi txt đi hoặc vào trong file setup_server_mariadb_nfs_memcache.txt thêm đuôi txt cho các file bash đề phòng không chay được
setup_NFS.txt
setup_mariadb.txt
setup_memcache.txt
setup_server_mariadb_nfs_memcache.txt
firewall_setup.txt

# Sau đó ta tiến hành cài đặt
chmod 755 setup_*
chmod 755 firewall_setup

bash setup_server_mariadb_nfs_memcache
#Lưu ý code sẽ không tự động toàn bộ quá trình mà sẽ dừng lại để người dùng nhập 1 số thông tin cần thiết ví dụ như sau
#Nhập dải để cho sử dụng cho máy chủ NFS
#Tự thiết lập mật khẩu và 1 số mục trong mariadb
#Nhập ip để kích hoạt tường lửa mở khóa dịch vụ cho 2 máy web server
#việc làm này khiến cho chúng ta có thể dễ dàng cài đặt trên các mô hình tương đương nhưng có dải ip khác với mô hình mà đang dự kiến sử dụng
#Khi quá trình cài đặt đã hoàn thành hãy kiểm tra lại xem có phần nào bị lỗi không

```
* Tiếp theo sẽ tiến hành cài đặt máy web server
```php
#Sử dụng file code 
setup_web_server.txt

#Phân quyền 
chmod 755 setup_web_server
bash setup_web_server

#Nhập ip của máy chủ NFS-Memcached-mariadb và chờ đợi cài đặt
#sau khi cài đặt thành công ta sẽ kiểm tra các cổng bằng cách cài đặt telnet
yum install -y telnet

#sau đó kiểm tra các cổng sau
telnet 192.168.1.23 11211

telnet 192.168.1.23 3306

telnet 192.168.1.23 2049

telnet 192.168.1.23 20048

#Riêng cổng 3306 thì kết nối vào là đóng luôn do chưa thiết lập tài khoản kết nối từ xa vấn đề này ta sẽ quay lại máy chủ chứ mariadb và tạo tài khoản cho phép truy cập từ xa

#Trên máy chủ
#truy cập vào mysql
mysql -u root -p
#Tạo tài khoản mới để truy cập từ xa
create user 'tai123'@'%' identified by 'tai0837686717';

GRANT ALL PRIVILEGES ON *.* TO 'tai123'@'192.168.1.21' IDENTIFIED BY 'tai0837686717';

GRANT ALL PRIVILEGES ON *.* TO 'tai123'@'192.168.1.22' IDENTIFIED BY 'tai0837686717';

FLUSH PRIVILEGES;
#Hoặc sử dụng tài khoản root để truy cập từ xa

GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.1.21' IDENTIFIED BY 'tai0837686717' WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.1.22' IDENTIFIED BY 'tai0837686717' WITH GRANT OPTION;

FLUSH PRIVILEGES;

#Sau đó quay lại bên web server thì telnet sẽ kết nối bình thường

```
* Cuối cùng là thiết lập cân bằng tải tại máy 192.168.1.20
```php
#Sử dụng file code 
setup_loadbalancing.txt

#Phân quyền cho file
chmod 755 setup_loadbalancing

#Chạy tools cài đặt
bash setup_loadbalancing

#Nhập ip của web server số 1 và web server số 2 sau đó chờ đợi
```

* Trường hợp muốn tách thêm 1 máy chủ web nữa ta sẽ xử lý như sau
```php
```