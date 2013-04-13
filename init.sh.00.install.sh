#what to install
echo "RUNNING INSTALL"
#misc
yum install -y wget
yum install -y byobu
yum install -y which
yum install -y nano
yum install -y cloud-utils
#apache
yum install -y httpd
#samba
yum install -y samba samba-client
#nfs
yum install -y nfs-utils
#vpn
yum install -y bridge-utils
yum install -y openvpn
#iscsi
yum install -y libiscsi-utils.i686 scsi-target-utils.i686 lsscsi.i686
