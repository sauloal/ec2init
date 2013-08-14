echo "setting up btsync"

wget -O btsync.tar.gz http://btsync.s3-website-us-east-1.amazonaws.com/btsync_i386.tar.gz

tar xvf btsync.tar.gz

cp btsync /usr/bin/btsync

if [[ ! -f "/etc/rc.d/init.d/btsyncd" ]]; then
	echo "copying btsyncd"
	sed 's/<DEFAULT_USER>/apache/g' mods/btsyncd > /etc/rc.d/init.d/btsyncd
else
	echo "btsyncd already present"
fi

chmod +x /etc/init.d/btsyncd

if [[ ! -f "~/.sync.json" ]]; then
	echo "copying sync.json"
	sed -e 's/<BT_USER>/'$BTSYNC_USER'/g' -e 's/<BT_PASS>/'$BTSYNC_PASS'/g' -e 's@<EC2_EXTERNAL_CONFIG_DST>@'$EC2_EXTERNAL_CONFIG_DST'@g' mods/btsync.json  >  ~/.sync.json
else
	echo "sync.json already present"
fi

cp ~/.sync.json /home/$DEFAULT_USER/
chmod 440 ~/.sync.json
chmod 440 /home/$DEFAULT_USER/.sync.json
chown $DEFAULT_USER:apache /home/$DEFAULT_USER/.sync.json


systemctl --system daemon-reload
chkconfig --add btsyncd
chkconfig --levels 2345 btsyncd on

service btsyncd start
