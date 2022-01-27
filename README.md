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
## Mail : phamductai123456@gmail.com

***
# Mục lục
[1. Giới thiệu mô hình](https://github.com/ductai124/Baitap_tonghop#1gi%E1%BB%9Bi-thi%E1%BB%87u-m%C3%B4-h%C3%ACnh)

[2. Tiến hành cài đặt](https://github.com/ductai124/Baitap_tonghop#2-ti%E1%BA%BFn-h%C3%A0nh-c%C3%A0i-%C4%91%E1%BA%B7t)

[3. Trường hợp các máy chủ memcached, mariadb, nfs cài đặt riêng lẻ](https://github.com/ductai124/Baitap_tonghop#3tr%C6%B0%E1%BB%9Dng-h%E1%BB%A3p-c%C3%A1c-m%C3%A1y-ch%E1%BB%A7-memcached-mariadb-nfs-c%C3%A0i-%C4%91%E1%BA%B7t-ri%C3%AAng-l%E1%BA%BB)

***
# 1.	Giới thiệu mô hình
* Trong quá trình xây dựng 1 hệ thống mô hình của chúng ta sẽ dần dần lớn lên và phát sinh ra đây là 1 mô hình đã được phát triển dần đàn theo nhu cầu sử dụng với các dịch vụ được tách biệt với nhau và sử dụng cân bằng tải giảm sự quá tải của hệ thống. Vì trong 1 hệ thống chỉ 1 máy chủ thì sẽ không chịu được số lượng truy cập ngày càng tăng vậy nên mô hình trên giúp phân tán các dịch vụ cho từng máy và cân bằng tải giúp giảm tải lượng truy cập phân chia lượng truy cập cho phù hợp
* Do giới hạn về mặt tài nguyên nên mô hình sẽ gồm:
    * Load balancing với IP là 192.168.1.20

    * Web server 1 với IP là: 192.168.1.21

    * Web server 2 với IP là: 192.168.1.22

    * Máy có IP là 192.168.1.23 sẽ đóng vai trò làm 3 máy
        * Mariadb (mysql)

        * NFS server

        * Memcached server
* *Lưu ý*: Mô hình thực tế thì 3 dịch vụ của máy 192.168.1.23 sẽ phải tách ra làm 3 máy chủ chứa dịch vụ tương ứng chứ không được đặt chung như vậy

# 2. Tiến hành cài đặt
* Đầu tiên sẽ tiến hành cài đặt 4 con máy ảo với IP tương tự như trên
* Việc đầu tiên ở tất cả các máy chúng ta sẽ tiến hành tắt SELINUX, unzip, telnet, git và reboot lại hệ thống
```php
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/sysconfig/selinux
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
yum -y install telnet git

reboot
```
## ***Sau đó ta sẽ tiến hành cài đặt bắt đầu từ  có ip 192.168.1.23 (máy chúa 3 dịch vụ mariadb, memcached và NFS server) đầu tiên***
```php
#Ta hãy sử dụng những file sau trên kho code, tải code từ kho code,  chúng ta dùng git để sử dụng và tiến hành cài đặt như sau 

 git clone https://github.com/ductai124/Baitap_tonghop.git

#Sau đó chúng ta tiếp tục cd vào thư mục như sau:

cd Baitap_tonghop-main/CODE/

#Sau đó ta ls để xem các file trong thu mực gồm những file gì
ls

#Truy cập vào file setup_server_all.sh tại ngay những dòng đầu tiên lần lượt nhập dải ip, ip web server 1 và ip web server 2 tương ứng ở trên

#Ví dụ như mô hình đang sử dụng thì chúng ta sẽ điền như sau

vi setup_mariadb_memcached_nfs.sh

ip_range="192.168.1.0"
ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"

# Sau đó ta tiến hành cài đặt
#Trong quá trình cài đặt sẽ có bước phải tự thiết lập mật khẩu và 1 số mục trong mariadb hãy để ý

#Phân quyền
chmod 755 setup_*

#Chạy tools cài đặt
bash setup_mariadb_memcached_nfs.sh


#Trên máy chủ
#Truy cập vào mysql
mysql -u root -p
#Tạo tài khoản mới để truy cập từ xa (ip ở đây là ip của máy web server)
create user 'tai123'@'%' identified by 'tai0837686717';

GRANT ALL PRIVILEGES ON *.* TO 'tai123'@'192.168.1.21' IDENTIFIED BY 'tai0837686717';

GRANT ALL PRIVILEGES ON *.* TO 'tai123'@'192.168.1.22' IDENTIFIED BY 'tai0837686717';

FLUSH PRIVILEGES;
#Hoặc sử dụng tài khoản root để truy cập từ xa (ip ở đây là ip của máy web server)

GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.1.21' IDENTIFIED BY 'tai0837686717' WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.1.22' IDENTIFIED BY 'tai0837686717' WITH GRANT OPTION;

FLUSH PRIVILEGES;

```
## ***Tiếp theo sẽ tiến hành cài đặt máy web server (IP:192.168.1.21 và IP: 192.168.1.22)***
```php
#Ta hãy sử dụng những file sau trên kho code, tải code từ kho code và chúng ta dùng git để sử dụng và tiến hành cài đặt như sau 

 git clone https://github.com/ductai124/Baitap_tonghop.git

#Sau đó chúng ta tiếp tục cd vào thư mục như sau:
cd Baitap_tonghop-main/CODE/

#Truy cập vào file setup_server_all.sh tại ngay những dòng đầu tiên lần lượt nhập dải ip, ip web server 1 và ip web server 2 tương ứng ở trên
#Web server có thể cài đặt cùng lúc và 2 web server cài đặt giống nhau nên sẽ sử dụng chung hướng dẫn này
#Trước khi cài đặt chúng ta có thể kiểm tra các cổng đã được thông từ bên phí máy server chưa
#Sau đó kiểm tra các cổng sau(ví dụ kiểm tra các cổng trên máy server có IP 192.168.1.23)

telnet 192.168.1.23 11211
telnet 192.168.1.23 3306
telnet 192.168.1.23 2049
telnet 192.168.1.23 20048

#Truy cập vào file setup_web_server.sh nhập ip của máy chủ NFS-Memcached-mariadb vào ngay những dòng đầu và chờ đợi cài đặt(đã có hướng dẫn và ví dụ trong file)

vi setup_web_server.sh
ip_server_nfs="192.168.1.23"

#Phân quyền 

chmod 755 setup_*

#Chạy tools cài đặt
bash setup_web_server.sh

```
## ***Cuối cùng là thiết lập cân bằng tải tại máy có ip là 192.168.1.20***
```php
#Ta hãy sử dụng những file sau trên kho code, tải code từ kho code và chúng ta dùng git để sử dụng và tiến hành cài đặt như sau 

 git clone https://github.com/ductai124/Baitap_tonghop.git

#Sau đó chúng ta tiếp tục cd vào thư mục như sau:

cd Baitap_tonghop-main/CODE/

#Truy cập vào file setup_server_all.sh tại ngay những dòng đầu tiên lần lượt nhập dải ip, ip web server 1 và ip web server 2 tương ứng ở trên
#Truy cập vào file setup_loadbalancing.sh tại những dòng đầu nhập ip của web server số 1  và web server số 2 tương ứng ở trên (đã có hướng dẫn trong file)

vi setup_loadbalancing.sh

ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"

#Phân quyền cho file

chmod 755 setup_*

#Chạy tools cài đặt

bash setup_loadbalancing.sh

```

# 3.	Trường hợp các máy chủ memcached, mariadb, nfs cài đặt riêng lẻ
## ***Đầu tiên chung ta tải code từ kho code về***
```php
##Ta hãy sử dụng những file sau trên kho code, tải code từ kho code và chúng ta dùng git để sử dụng và tiến hành cài đặt như sau 

 git clone https://github.com/ductai124/Baitap_tonghop.git

#Sau đó chúng ta tiếp tục cd vào thư mục như sau:

cd Baitap_tonghop-main/CODE/
```
## ***Đối với máy cần cài đặt mariadb***
```php
#Truy cập vào file setup_server_mariadb.sh tìm đến dòng sau và thay lần lượt ip web server 1 và ip web server 2 (đã có hướng dẫn trong file)

#Ví dụ như mô hình đang sử dụng là sẽ điền như sau

vi setup_server_mariadb.sh

ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"

#Phân quyền và cài đặt

chmod 755 setup_*
bash setup_server_mariadb.sh
```
## ***Đối với máy cần cài đặt memcached server***
```php
#Truy cập vào file setup_server_memcache.sh tìm đến dòng sau và thay lần lượt ip web server 1 và ip web server 2 tương ứng ở trên (đã có hướng dẫn trong file)

#Ví dụ như mô hình đang sử dụng là sẽ điền như sau

vi setup_server_memcache.sh

ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"

#Phân quyền và cài đặt

chmod 755 setup_*
bash setup_server_memcache.sh

```
## ***Đối với máy cần cài đặt nfs server***
```php
#Truy cập vào file setup_server_nfs.sh tìm đến dòng lần lượt nhập dải ip, ip web server 1 và ip web server 2 theo hướng dẫn có ghi trong file

#Ví dụ như mô hình đang sử dụng là sẽ điền như sau

vi setup_server_nfs.sh

ip_range="192.168.1.0"
ip_web_server_1="192.168.1.21"
ip_web_server_2="192.168.1.22"

#Phân quyền và cài đặt

chmod 755 setup_*
bash setup_server_nfs.sh

```