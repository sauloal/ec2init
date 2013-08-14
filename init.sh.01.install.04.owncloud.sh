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

if [[ ! -d '/mnt/sync' ]]; then
  mkdir /mnt/sync
  chown root:apache /mnt/sync
  chmod 770 /mnt/sync
fi

#################
# OwnCloud
#################
if [[ ! -z "$EC2_EXTERNAL_CONFIG_PRESENT" ]]; then
  echo "mounting owncloud to external"
  if [[ ! -e "$EC2_EXTERNAL_CONFIG_DST/owncloud" ]]; then
    mkdir -p $EC2_EXTERNAL_CONFIG_DST/owncloud
    chown -R apache:apache $EC2_EXTERNAL_CONFIG_DST/owncloud
    chown -R apache:apache /var/www/html/owncloud
    chmod 0774 $EC2_EXTERNAL_CONFIG_DST/owncloud
  fi
  
  if [[ -z `grep owncloud /etc/fstab` ]]; then
    echo "adding owncloud to fstab"
    echo "$EC2_EXTERNAL_CONFIG_DST/owncloud   /var/www/html/owncloud        bind    bind    0" >> /etc/fstab
  else
    echo "owncloud already in fstab"
  fi
  
  if [[ -z `mount | grep "owncloud"` ]]; then
    echo "mounting owncloud"
    mount --bind $EC2_EXTERNAL_CONFIG_DST/owncloud /var/www/html/owncloud
    mount --make-shared /var/www/html/owncloud
  else
    echo "owncloud already mounted"
  fi
  echo "mounting owncloud to external done"
else
  echo "external not present. skipping mounting owncloud to external"
fi
