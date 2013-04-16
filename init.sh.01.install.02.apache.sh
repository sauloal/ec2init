###############
#apache
###############
yum install -y httpd

#APACHE
systemctl enable httpd.service
systemctl start  httpd.service
systemctl status httpd.service
