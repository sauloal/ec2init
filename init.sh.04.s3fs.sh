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


BUCKET=saulo


	BUCKETPATH=$BASE/$BUCKET

	if [[ ! -d "$BUCKETPATH" ]]; then
		mkdir -p $BUCKETPATH
	fi


	if [[ -z `grep $BUCKETPATH /etc/fstab` ]]; then
		echo "adding $BUCKETPATH to fstab"
		echo "s3fs#$BUCKET $BUCKETPATH fuse url=http://s3.amazonaws.com,uid=1001,gid=1001,allow_other,use_rrs=1 0 0" >> /etc/fstab
		echo "added $BUCKETPATH to fstab"
	else
		echo "$BUCKETPATH already in fstab"
	fi

	if [[ -z `mount | grep "$BUCKETPATH"` ]]; then
		echo "mounting $BUCKETPATH"
		mount $BUCKETPATH
		echo "mounted $BUCKETPATH"
	else
		echo "$BUCKETPATH already mounted"
	fi



cd ~/ec2init

