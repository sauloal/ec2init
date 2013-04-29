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

yum update -y
yum install -y ajaxplorer

cp -f --no-preserve=all mods/bootstrap_conf.php /etc/ajaxplorer/bootstrap_conf.php 
cp -f --no-preserve=all mods/ajaxplorer.conf /etc/httpd/conf.d/ajaxplorer.conf

/bin/systemctl restart  httpd.service

