#which services to start
echo "RUNNING START"
systemctl enable tgtd.service
systemctl start tgtd.service
systemctl status tgtd.service
