#what to install
echo "RUNNING INSTALL"

#misc
yum install -y wget
yum install -y byobu
yum install -y which
yum install -y nano
yum install -y htop
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

#management
wget -O /tmp/webmin-1.620-1.noarch.rpm 'http://downloads.sourceforge.net/project/webadmin/webmin/1.620/webmin-1.620-1.noarch.rpm?r=http%3A%2F%2Fwww.webmin.com%2Fdownload.html&ts=1365823599&use_mirror=surfnet'
yum install -y /tmp/webmin-1.620-1.noarch.rpm
rm -f /tmp/webmin-1.620-1.noarch.rpm
#http://prdownloads.sourceforge.net/webadmin/webmin-1.620-1.noarch.rpm

#TODO
#git clone https://github.com/bobsta63/zpanelx.git zpanelx
