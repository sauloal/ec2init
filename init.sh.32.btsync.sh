echo "setting up btsync"

wget -O btsync.tar.gz http://btsync.s3-website-us-east-1.amazonaws.com/btsync_i386.tar.gz

tar xvf btsync.tar.gz

cp btsync /usr/bin/btsync

if [[ ! -f "/etc/rc.d/init.d/btsyncd" ]]; then
	echo "copying btsyncd"
	cp mods/btsyncd      /etc/rc.d/init.d/btsyncd
else
	echo "btsyncd already present"
fi

chmod +x /etc/init.d/btsyncd

if [[ ! -f "~/.sync.json" ]]; then
	echo "copying sync.json"
	cp mods/sync.json ~/.sync.json
else
	echo "sync.json already present"
fi


chkconfig --add btsyncd
chkconfig --levels 2345 btsyncd on

service btsyncd start
