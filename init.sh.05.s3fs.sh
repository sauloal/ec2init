BASE=/mnt/s3

# http://www.linode.com/wiki/index.php/S3fs

if [[ ! -d "$BASE" ]]; then
	echo "CREATING BASE FOLDER $BASE"
	mkdir $BASE
else
	echo "BASE FOLDER $BASE ALREADY EXISTS"
fi

chown guests:guests $BASE
chmod 777 $BASE

V=1.71
cd /tmp

#git clone git://github.com/tongwang/s3fs-c.git
#cd s3fs-c/

yum install -yt --skip-broken openssl-devel

if [[ ! -f "/usr/local/bin/s3fs" ]]; then
	echo "installing s3fs"

	#wget -O s3fs.tar.gz http://s3fs.googlecode.com/files/s3fs-1.67.tar.gz
	wget -O s3fs-$V.tar.gz https://s3fs.googlecode.com/files/s3fs-$V.tar.gz
	tar xvf s3fs-$V.tar.gz
	cd s3fs-$V

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

	set +xeu
	R=`grep -x $BUCKET ~/ec2init/mods/s3fs_forbidden`
	echo "R $R"
	if [[ ! -z "$R" ]]; then
		echo "FORBIDDEN"
		continue
	else
		echo "ALLOWED"
	fi
	set -xeu

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
		echo "s3fs#$BUCKET $BUCKETPATH fuse url=http://s3.amazonaws.com,uid=1001,gid=1001,allow_other,use_cache=/tmp,use_rrs=1,noatime, 0 0" >> /etc/fstab
		echo "added $BUCKETPATH to fstab"
	else
		echo "$BUCKETPATH already in fstab"
	fi



	if [[ -z `mount | grep "$BUCKETPATH"` ]]; then
		echo "mounting $BUCKETPATH"
		mount $BUCKETPATH
		echo "mounted $BUCKETPATH"

		firstfile=`ls $BUCKETPATH | head -1`
		filemode=`stat -c %a $BUCKETPATH/$firstfile`

		echo "  first file $firstfile"
		echo "  file mode $filemode"

		if [[ $filemode -eq 0 ]]; then
			echo "    chaning mode of folders"
			find $BUCKETPATH/ -mindepth 1 -type d -exec echo changing permission of folder {} \; -exec chmod 777 {} \;
		
			echo "    changing mode of files"
			find $BUCKETPATH/ -mindepth 1 -type f -exec echo changing permission of file {} \; -exec chmod 666 {} \;
		else
			echo "    file mode already correct"
		fi

		echo "done"
	else
		echo "$BUCKETPATH already mounted"
	fi
done


cd ~/ec2init

