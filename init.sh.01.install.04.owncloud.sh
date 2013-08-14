###############
#ownclound
#http://software.opensuse.org/download/package?project=isv:ownCloud:community&package=owncloud
#http://ubuntuserverguide.com/2013/04/how-to-setup-owncloud-server-5-with-ssl-connection.html
###############
set -xeu
cd /etc/yum.repos.d/
wget http://download.opensuse.org/repositories/isv:ownCloud:community/Fedora_18/isv:ownCloud:community.repo
cd -
yum install -y owncloud
service httpd restart


setenforce 0
cp -f --no-preserve=all mods/selinux.new /etc/sysconfig/selinux

if [[ ! -d "$EXTERNAL_SYNC_FOLDER" ]]; then
  mkdir $EXTERNAL_SYNC_FOLDER
  chown root:apache $EXTERNAL_SYNC_FOLDER
  chmod 770 $EXTERNAL_SYNC_FOLDER
fi

#################
# OwnCloud
#################
if [[ ! -z "$EC2_EXTERNAL_CONFIG_PRESENT" ]]; then
  OWNCLOUD_DST=$EC2_EXTERNAL_CONFIG_DST/owncloud
  echo "mounting owncloud to external"
  if [[ ! -e "$OWNCLOUD_DST" ]]; then
    mkdir -p $OWNCLOUD_DST
    chown -R apache:apache $OWNCLOUD_DST
    chown -R apache:apache /var/www/html/owncloud
    chmod 0774 $OWNCLOUD_DST
  fi
  
  if [[ -z `grep owncloud /etc/fstab` ]]; then
    echo "adding owncloud to fstab"
    echo "$OWNCLOUD_DST   /var/www/html/owncloud        bind    bind    0" >> /etc/fstab
  else
    echo "owncloud already in fstab"
  fi
  
  if [[ -z `mount | grep "owncloud"` ]]; then
    echo "mounting owncloud"
    mount --bind $OWNCLOUD_DST /var/www/html/owncloud
    mount --make-shared /var/www/html/owncloud
  else
    echo "owncloud already mounted"
  fi
  echo "mounting owncloud to external done"
else
  echo "external not present. skipping mounting owncloud to external"
fi
