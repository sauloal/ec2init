BASE=/mnt/s3

# http://www.linode.com/wiki/index.php/S3fs

cd /tmp

#git clone git://github.com/tongwang/s3fs-c.git
#cd s3fs-c/

wget http://s3fs.googlecode.com/files/s3fs-1.67.tar.gz
tar xvf s3fs-1.67.tar.gz
cd s3fs-1.67


./configure
make
make install


chmod 400 /etc/passwd-s3fs


#./s3fs saulo saulo -o use_rrs=1 -o allow_other -o passwd_file=./confi


BUCKETS=`s3cmd ls | gawk '{print $3}' | sed 's/s3\:\/\///'`

for BUCKET in $BUCKETS; do
	#BUCKET=saulo

	echo "adding bucket $BUCKET"

	BUCKETPATH=$BASE/$BUCKET

	if [[ ! -d "$BUCKETPATH" ]]; then
		mkdir -p $BUCKETPATH
	fi

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
		find $BUCKETPATH -type d -exec chmod 777 {} \;
		find $BUCKETPATH -type f -exec chmod 666 {} \;
	else
		echo "$BUCKETPATH already mounted"
	fi
exit 0
done


cd ~/ec2init

