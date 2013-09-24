yum install -yt samba
yum install -yt samba-client

if [[ -f "/etc/samba/smb.conf" ]]; then
	mv /etc/samba/smb.conf /etc/samba/smb.conf.bkp
fi

cp ~/ec2init/mods/smb.conf.new /etc/samba/smb.conf

service smb start
service nmb start

service smb restart
service nmb restart
