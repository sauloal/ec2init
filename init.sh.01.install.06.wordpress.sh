################
# wordpress
################
#http://www.linuxforu.com/2011/07/wordpress-multi-site-servers-on-production-machines/
#http://www.if-not-true-then-false.com/2010/install-wordpress-on-fedora-centos-red-hat-rhel/
#http://fedoraproject.org/wiki/Features/ReplaceMySQLwithMariaDB

# REMOVE MYSQL
if [[ ! -z `yum list installed mysql-libs` ]]; then
	echo "uninstalling mysql"
	rpm -e --nodeps mysql mysql-libs
else
	echo "mysql not installed"
fi

yum install -y mariadb mariadb-server mariadb-libs mariadb-devel
yum install -y pwgen
yum install -y wordpress

systemctl restart mysqld.service


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


#yum install -y gallery2
#http://getgitorious.com/installer
#https://github.com/gitlabhq/gitlabhq#installation
#
#http://pythonhosted.org/RhodeCode/
#easy_install rhodecode
#
#https://github.com/sitaramc/gitolite
#
#https://github.com/res0nat0r/gitosis#readme
#zabbix

