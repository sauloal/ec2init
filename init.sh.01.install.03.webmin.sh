###############
#management - webmin
###############
set -xeu

WEBMINTMP=/tmp/webmin-1.620-1.noarch.rpm
if [[ ! -f "${WEBMINTMP}" ]]; THEN
  wget -O $WEBMINTMP 'http://downloads.sourceforge.net/project/webadmin/webmin/1.620/webmin-1.620-1.noarch.rpm?r=http%3A%2F%2Fwww.webmin.com%2Fdownload.html&ts=1365823599&use_mirror=surfnet'
  yum install -y $WEBMINTMP
  #rm -f $WEBMINTMP
  #http://prdownloads.sourceforge.net/webadmin/webmin-1.620-1.noarch.rpm
fi


yum install -y perl make openssl perl-Authen-PAM


#WEBMIN - CHANGE PASSWORD ASAP
#port 10000
/sbin/chkconfig webmin on
set +xeu
service webmin start &
set -xeu


