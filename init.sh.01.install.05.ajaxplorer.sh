################
# ajax explorer
################
#http://ajaxplorer.info/documentation/administration/
#todo: setup folders
set -xeu

rpm -Uvh http://dl.ajaxplorer.info/repos/el6/ajaxplorer-stable/ajaxplorer-release-4-1.noarch.rpm


yum update -y
yum install -y ajaxplorer

cp -f --no-preserve=all mods/bootstrap_conf.php /etc/ajaxplorer/bootstrap_conf.php 
cp -f --no-preserve=all mods/ajaxplorer.conf /etc/httpd/conf.d/ajaxplorer.conf

/bin/systemctl restart  httpd.service


#yum install -y gallery2
#yum install -y wordpress
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
