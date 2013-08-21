echo "setting up btsync"

wget -O btsync.tar.gz http://btsync.s3-website-us-east-1.amazonaws.com/btsync_i386.tar.gz

tar xvf btsync.tar.gz

cp btsync /usr/bin/btsync

if [[ ! -d "$EC2_EXTERNAL_CONFIG_DST" ]]; then
	BT_CONF_FOLDER="$EC2_EXTERNAL_CONFIG_DST/bittorrentsync"
	SYNC_JSON="$BT_CONF_FOLDER/.sync.json"
	BTSYNC_D=/etc/init.d/btsyncd
	
	if [[ ! -f "$BTSYNC_D" ]]; then
		echo "copying btsyncd"
		sed -e 's/<EFFECTIVE_USER>/apache/g' -e 's@<CONFIG_FILE>@'$SYNC_JSON'@g' mods/btsyncd > $BTSYNC_D
	else
		echo "btsyncd already present"
	fi
	chmod +x $BTSYNC_D
	
	
	
	if [[ ! -d "$BT_CONF_FOLDER" ]]; then
		mkdir $BT_CONF_FOLDER
		chown root:apache $BT_CONF_FOLDER
	  	chmod 770 $BT_CONF_FOLDER
	else
		echo "BT CONF FOLDER $BT_CONF_FOLDER ALREADY PRESENT"
	fi
	
	
	
	if [[ ! -d "$EXTERNAL_SYNC_FOLDER" ]]; then
		mkdir $EXTERNAL_SYNC_FOLDER
	else
		echo "EXTERNAL SYNC FOLDER $EXTERNAL_SYNC_FOLDER EXISTS"
	fi
	chown root:apache $EXTERNAL_SYNC_FOLDER
	chmod 770 $EXTERNAL_SYNC_FOLDER



	if [[ ! -f "$SYNC_JSON" ]]; then
		echo "copying sync.json"
		sed -e 's/<BT_USER>/'$BTSYNC_USER'/g' -e 's/<BT_PASS>/'$BTSYNC_PASS'/g' -e 's@<DATA_FOLDER>@'$BT_CONF_FOLDER'@g' mods/btsync.json  >  $SYNC_JSON
	else
		echo "sync.json already present"
	fi


	
	#cp ~/.sync.json /home/$DEFAULT_USER/
	#cp ~/.sync.json /etc/
	
	chmod 440 $SYNC_JSON
	#chmod 440 /home/$DEFAULT_USER/.sync.json
	#chmod 440 /etc/.sync.json
	#chown $DEFAULT_USER:apache /home/$DEFAULT_USER/.sync.json
	chown root:apache $SYNC_JSON
	
	
	systemctl --system daemon-reload
	chkconfig --add btsyncd
	chkconfig --levels 2345 btsyncd on
	
	service btsyncd start
else
	echo "SKIPPING BTSYNC. NO $EC2_EXTERNAL_CONFIG_DST"
fi
