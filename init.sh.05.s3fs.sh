BASE=/mnt/s3

# http://www.linode.com/wiki/index.php/S3fs

cd /tmp

#git clone git://github.com/tongwang/s3fs-c.git
#cd s3fs-c/


if [[ ! -f "/usr/local/bin/s3fs" ]]; then
	echo "installing s3fs"
	wget http://s3fs.googlecode.com/files/s3fs-1.67.tar.gz
	tar xvf s3fs-1.67.tar.gz
	cd s3fs-1.67

	./configure
	make
	make install
else
	echo "s3fs already installed"
fi


chmod 400 /etc/passwd-s3fs


#./s3fs saulo saulo -o use_rrs=1 -o allow_other -o passwd_file=./confi


BUCKETS=`s3cmd ls | gawk '{print $3}' | sed 's/s3\:\/\///'`


for BUCKET in $BUCKETS; do
	#BUCKET=saulo

	echo "adding bucket $BUCKET"

	BUCKETPATH=$BASE/$BUCKET


	if [[ ! -d "$BUCKETPATH" ]]; then
		echo "creating folder $BUCKETPATH"
		mkdir -p $BUCKETPATH
	fi


	echo "changing permission"
	chown guests:guests $BUCKETPATH
	chmod 777 $BUCKETPATH


	if [[ -z `grep $BUCKETPATH /etc/fstab` ]]; then
		echo "adding $BUCKETPATH to fstab"
		echo "s3fs#$BUCKET $BUCKETPATH fuse netdev,url=http://s3.amazonaws.com,uid=1001,gid=1001,allow_other,use_cache=/tmp,use_rrs=1,noatime, 0 0" >> /etc/fstab
		echo "added $BUCKETPATH to fstab"
	else
		echo "$BUCKETPATH already in fstab"
	fi

	if [[ -z `mount | grep "$BUCKETPATH"` ]]; then
		echo "mounting $BUCKETPATH"
		mount $BUCKETPATH
		echo "mounted $BUCKETPATH"

		echo "chaning mode of folders"
		find $BUCKETPATH -type d -exec echo {} \; chmod 777 {} \;
		
		echo "changing mode of files"
		find $BUCKETPATH -type f -exec echo {} \; -exec chmod 666 {} \;
		echo "done"
	else
		echo "$BUCKETPATH already mounted"
	fi
exit 0
done


cd ~/ec2init

