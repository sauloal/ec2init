rpm -Uvh http://dl.ajaxplorer.info/repos/el6/ajaxplorer-stable/ajaxplorer-release-4-1.noarch.rpm


yum update -y
yum install -y ajaxplorer

cp -f --no-preserve=all mods/bootstrap_conf.php /etc/ajaxplorer/bootstrap_conf.php 
cp -f --no-preserve=all mods/ajaxplorer.conf /etc/httpd/conf.d/ajaxplorer.conf

/bin/systemctl restart  httpd.service
