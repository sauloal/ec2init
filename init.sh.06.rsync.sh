echo "setting up rsync"

if [[ ! -f "/etc/rc.d/init.d/rsyncd" ]]; then
	echo "copying rsyncd"
	cp mods/rsyncd      /etc/rc.d/init.d/rsyncd
else
	echo "rsyncd already present"
fi

chmod +x /etc/init.d/rsyncd

if [[ ! -f "/etc/rsyncd.conf" ]]; then
	echo "copying rsyncd.conf"
	cp mods/rsyncd.conf /etc/rsyncd.conf
else
	echo "rsyncd.conf already present"
fi


chkconfig --add rsyncd
chkconfig --levels 2345 rsyncd on

service rsyncd start
