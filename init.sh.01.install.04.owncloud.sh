###############
#ownclound
#http://software.opensuse.org/download/package?project=isv:ownCloud:community&package=owncloud
#http://ubuntuserverguide.com/2013/04/how-to-setup-owncloud-server-5-with-ssl-connection.html
#REMEMBER TO:
#  COPY /var/www/html/owncloud to /mnt/config
#  change owner root:apache
#  edit config/config.php:
#    'datadirectory' => '/mnt/sync',
###############
set -xeu
cd /etc/yum.repos.d/
wget http://download.opensuse.org/repositories/isv:ownCloud:community/Fedora_18/isv:ownCloud:community.repo
cd -
yum install -yt owncloud
service httpd restart


setenforce 0
cp -f --no-preserve=all mods/selinux.new /etc/sysconfig/selinux

if [[ ! -d "$EXTERNAL_SYNC_FOLDER" ]]; then
  mkdir $EXTERNAL_SYNC_FOLDER
fi

chown apache:apache $EXTERNAL_SYNC_FOLDER
chmod 770 $EXTERNAL_SYNC_FOLDER


#################
# OwnCloud
#################
if [[ -d "$EC2_EXTERNAL_CONFIG_DST" ]]; then
  OWNCLOUD_DST=$EC2_EXTERNAL_CONFIG_DST/owncloud
  OWNCLOUD_SRC=/var/www/html/owncloud
  echo "mounting owncloud to external"
  if [[ ! -e "$OWNCLOUD_DST" ]]; then
    mkdir -p $OWNCLOUD_DST
    chown -R apache:apache $OWNCLOUD_DST
    chown -R apache:apache $OWNCLOUD_SRC
    chmod 0774 $OWNCLOUD_DST
  fi
  

  if [[ -z `grep owncloud /etc/fstab` ]]; then
    echo "adding owncloud to fstab"
    echo "$OWNCLOUD_DST   $OWNCLOUD_SRC        bind    bind    0" >> /etc/fstab
  else
    echo "owncloud already in fstab"
  fi
  

  if [[ -z `mount | grep "owncloud"` ]]; then
    echo "mounting owncloud"
    mount --bind $OWNCLOUD_DST $OWNCLOUD_SRC
    mount --make-shared $OWNCLOUD_SRC
  else
    echo "owncloud already mounted"
  fi

  echo "mounting owncloud to external done"

else
  echo "external not present. skipping mounting owncloud to external"
fi
