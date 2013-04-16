###############
#ownclound
#http://software.opensuse.org/download/package?project=isv:ownCloud:community&package=owncloud
#http://ubuntuserverguide.com/2013/04/how-to-setup-owncloud-server-5-with-ssl-connection.html
###############
set -xeu
cd /etc/yum.repos.d/
wget http://download.opensuse.org/repositories/isv:ownCloud:community/Fedora_18/isv:ownCloud:community.repo
yum install -y owncloud
service httpd restart


setenforce 0
cp -f --no-preserve=all mods/selinux.new /etc/sysconfig/selinux


#################
# OwnCloud
#################
if [[ ! -e "$EC2_EXTERNAL_DST/owncloud" ]]; then
  mkdir -p $EC2_EXTERNAL_DST/owncloud/data
  chown -R apache:apache $EC2_EXTERNAL_DST/owncloud/data
  chown -R apache:apache /var/www/html/owncloud
  chmod 0774 $EC2_EXTERNAL_DST/owncloud
  chmod 0774 $EC2_EXTERNAL_DST/owncloud/data
fi

if [[ -z `grep owncloud /etc/fstab` ]]; then
  echo "adding owncloud to fstab"
  echo "$EC2_EXTERNAL_DST/owncloud/data   /var/www/html/owncloud/data/        bind    bind    0" >> /etc/fstab
else
  echo "owncloud already in fstab"
fi

if [[ -z `mount | grep "owncloud"` ]]; then
  echo "mounting owncloud"
  mount --bind $EC2_EXTERNAL_DST/owncloud/data /var/www/html/owncloud/data
  mount --make-shared /var/www/html/owncloud/data
else
  echo "owncloud already mounted"
fi
