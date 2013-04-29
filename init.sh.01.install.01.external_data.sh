######################
# External
######################
#usermod -a -G floppy ec2-user
#usermod -a -G floppy root
#usermod -a -G floppy apache
#useradd -g floppy -G floppy -d /mnt -M -r -s /sbin/nologin -u 19 floppy

if [[ ! -z "$EC2_EXTERNAL_DATA_PRESENT" ]]; then
  if [[ ! -e "$EC2_EXTERNAL_DATA_DST" ]]; then
    mkdir $EC2_EXTERNAL_DATA_DST
  #  chown floppy:floppy $EC2_EXTERNAL_DATA_DST
  #  chmod 775 $EC2_EXTERNAL_DATA_DST
  fi
  
  
  if [[ -z `grep $EC2_EXTERNAL_DATA_SRC /etc/fstab` ]]; then
    echo "adding external $EC2_EXTERNAL_DATA_SRC to fstab"
    #http://blog.smartlogicsolutions.com/2009/06/04/mount-options-to-improve-ext4-file-system-performance/
    #gid 19 = floppy
    #data=ordered
  
    echo "$EC2_EXTERNAL_DATA_SRC   $EC2_EXTERNAL_DATA_DST        ext4    rw,user,auto,noatime,exec,relatime,seclabel,data=writeback,barrier=0,nobh,errors=remount-ro    0 0" >> /etc/fstab
  
  else
    echo "external already in fstab"
  fi
  
  
  if [[ -z `mount | grep "$EC2_EXTERNAL_DATA_DST"` ]]; then
    echo "mounting external $EC2_EXTERNAL_DATA_SRC to $EC2_EXTERNAL_DATA_DST"
    mount $EC2_EXTERNAL_DATA_DST
    mount --make-shared $EC2_EXTERNAL_DATA_DST
  #  chmod 775 $EC2_EXTERNAL_DATA_DST
  #  chown floppy:floppy $EC2_EXTERNAL_DATA_DST
  else
    echo "external $EC2_EXTERNAL_DATA_SRC to $EC2_EXTERNAL_DATA_DST already mounted"
  fi
else
  echo "NO EXTERNAL DEVICE DEFINED"
fi
