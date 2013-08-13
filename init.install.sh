#what to install
echo "RUNNING INSTALL"

###############
#misc
###############
yum clean all
yum update  -y

yum install -y --skip-broken deltarpm
yum install -y --skip-broken wget
yum install -y --skip-broken byobu
yum install -y --skip-broken which
yum install -y --skip-broken nano
yum install -y --skip-broken htop
yum install -y --skip-broken cloud-utils
yum install -y --skip-broken perl-CPAN
yum install -y --skip-broken patch
yum install -y --skip-broken mlocate
yum remove  -y --skip-broken audit
yum install -y --skip-broken binutils coreutils moreutils make automake gcc gcc-c++ kernel-devel
yum install -y --skip-broken python-devel
yum install -y --skip-broken unzip
yum install -y --skip-broken fuse fuse-devel libcurl libcurl-devel libxml libxml-devel libxml2 libxml2-devel


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




