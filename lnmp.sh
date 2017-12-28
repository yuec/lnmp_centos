#!/bin/bash

#Nginx 版本号
NGINX_VERSION=1.9.9

#Maria DB 版本号
MARIA_DB_VERSION=10.2.11

#Maria DB 密码
MARIA_DB_PASSWORD="root"

#PHP 版本号
PHP_VERSION=7.2.0

#本机公网IP
HOST_PUBLIC_IP=$(curl ifconfig.me)
yum -y update 

echo -e "\n\e[01;36m
	Starting Install LNMP (Linux Nginx MariaDB PHP )\n
	
	Author : yuec \n 

	Email : sinyuec@163.com \n
	
	Target Nginx Version：：$NGINX_VERSION \n
	
	Target MariaDB Version：：$MARIA_DB_VERSION\n
	
	Target PHP Version：$PHP_VERSION\n
	
	Current System Version : $(cat /etc/redhat-release) \n
	
	Notice: This shell is written for centos or redhat releases
	
\033[0m\n"

sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

setenforce 0

groupadd -r nginx    
useradd -r -g nginx  nginx

wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz

tar xvf nginx-$NGINX_VERSION.tar.gz -C /usr/local/src

yum -y groupinstall "Development tools"

yum -y install gcc wget gcc-c++ automake autoconf libtool libxml2-devel libxslt-devel perl-devel perl-ExtUtils-Embed pcre-devel openssl-devel ncurses-devel

cd /usr/local/src/nginx-$NGINX_VERSION

./configure \
--prefix=/usr/local/nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/tmp/nginx/client \
--http-proxy-temp-path=/var/tmp/nginx/proxy \
--http-fastcgi-temp-path=/var/tmp/nginx/fcgi \
--http-uwsgi-temp-path=/var/tmp/nginx/uwsgi \
--http-scgi-temp-path=/var/tmp/nginx/scgi \
--user=nginx \
--group=nginx \
--with-pcre \
--with-http_v2_module \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-ipv6 \
--with-http_v2_module \
--with-threads \
--with-stream \
--with-stream_ssl_module

make && make install

mkdir -pv /var/tmp/nginx/client

echo '#!/bin/sh 
# 
# nginx - this script starts and stops the nginx daemon 
# 
# chkconfig:   - 85 15 
# description: Nginx is an HTTP(S) server, HTTP(S) reverse \ 
#               proxy and IMAP/POP3 proxy server 
# processname: nginx 
# config:      /etc/nginx/nginx.conf 
# config:      /etc/sysconfig/nginx 
# pidfile:     /var/run/nginx.pid 
# Source function library. 
. /etc/rc.d/init.d/functions
# Source networking configuration. 
. /etc/sysconfig/network
# Check that networking is up. 
[ "$NETWORKING" = "no" ] && exit 0
nginx="/usr/sbin/nginx"
prog=$(basename $nginx)
NGINX_CONF_FILE="/etc/nginx/nginx.conf"
[ -f /etc/sysconfig/nginx ] && . /etc/sysconfig/nginx
lockfile=/var/lock/subsys/nginx
start() {
    [ -x $nginx ] || exit 5
    [ -f $NGINX_CONF_FILE ] || exit 6
    echo -n $"Starting $prog: " 
    daemon $nginx -c $NGINX_CONF_FILE
    retval=$?
    echo 
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}
stop() {
    echo -n $"Stopping $prog: " 
    killproc $prog -QUIT
    retval=$?
    echo 
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
killall -9 nginx
}
restart() {
    configtest || return $?
    stop
    sleep 1
    start
}
reload() {
    configtest || return $?
    echo -n $"Reloading $prog: " 
    killproc $nginx -HUP
RETVAL=$?
    echo 
}
force_reload() {
    restart
}
configtest() {
$nginx -t -c $NGINX_CONF_FILE
}
rh_status() {
    status $prog
}
rh_status_q() {
    rh_status >/dev/null 2>&1
}
case "$1" in
    start)
        rh_status_q && exit 0
    $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart|configtest)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
            ;;
    *)
      echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}" 
        exit 2
esac
' > /etc/init.d/nginx

chmod +x /etc/init.d/nginx

chkconfig --add nginx
chkconfig  nginx on

service nginx start

echo -e "\n\e[01;36m
	You can try to visit you host by IP:  $HOST_PUBLIC_IP 
	\n
\033[0m\n"

echo -e "\n\e[01;36m
	Starting install MariaDB...
	\n
\033[0m\n"

yum groupinstall "Server Platform Development"  "Development tools" -y
yum install cmake -y


mkdir /mnt/data

groupadd -r mysql

useradd -r -g mysql -s /sbin/nologin mysql

id mysql

chown -R mysql:mysql /mnt/data

wget https://mirrors.tuna.tsinghua.edu.cn/mariadb//mariadb-$MARIA_DB_VERSION/source/mariadb-10.2.11.tar.gz

tar zxf mariadb-$MARIA_DB_VERSION.tar.gz -C /usr/local/src

cd /usr/local/src/mariadb-$MARIA_DB_VERSION
echo -e "\n\e[01;36m
	Starting Complining MariaDB...\n
	This may take a long time...
	\n
\033[0m\n"

cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/mnt/data \
-DSYSCONFDIR=/etc \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DWITH_SSL=system \
-DWITH_ZLIB=system \
-DWITH_LIBWRAP=0 \
-DMYSQL_TCP_PORT=3306 \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci
#todo
make && make install

chown -R mysql:mysql /usr/local/mysql/

cd  /usr/local/mysql/

scripts/mysql_install_db --user=mysql --datadir=/mnt/data/

cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld

chmod +x /etc/init.d/mysqld

cp -rf support-files/my-medium.cnf /etc/my.cnf

chkconfig mysqld  on 
chkconfig --add mysqld

mkdir -p /var/run/mysql/
mkdir -p /var/log/mysql/ 

chown mysql -R /var/run/mysql
chown mysql -R /var/log/mysql

echo -e "basedir = /usr/local/mysql\ndatadir = /mnt/data\n" >> /etc/my.cnf

echo "export PATH=$PATH:/usr/local/mysql/bin" > /etc/profile.d/mysql.sh 

source /etc/profile.d/mysql.sh

service mysqld start 

./bin/mysqladmin -u root password $MARIA_DB_PASSWORD

#mysql -h 127.0.0.1

echo -e "\n\e[01;36m
	Starting install PHP-FPM...
\033[0m\n"

yum install -y libmcrypt libmcrypt-devel mhash mhash-devel libxml2 libxml2-devel bzip2 bzip2-devel

wget http://cn2.php.net/distributions/php-$PHP_VERSION.tar.gz

tar xvf php-$PHP_VERSION.tar.gz -C /usr/local/src

cd /usr/local/src/php-$PHP_VERSION

./configure --prefix=/usr/local/php \
--with-config-file-scan-dir=/etc/php.d \
--with-config-file-path=/etc \
--with-mysql=/usr/local/mysql \
--with-mysqli=/usr/local/mysql/bin/mysql_config \
--enable-mbstring \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--with-openssl \
-enable-xml \
--enable-sockets \
--enable-fpm \
--with-mcrypt \
--with-bz2\
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-pdo-sqlite 

make && make install

cp /usr/local/src/php-$PHP_VERSION/php.ini-production /etc/php.ini

cd /usr/local/php/etc/

echo -e '\nexport PATH=/usr/local/php/bin:/usr/local/php/sbin:$PATH\n' >> /etc/profile && source /etc/profile

cp php-fpm.conf.default php-fpm.conf

sed -i 's@;pid = run/php-fpm.pid@pid = /usr/local/php/var/run/php-fpm.pid@' php-fpm.conf

cp /usr/local/src/php-$PHP_VERSION/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm

cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf

chmod +x /etc/init.d/php-fpm

chkconfig --add php-fpm   

chkconfig --list php-fpm 

chkconfig php-fpm on

service php-fpm start

cp /etc/nginx/nginx.conf /etc/nginx/nginx.confbak

cp /etc/nginx/nginx.conf.default /etc/nginx/nginx.conf

#mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

echo -e '#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

       location / {
            root   /usr/local/nginx/html;
            index  index.php index.html index.htm;
        }

       location ~ \.php$ {
            root           /usr/local/nginx/html;
            fastcgi_pass    127.0.0.1:9000;
            fastcgi_index   index.php;
            fastcgi_param  SCRIPT_FILENAME  /usr/local/nginx/html/$fastcgi_script_name;
            include        fastcgi_params;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apaches document root
        # concurs with nginxs one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

}


' > /etc/nginx/nginx.conf

service nginx reload
echo '<?php
$conn=mysqli_connect("127.0.0.1","root","'$MARIA_DB_PASSWORD'");' > /usr/local/nginx/html/index.php

echo '
if ($conn){
  echo "LNMP platform connect to mysql is successful!";
}else{
  echo "LNMP platform connect to mysql is failed!";
}
 phpinfo();
?>' >> /usr/local/nginx/html/index.php

chmod 777 /usr/local/nginx/html/index.php

echo -e "\n\e[01;36m
	Now , You can try to visit your host by IP：$HOST_PUBLIC_IP ,by this way, you will find  PHP and MYSQL are runing; 
	
	\n Bye Bye
\033[0m\n"







