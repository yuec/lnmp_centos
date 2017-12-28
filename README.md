# lnmp
## Notice : This shell is written for centos or redhat releases

# This shell use the default config files (nginx,mysql and php),so you should reedit these config files if you want a greater or balance performance.

guide:

1. download this shell file

2. edit config options:

      #Nginx 版本号
      NGINX_VERSION=1.9.9

      #Maria DB 版本号
      MARIA_DB_VERSION=10.2.11

      #Maria DB 默认密码
      MARIA_DB_PASSWORD="root"

      #PHP 版本号
      PHP_VERSION=7.2.0

3. chmod +x lnmp.sh

4. sudo ./lnmp.sh

then ,enjoy the lnmp ;)


# /etc/php.ini配置
######避免PHP信息暴露在http头中
expose_php = Off

######避免暴露php调用mysql的错误信息
display_errors = Off

######在关闭display_errors后开启PHP错误日志（路径在php-fpm.conf中配置）
log_errors = On

######设置PHP的时区
date.timezone = PRC

# /usr/local/php/etc/php-fpm.conf 配置
######设置错误日志的路径
error_log = /var/log/php-fpm/error.log
######引入www.conf文件中的配置
include=/usr/local/php7/etc/php-fpm.d/*.conf

# /usr/local/php/etc/php-fpm.d/www.conf 配置
######设置用户和用户组
user = nginx
group = nginx





