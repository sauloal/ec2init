################
# wordpress
################
#http://www.linuxforu.com/2011/07/wordpress-multi-site-servers-on-production-machines/
#http://www.if-not-true-then-false.com/2010/install-wordpress-on-fedora-centos-red-hat-rhel/

# REMOVE MYSQL
#yum install -y mariadb mariadb-server
#yum install -y pwgen

#systemctl restart mysqld.service


# CHANGE PASSWORD PROGRAMATICALLY
#mysqladmin -u root password


#/etc/wordpress/wp-config.php
# GIVE PASSWORD PROGRAMATICALLY
# REPLACE ALL VARIABLES
#mysql -h localhost -u root -p < mods/wp-config.php.sql
#/var/lib/mysql

mount --bind /mnt/external/mysql     /var/lib/mysql 
mount --bind /mnt/external/wordpress /usr/share/wordpress

# REPLACE ALL VARIABLES
#cp  -f --no-preserve=all mods/wp-config.php.new /etc/wordpress/wp-config.php
