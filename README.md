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

[3. Trường hợp các máy chủ memcached, mariadb, nfs cài đặt riêng lẻ](https://github.com/ductai124/Baitap_tonghop#3tr%C6%B0%E1%BB%9Dng-h%E1%BB%A3p-c%C3%A1c-m%C3%A1y-ch%E1%BB%A7-memcached-mariadb-nfs-c%C3%A0i-%C4%91%E1%BA%B7t-ri%C3%AAng-l%E1%BA%BB)

***
# 1.	Giới thiệu mô hình
* Trong quá trình xây dựng 1 hệ thống mô hình của chúng ta sẽ dần dần lớn lên và phát sinh ra đây là 1 mô hình đã được phát triển dần đàn theo nhu cầu sử dụng với các dịch vụ được tách biệt với nhau và sử dụng cân bằng tải giảm sự quá tải của hệ thống
* Do giới hạn về mặt tài nguyên nên mô hình sẽ gồm:
    * Load balancing với ip là 192.168.1.20

    * Web server 1 với ip là: 192.168.1.21

    * Web server 2 với ip là: 192.168.1.22

    * Mấy có ip là 192.168.1.23 sẽ đóng vai trò làm 3 máy
        * Mariadb(mysql)

        * NFS server

        * Memcached server
* Mô tả:
    * Ban đầu có 1 **máy chủ web số 1: 192.168.1.21** và chưa cần sử dụng **memcached và nfs server** sau 1 thời gian đi vào hoạt động máy chủ đã không thể chịu nổi lượng truy cập lớn ngày càng tăng của người dùng từ đó thì ta cần tách dịch vụ.
    * Thậm chí máy 1 có thể đóng luôn cả vai trò là mariadb cũng được hoặc sẽ có thêm 1 máy là **máy có ip là 192.168.1.23 đóng vai trò chứa dịch vụ mariadb**
    * Do nhu cầu truy cập cao và 1 máy chủ không thể tải hết được ta sẽ phát sinh ra phải tạo thêm **1 máy chủ chứa nfs server ,mariadb và memcached**, **1 con máy web server** nữa và **1 con cân bằng tải*. Từ đó sẽ thiết lập thêm 2 máy
    * Các máy phát sinh sẽ là
    * Mấy có ip là 192.168.1.23 sẽ đóng vai trò làm 3 máy (trong thực tế các dịch vụ sẽ phải để riêng)
        * Mariadb(mysql)(nếu đã được tách dịch vụ từ đầu thì vẫn là máy cũ)
        * NFS server(Phát sinh thêm do có thêm 1 con web server)
        * Memcached server(phát sinh thêm do có thêm 1 con web server)
    * Máy chủ nginx đóng vài trò là máy cân bằng tải: 192.168.1.20
    * Máy chủ nginx số 2: 192.168.1.22

# 2.	Tiến hành cài đặt
* ***Lưu ý*** : **Mô hình này sẽ được cài đặt từ những OS mới tinh chưa được cài đặt các dịch vụ gì vậy nên hãy kiểm tra kỹ OS xem liệu đã có cài đặt các dịch vụ gì trước trùng với các dịch vụ của mô hình không nếu đã có thì sẽ không thực hiện được cài đặt do không thể kiểm soát được những gì đã được cài đặt từ trước**
* Đầu tiên sẽ tiến hành cài đặt 4 con máy ảo với ip tương tự như trên
* Việc đầu tiên ở tất cả các máy chúng ta sẽ tiến hành tắt SELINUX và reboot lại hệ thống
```php
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/sysconfig/selinux
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
reboot
```
## ***Sau đó ta sẽ tiến hành cài đặt bắt đầu từ máy 192.168.1.23(máy chúa 3 dịch vụ mariadb, memcached và NFS server) đầu tiên***
* Ta hãy sử dụng những file sau trên kho code 
```php
#Tải code từ kho code về
có thể dùng git hoặc unzip

cd baitap_tonghop/CODE
#Những file cần sử dụng

#Truy cập vào file setup_server_all.sh tại ngay những dòng đầu tiên lần lượt nhập dải ip, ip web server 1 và ip web server 2
#Ví dụ như mô hình đang sử dụng là sẽ điền như sau
vi setup_mariadb_memcached_nfs.sh

ip_range="192.168.1.0"
ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"

# Sau đó ta tiến hành cài đặt
chmod 755 setup_*


bash setup_mariadb_memcached_nfs.sh


#Tự thiết lập mật khẩu và 1 số mục trong mariadb

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

```
## ***Tiếp theo sẽ tiến hành cài đặt máy web server(192.168.1.21 và 192.168.1.22)***
```php
#Web server có thể cài đặt cùng lúc và 2 web server cài đặt giống nhau nên sẽ sử dụng chung hướng dẫn này
#Trước khi cài đặt chúng ta có thể kiểm tra các cổng đã được thông từ bên phí máy server chưa
yum install -y telnet
#sau đó kiểm tra các cổng sau(ví dụ kiểm tra các cổng trên máy server có ip 192.168.1.23)
telnet 192.168.1.23 11211
telnet 192.168.1.23 3306
telnet 192.168.1.23 2049
telnet 192.168.1.23 20048

#Sử dụng file code 
setup_web_server.sh

#Truy cập vào file setup_web_server.sh nhập ip của máy chủ NFS-Memcached-mariadb vào ngay những dòng đầu và chờ đợi cài đặt(đã có hướng dẫn và ví dụ trong file)
vi setup_web_server.sh

ip_server_nfs="192.168.1.23"

#Phân quyền 
chmod 755 setup_web_server.sh
bash setup_web_server.sh



```
## ***Cuối cùng là thiết lập cân bằng tải tại máy có ip là 192.168.1.20***
```php
#Tải code tại kho code
#Sử dụng file code 
setup_loadbalancing.sh

#truy cập vào file setup_loadbalancing.sh tại những dòng đầu nhập ip của web server số 1 và web server số 2 (đã có hướng dẫn trong file)
vi setup_loadbalancing.sh

ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"
#Phân quyền cho file
chmod 755 setup_loadbalancing.sh

#Chạy tools cài đặt
bash setup_loadbalancing.sh


```

# 3.	Trường hợp các máy chủ memcached, mariadb, nfs cài đặt riêng lẻ
## ***Cài đặt mariadb***
```php
#Cài đặt mariadb bằng 2 file
setup_server_mariadb.sh
setup_mariadb.sh
#Truy cập vào file setup_server_mariadb.sh tìm đến dòng sau và thay lần lượt ip web server 1 và ip web server 2(đã có hướng dẫn trong file)
#Ví dụ như mô hình đang sử dụng là sẽ điền như sau

vi setup_server_mariadb.sh

ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"

#Phân quyền và cài đặt
chmod 755 setup_server_mariadb.sh

bash setup_server_mariadb.sh
```
## ***Cài đặt memcached server***
```php
#Cài đặt memcached bằng 2 file
setup_server_memcache.sh
setup_memcache.sh
#Truy cập vào file setup_server_memcache.sh tìm đến dòng sau và thay lần lượt ip web server 1 và ip web server 2 (đã có hướng dẫn trong file)
#Ví dụ như mô hình đang sử dụng là sẽ điền như sau

vi setup_server_memcache.sh

ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"

#Phân quyền và cài đặt
chmod 755 setup_server_memcache.sh

bash setup_server_memcache.sh
```
## ***Cài đặt nfs server***
```php
#Cài đặt nfs bằng 2 file
setup_server_nfs.sh
setup_NFS.sh
#Truy cập vào file setup_server_nfs.sh tìm đến dòng lần lượt nhập dải ip, ip web server 1 và ip web server 2 theo hướng dẫn có ghi trong file
#Ví dụ như mô hình đang sử dụng là sẽ điền như sau

vi setup_server_nfs.sh

ip_range="192.168.1.0"
ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"

#Phân quyền và cài đặt
chmod 755 setup_server_nfs.sh

bash setup_server_nfs.sh

```