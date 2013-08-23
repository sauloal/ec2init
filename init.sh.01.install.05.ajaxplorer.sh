################
# ajax explorer
################
#http://ajaxplorer.info/documentation/administration/
#todo: setup folders
set -xeu

if [[ -z `yum list installed | grep ajaxplorer-release` ]]; then
	wget -O /tmp/ajax.rpm http://dl.ajaxplorer.info/repos/el6/ajaxplorer-stable/ajaxplorer-release-4-1.noarch.rpm
	yum install -y /tmp/ajax.rpm
else
	echo "ajax explorer release already installed"
fi

yum update -yt
yum install -yt ajaxplorer

#http://www.howtoforge.com/apc-php5-apache2-fedora8
yum install -yt php-pear php-devel httpd-devel

#RUN MANUALLY
#pecl install --soft --alldeps apc
echo "pecl install --soft --alldeps apc" >> RUNME.sh

#if [[ -z `grep apc.so /etc/php.d/apc.ini` ]]; then
	#vi /etc/php.d/apc.ini
	
#	echo -e "extension=apc.so\napc.enabled=1\napc.shm_size=30" >> /etc/php.d/apc.ini
#fi

cp -f --no-preserve=all mods/bootstrap_conf.php /etc/ajaxplorer/bootstrap_conf.php 
cp -f --no-preserve=all mods/ajaxplorer.conf /etc/httpd/conf.d/ajaxplorer.conf

sed -f mods/bootstrap_context.pgp.sed /etc/ajaxplorer/bootstrap_context.php > /tmp/b
mv /etc/ajaxplorer/bootstrap_context.php /etc/ajaxplorer/bootstrap_context.php.bkp
cp -f --no-preserve=all /tmp/b /etc/ajaxplorer/bootstrap_context.php

/bin/systemctl restart  httpd.service

