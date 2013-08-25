yum install -yt nfs-utils

patch /etc/sysconfig/nfs mods/nfs_sysconfig.patch

if [[ ! -f "/etc/exports.bkp" ]]; then
	mv /etc/exports /etc/exports.bkp
	cp mods/nfs_exports /etc/exports
	chmod 644 /etc/exports
fi

service nfs restart
