#which services to start
echo "RUNNING START"

systemctl enable httpd.service
systemctl start  httpd.service
systemctl status httpd.service

systemctl enable tgtd.service
systemctl start  tgtd.service
systemctl status tgtd.service

#port 10000
/sbin/chkconfig webmin on
service start webmin
