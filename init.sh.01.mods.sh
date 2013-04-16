#modifications to setup

######################
# External
######################
usermod -a -G floppy ec2-user
usermod -a -G floppy root
usermod -a -G floppy apache
useradd -g floppy -G floppy -d /mnt -M -r -s /sbin/nologin -u 19 floppy

if [[ ! -e "$EC2_EXTERNAL_DST" ]]; then
  mkdir $EC2_EXTERNAL_DST
  chown floppy:floppy $EC2_EXTERNAL_DST
  chmod 775 $EC2_EXTERNAL_DST
fi


if [[ -z `grep $EC2_EXTERNAL_SRC /etc/fstab` ]]; then
  echo "adding external $EC2_EXTERNAL_SRC to fstab"
  #http://blog.smartlogicsolutions.com/2009/06/04/mount-options-to-improve-ext4-file-system-performance/
  #gid 19 = floppy
  #data=ordered

  echo "$EC2_EXTERNAL_SRC   $EC2_EXTERNAL_DST        ext4    rw,user,auto,noatime,exec,relatime,seclabel,gid=19,data=writeback,barrier=0,nobh,umask=000,errors=remount-ro    0 0" >> /etc/fstab

else
  echo "external already in fstab"
fi


if [[ ! -z `mount | grep "$EC2_EXTERNAL_DST"` ]]; then
  mecho "mounting external $EC2_EXTERNAL_SRC to $EC2_EXTERNAL_DST"
  mount $EC2_EXTERNAL_DST
  mount --make-shared $EC2_EXTERNAL_DST
  chmod 775 $EC2_EXTERNAL_DST
  chown floppy:floppy $EC2_EXTERNAL_DST
else
	echo "external $EC2_EXTERNAL_SRC to $EC2_EXTERNAL_DST already mounted"
fi





#################
# OwnCloud
#################
if [[ ! -e "$EC2_EXTERNAL_DST/owncloud" ]]; then
  mkdir $EC2_EXTERNAL_DST/owncloud
  chown -R apache:apache $EC2_EXTERNAL_DST/owncloud
  chown -R apache:apache /var/www/html/owncloud
  chmod 0774 $EC2_EXTERNAL_DST/owncloud
  mount --bind $EC2_EXTERNAL_DST/owncloud/ /var/www/html/owncloud/data
  mount --make-shared /var/www/html/owncloud/data
fi

if [[ -z `grep owncloud /etc/fstab` ]]; then
  echo "adding owncloud to fstab"
  echo "/mnt/external/owncloud   /var/www/html/owncloud/data/        bind    bind    0" >> /etc/fstab
  mount -a
else
  echo "owncloud already in fstab"
fi





######################
# SSH
######################
#https://wiki.archlinux.org/index.php/Sshfs
#http://ubuntuforums.org/showthread.php?t=1182295
#TODO:
# /etc/passwd:
# user:1003:1003:User,,,:/:/usr/sbin/nologin
#
#/etc/group:
#sftp:1004:user
#
#/etc/ssh/sshd_config:
# Logging
#SyslogFacility AUTH
#LogLevel DEBUG
#Subsystem sftp internal-sftp
#Match group sftp
#ForceCommand internal-sftp
#ChrootDirectory /var/sshbox

#http://serverfault.com/questions/431169/is-it-possible-to-allow-key-based-authentication-for-sshd-cofnig-chroot-sftp-use
#OR:
#Match Group sftpusers
#        ChrootDirectory /sftp/%u
#        ForceCommand internal-sftp
#        PubkeyAuthentication yes
#        AuthorizedKeysFile     %h/.ssh/authorized_keys

cp --no-preserve=all mods/sshd_config.new /etc/ssh/sshd_config





if [[ 0 -eq 1 ]]; then
echo mods
##################
# iSCSI
##################
#/etc/tgt/targets.conf
#ignore-errors yes

#<target iqn.2012-04.ec2-54-228-22-35.eu-west-1.compute.amazonaws.com:disk>
#        backing-store /dev/xvdg
#        #initiator-address 54.228.22.35
#        incominguser saulo pass
#</target>


#/lib/systemd/system/tgtd.service
## see bz 848942. workaround for a race for now.
#ExecStartPost=sleep 5

## see bz 848942. workaround for a race for now.
#ExecStartPost=/bin/sleep 10



##################
# NFS
##################
#TODO:
#http://www.learnbydoingit.org/2013/01/configuring-nfs-server-on-fedora-18/
#vi /etc/idmapd.conf

# line 5: uncomment and change to your domain name

#Domain = server.world

#[root@master ~]# vi /etc/exports

# write like below *note 
#/home 10.0.0.0/24(rw,sync,no_root_squash,no_all_squash)

# *note 
#/home ⇒ shared directory 
#10.0.0.0/24 ⇒ range of networks NFS permits accesses 
#rw ⇒ writable 
#sync ⇒ synchronize 
#no_root_squash ⇒ enable root privilege 
#no_all_squash ⇒ enable users’ authority

#if [[ ! -e "/mnt/external" ]]; then
#  mkdir /mnt/external
#fi
#patch /etc/exports < mods/nfs_exports.patch
#patch /etc/fstab   < mods/fstab.patch

#cp --no-preserve=all mods/nfs_exports.new /etc/exports
#cp --no-preserve=all mods/fstab.new       /etc/fstab 

#mount -a


##################
# SAMBA
##################
#patch /etc/smb.conf < mods/smb.conf.patch

#http://www.howtoforge.com/fedora-18-samba-standalone-server-with-tdbsam-backend
#vi /etc/samba/smb.conf

#[...]
#[allusers]
#  comment = All Users
#  path = /home/shares/allusers
#  valid users = @users
#  force group = users
#  create mask = 0660
#  directory mask = 0771
#  writable = yes
#If you want all users to be able to read and write to their home directories via Samba, add the following lines to /etc/samba/smb.conf (make sure you comment out or remove the other [homes] section in the smb.conf file!):

#[...]
#[homes]
#   comment = Home Directories
#   browseable = no
#   valid users = %S
#   writable = yes
#   create mask = 0700
#   directory mask = 0700

#useradd tom -m -G users

#Set a password for tom in the Linux system user database. If the user tom should not be able to log into the Linux system, skip this step.

#passwd tom


#-> Enter the password for the new user.

#Now add the user to the Samba user database:

#smbpasswd -a tom

fi


