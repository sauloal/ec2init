#what to install
echo "RUNNING INSTALL"

###############
#misc
###############
set +xeu
yum clean all
yum install -yt --skip-broken deltarpm
yum update  -yt

yum clean all
yum update  -yt

yum install -yt --skip-broken psmisc 
yum install -yt --skip-broken mlocate 
yum install -yt --skip-broken which 
yum install -yt --skip-broken htop 
yum install -yt --skip-broken audit
yum install -yt --skip-broken glibc-headers
yum install -yt --skip-broken make
yum install -yt --skip-broken binutils 
yum install -yt --skip-broken coreutils 
yum install -yt --skip-broken moreutils 
yum install -yt --skip-broken automake 
yum install -yt --skip-broken gcc 
yum install -yt --skip-broken gcc-c++ 
yum install -yt --skip-broken kernel-devel
yum install -yt --skip-broken fuse
yum install -yt --skip-broken fuse-devel
yum install -yt --skip-broken libcurl
yum install -yt --skip-broken libcurl-devel
yum install -yt --skip-broken libxml
yum install -yt --skip-broken libxml-devel
yum install -yt --skip-broken libxml2
yum install -yt --skip-broken libxml2-devel

yum install -yt --skip-broken cloud-utils
yum install -yt --skip-broken wget
yum install -yt --skip-broken byobu
yum install -yt --skip-broken nano
yum install -yt --skip-broken patch
yum install -yt --skip-broken unzip
yum install -yt --skip-broken perl-CPAN
yum install -yt --skip-broken python-devel

set -xeu


if [[ -z `yum list installed | gawk '{print $1}' | grep rpmfusion-free` ]]; then
	wget -O /tmp/fusion_free.rpm  http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-18.noarch.rpm
	yum install -yt --skip-broken /tmp/fusion_free.rpm
else
	echo "rpm fusion free alaready installed"
fi



if [[ -z `yum list installed | gawk '{print $1}' | grep rpmfusion-nonfree` ]]; then
	wget -O /tmp/fusion_nfree.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-18.noarch.rpm
	yum install -yt --skip-broken /tmp/fusion_nfree.rpm
else
	echo "rpm fusion non free alaready installed"
fi



#yum remove java java-devel

if [[ -z `yum list installed | grep jre.i586` ]]; then
	wget -O /tmp/jre.rpm 'http://javadl.sun.com/webapps/download/AutoDL?BundleId=76850'
	yum install -yt --skip-broken /tmp/jre.rpm
else
	echo "jre already installed"
fi


yum clean all






#boto
easy_install boto
# gives boto-rsync
easy_install boto_rsync
# gives ses-send-email and s3-geturl, among others
easy_install boto_utils








#TODO
#git clone https://github.com/bobsta63/zpanelx.git zpanelx


#wget -O ec2-api-tools.zip 'http://www.amazon.com/gp/redirect.html/ref=aws_rc_ec2tools?location=http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip&token=A80325AA4DAB186C80828ED5138633E3F49160D9'
#unzip ec2-api-tools.zip
#rm -f ec2-api-tools.zip

#mkdir /usr/ec2
#cd ec2-api-tool-*
#mv bin lib /usr/ec2/

#cd /usr/ec2/bin
#rm -f *.cmd
#for file in *; do
#	if [[ ! -f "/usr/bin/$file" ]]; then
#		unlink /usr/bin/$file
#	fi
#	ln -s $PWD/$file /usr/bin/$file
#done

#cd -

#echo 'export EC2_HOME=/usr/ec2/'         >> /etc/profile.d/saulo.sh
echo 'export JAVA_HOME=/usr/java/latest' >> /etc/profile.d/saulo.sh




