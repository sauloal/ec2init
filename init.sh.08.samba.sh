yum install -yt samba
yum install -yt samba-client

mv /etc/samba/smb.conf /etc/samba/smb.conf.bkp
cp ~/ec2init/mods/smb.conf.new /etc/samba/smb.conf

service smb start
service nmb start

service smb restart
service nmb restart
