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


if [[ ! -z "$EC2_EXTERNAL_CONFIG_PRESENT" ]]; then

  echo "mounting wordpress to external"

  if [[ ! -e "$EC2_EXTERNAL_CONFIG_DST/wordpress" ]]; then
    mkdir -p $EC2_EXTERNAL_CONFIG_DST/wordpress
    chown -R apache:apache $EC2_EXTERNAL_CONFIG_DST/wordpress
    chmod 0774 $EC2_EXTERNAL_CONFIG_DST/wordpress
  fi


  if [[ -z `grep wordpress /etc/fstab` ]]; then
    echo "adding wordpress to fstab"
    echo "$EC2_EXTERNAL_CONFIG_DST/wordpress   /usr/share/wordpress        bind    bind    0" >> /etc/fstab
  else
    echo "wordpress already in fstab"
  fi


  if [[ -z `grep mysql /etc/fstab` ]]; then
    echo "adding mysql to fstab"
    echo "$EC2_EXTERNAL_CONFIG_DST/mysql   /var/lib/mysql        bind    bind    0" >> /etc/fstab
  else
    echo "mysql already in fstab"
  fi


  if [[ -z `mount | grep "wordpress"` ]]; then
    echo "mounting wordpress"
    mount --bind $EC2_EXTERNAL_CONFIG_DST/wordpress /usr/share/wordpress
    mount --make-shared /usr/share/wordpress
  else
    echo "wordpress already mounted"
  fi


  if [[ -z `mount | grep "mysql"` ]]; then
    echo "mounting mysql"
    mount --bind $EC2_EXTERNAL_CONFIG_DST/mysql /var/lib/mysql
    mount --make-shared /var/lib/mysql
  else
    echo "wordpress already mounted"
  fi


  echo "mounting wordpress to external done"
else
  echo "external not present. skipping mounting wordpress to external"
fi




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

