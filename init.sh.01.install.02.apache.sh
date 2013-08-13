###############
#apache
###############
yum install -yt --skip-broken httpd

#APACHE
systemctl enable httpd.service
systemctl start  httpd.service
systemctl status httpd.service
