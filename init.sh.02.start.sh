#which services to start
echo "RUNNING START"

#APACHE
systemctl enable httpd.service
systemctl start  httpd.service
systemctl status httpd.service

#iSCSI
systemctl enable tgtd.service
systemctl start  tgtd.service
systemctl status tgtd.service

#SAMBA
#http://www.howtoforge.com/fedora-18-samba-standalone-server-with-tdbsam-backend
systemctl enable smb.service
systemctl start  smb.service
systemctl status smb.service

#NFS
#http://www.learnbydoingit.org/2013/01/configuring-nfs-server-on-fedora-18/
systemctl start  rpcbind.service
systemctl enable rpcbind.service
systemctl status rpcbind.service

systemctl start  nfs-server.service
systemctl enable nfs-server.service
systemctl status nfs-server.service

systemctl start  nfs-lock.service
systemctl enable nfs-lock.service
systemctl status nfs-lock.service

systemctl start  nfs-idmap.service
systemctl enable nfs-idmap.service
systemctl status nfs-idmap.service

#WEBMIN - CHANGE PASSWORD ASAP
#port 10000
/sbin/chkconfig webmin on
service webmin start
