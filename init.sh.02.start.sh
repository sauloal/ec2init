#which services to start
echo "RUNNING START"

#APACHE
systemctl enable httpd.service
systemctl start  httpd.service
systemctl status httpd.service


