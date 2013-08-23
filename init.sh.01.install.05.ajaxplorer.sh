################
# ajax explorer
################
#http://ajaxplorer.info/documentation/administration/
#todo: setup folders
set -xeu

if [[ -z `yum list installed | grep ajaxplorer-release` ]]; then
	wget -O /tmp/ajax.rpm http://dl.ajaxplorer.info/repos/el6/ajaxplorer-stable/ajaxplorer-release-4-1.noarch.rpm
	yum install -y /tmp/ajax.rpm
else
	echo "ajax explorer release already installed"
fi

yum update -yt
yum install -yt ajaxplorer

#http://www.howtoforge.com/apc-php5-apache2-fedora8
yum install -yt php-pear php-devel httpd-devel

#RUN MANUALLY
#pecl install --soft --alldeps apc
echo "pecl install --soft --alldeps apc" >> RUNME.sh

#if [[ -z `grep apc.so /etc/php.d/apc.ini` ]]; then
	#vi /etc/php.d/apc.ini
	
#	echo -e "extension=apc.so\napc.enabled=1\napc.shm_size=30" >> /etc/php.d/apc.ini
#fi

cp -f --no-preserve=all mods/bootstrap_conf.php /etc/ajaxplorer/bootstrap_conf.php 
cp -f --no-preserve=all mods/ajaxplorer.conf /etc/httpd/conf.d/ajaxplorer.conf

#sed -f mods/bootstrap_context.pgp.sed /etc/ajaxplorer/bootstrap_context.php > /tmp/b
#mv /etc/ajaxplorer/bootstrap_context.php /etc/ajaxplorer/bootstrap_context.php.bkp
#cp -f --no-preserve=all /tmp/b /etc/ajaxplorer/bootstrap_context.php


if [[ ! -d "$EXTERNAL_SYNC_FOLDER" ]]; then
  mkdir $EXTERNAL_SYNC_FOLDER
fi
chown apache:apache $EXTERNAL_SYNC_FOLDER
chmod 770 $EXTERNAL_SYNC_FOLDER

if [[ -d "$EC2_EXTERNAL_CONFIG_DST" ]]; then
  AJAX_DST=$EC2_EXTERNAL_CONFIG_DST/ajaxplorer
  AJAX_DST_ETC=$AJAX_DST/etc
  AJAX_DST_USR=$AJAX_DST/usrshare
  AJAX_DST_VAR=$AJAX_DST/varlib

  AJAX_SRC_ETC=/etc/ajaxplorer/
  AJAX_SRC_USR=/usr/share/ajaxplorer/
  AJAX_SRC_VAR=/var/lib/ajaxplorer/

  echo "mounting AJAX to external"
  if [[ ! -e "$AJAX_DST_ETC" ]]; then
    mkdir -p $AJAX_DST_ETC
    chown -R apache:apache $AJAX_DST_ETC
    chown -R apache:apache $AJAX_SRC_ETC
    chmod 0774 $AJAX_DST_ETC
  fi
  if [[ ! -e "$AJAX_DST_USR" ]]; then
    mkdir -p $AJAX_DST_USR
    chown -R apache:apache $AJAX_DST_USR
    chown -R apache:apache $AJAX_SRC_USR
    chmod 0774 $AJAX_DST_USR
  fi
  if [[ ! -e "$AJAX_DST_VAR" ]]; then
    mkdir -p $AJAX_DST_VAR
    chown -R apache:apache $AJAX_DST_VAR
    chown -R apache:apache $AJAX_SRC_VAR
    chmod 0774 $AJAX_DST_VAR
  fi

  if [[ -z `grep ajaxplorer /etc/fstab` ]]; then
    echo "adding AJAX to fstab"
    echo "$AJAX_DST_ETC   $AJAX_SRC_ETC        bind    bind    0" >> /etc/fstab
    echo "$AJAX_DST_USR   $AJAX_SRC_USR        bind    bind    0" >> /etc/fstab
    echo "$AJAX_DST_VAR   $AJAX_SRC_VAR        bind    bind    0" >> /etc/fstab
  else
    echo "AJAX already in fstab"
  fi

  

  if [[ -z `mount | grep "AJAX"` ]]; then
    echo "mounting AJAX"
    mount --bind $AJAX_DST_ETC $AJAX_SRC_ETC
    mount --bind $AJAX_DST_USR $AJAX_SRC_USR
    mount --bind $AJAX_DST_VAR $AJAX_SRC_VAR
    mount --make-shared $AJAX_SRC_ETC
    mount --make-shared $AJAX_SRC_USR
    mount --make-shared $AJAX_SRC_VAR

    #mount --bind etc/      /etc/ajaxplorer/
    #mount --bind usrshare/ /usr/share/ajaxplorer/
    #mount --bind varlib/   /var/lib/ajaxplorer/

  else
    echo "AJAX already mounted"
  fi

  echo "mounting AJAX to external done"

else
  echo "external not present. skipping mounting AJAX to external"
fi


/bin/systemctl restart  httpd.service

