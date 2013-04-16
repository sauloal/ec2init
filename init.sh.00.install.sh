#what to install
echo "RUNNING INSTALL"

###############
#misc
###############
yum install -y wget
yum install -y byobu
yum install -y which
yum install -y nano
yum install -y htop
yum install -y cloud-utils
yum install -y perl-CPAN
yum install -y patch

###############
#apache
###############
#yum install -y httpd

###############
#samba
###############
yum install -y samba samba-client

###############
#nfs
###############
#yum install -y nfs-utils

###############
#vpn
###############
#yum install -y bridge-utils
#yum install -y openvpn

###############
#iscsi
###############
#yum install -y libiscsi-utils scsi-target-utils lsscsi
#yum install -y ntfs-3g ntfsprogs

###############
#management - webmin
###############
set +xe

WEBMINTMP=/tmp/webmin-1.620-1.noarch.rpm
if [[ ! -f "${WEBMINTMP}" ]]; THEN
  wget -O $WEBMINTMP 'http://downloads.sourceforge.net/project/webadmin/webmin/1.620/webmin-1.620-1.noarch.rpm?r=http%3A%2F%2Fwww.webmin.com%2Fdownload.html&ts=1365823599&use_mirror=surfnet'
  yum install -y $WEBMINTMP
  #rm -f $WEBMINTMP
  #http://prdownloads.sourceforge.net/webadmin/webmin-1.620-1.noarch.rpm
fi

set -xe
yum install -y perl make openssl perl-Authen-PAM


###############
#ownclound
#http://software.opensuse.org/download/package?project=isv:ownCloud:community&package=owncloud
#http://ubuntuserverguide.com/2013/04/how-to-setup-owncloud-server-5-with-ssl-connection.html
###############
cd /etc/yum.repos.d/
wget http://download.opensuse.org/repositories/isv:ownCloud:community/Fedora_18/isv:ownCloud:community.repo
yum install owncloud
service httpd restart
chown -R apache:apache /var/www/html/owncloud
chmod 0774 /mnt/external/owncloud


if [[ ! -e "/mnt/external/owncloud" ]]; then
  mkdir /mnt/external/owncloud
  chown -R apache:apache /mnt/external/owncloud
fi

if [[ -z `grep owncloud /etc/fstab` ]]; then
  echo "adding owncloud to fstab"
  echo "/mnt/external/owncloud   /var/www/html/owncloud/data/        bind    bind    0" >> /etc/fstab
  mount -a
else
  echo "owncloud already in fstab"
fi




#TODO
#git clone https://github.com/bobsta63/zpanelx.git zpanelx
