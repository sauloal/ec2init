BASE=/mnt/s3

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
if [[ ! -d "$BASE/BUCKET" ]]; THEN
	mkdir -p $BASE/$BUCKET
fi

echo "s3fs#$BUCKET $BASE/$BUCKET fuse url=http://s3.amazonaws.com,uid=1001,gid=1001,allow_other,use_rrs=1 0 0


cd ~/ec2init
