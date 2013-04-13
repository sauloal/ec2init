#which services to start
echo "RUNNING START"

/sbin/chkconfig httpd on
/sbin/service httpd start

systemctl enable tgtd.service
systemctl start tgtd.service
systemctl status tgtd.service
