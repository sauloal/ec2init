###############
#apache
###############
set +xeu
yum install -yt --skip-broken httpd
yum install -yt --skip-broken httpd
yum install -yt --skip-broken httpd


#APACHE
systemctl enable httpd.service
systemctl start  httpd.service
systemctl status httpd.service

set -xeu
