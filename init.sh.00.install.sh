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
yum remove -y audit
yum install -y binutils coreutils moreutils make automake gcc gcc-c++ kernel-devel

#TODO
#git clone https://github.com/bobsta63/zpanelx.git zpanelx
