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
***
# TÀI LIỆU HƯỚNG DẪN CÀI ĐĂT 1 MÔ HÌNH HỆ THỐNG CƠ BẢN 
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

setup_NFS.txt
setup_mariadb.txt
setup_memcache.txt
setup_server_mariadb_nfs_memcache.txt
firewall_setup.txt

# Sau đó ta tiến hành cài đặt
```