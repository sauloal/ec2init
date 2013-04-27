#what to install
echo "RUNNING INSTALL"

###############
#misc
###############
yum update -y

yum install -y wget
yum install -y byobu
yum install -y which
yum install -y nano
yum install -y htop
yum install -y cloud-utils
yum install -y perl-CPAN
yum install -y patch
yum install -y mlocate
yum remove  -y audit
yum install -y binutils coreutils moreutils make automake gcc gcc-c++ kernel-devel
yum install -y python-devel
yum install -y unzip

rpm -ivh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-18.noarch.rpm
rpm -ivh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-18.noarch.rpm

yum clean all

#TODO
#git clone https://github.com/bobsta63/zpanelx.git zpanelx

#yum remove java java-devel
wget -O jre.rpm 'http://javadl.sun.com/webapps/download/AutoDL?BundleId=76850'
rpm -ivf jre.rpm
rm -f jre.rpm

wget -O ec2-api-tools.zip 'http://www.amazon.com/gp/redirect.html/ref=aws_rc_ec2tools?location=http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip&token=A80325AA4DAB186C80828ED5138633E3F49160D9'
unzip ec2-api-tools.zip
rm -f ec2-api-tools.zip

mkdir /usr/ec2
cd ec2-api-tool-*
mv bin lib /usr/ec2/

cd /usr/ec2/bin
rm -f *.cmd
for file in *; do
	if [[ ! -f "/usr/bin/$file" ]]; then
		unlink /usr/bin/$file
	fi
	ln -s $PWD/$file /usr/bin/$file
done

echo 'export EC2_HOME=/usr/ec2/'         >> /etc/profile.d/saulo.sh
echo 'export JAVA_HOME=/usr/java/latest' >> /etc/profile.d/saulo.sh

cd -

