#!/bin/bash
set -e -x -u

cd $BASE
echo "IN BASE $PWD"

# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AESDG-chapter-instancedata.html
EC2_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/hostname`

EC2_PRIV_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/local-hostname`
EC2_PRIV_IPV4=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

EC2_PUB_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/public-hostname`
EC2_PUB_IPV4=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
EC2_TYPE=`curl http://169.254.169.254/latest/meta-data/instance-type`
# http://stackoverflow.com/questions/4249488/find-region-from-within-ec2-instance
EC2_REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`

echo "HOSTNAME          $EC2_HOSTNAME"
echo "PRIV HOSTNAME     $EC2_PRIV_HOSTNAME"
echo "PRIV IPV4         $EC2_PRIV_IPV4"
echo "PUB  IPV4         $EC2_PUB_IPV4"
echo "PUB  HOSTNAME     $EC2_PUB_HOSTNAME"
echo "EC2  TYPE         $EC2_TYPE"
echo "EC2  ARN          $EC2_ARN"
echo "EC2  REGION       $EC2_REGION"
echo "EC2  EXTERNAL SRC $EC2_EXTERNAL_SRC"
echo "EC2  EXTERNAL DST $EC2_EXTERNAL_DST"


echo "export EC2_HOSTNAME=$EC2_HOSTNAME"            > ~/.ec2
echo "export EC2_PRIV_HOSTNAME=$EC2_PRIV_HOSTNAME" >> ~/.ec2
echo "export EC2_PRIV_IPV4=$EC2_PRIV_IPV4"         >> ~/.ec2
echo "export EC2_PUB_IPV4=$EC2_PUB_IPV4"           >> ~/.ec2
echo "export EC2_PUB_HOSTNAME=$EC2_PUB_HOSTNAME"   >> ~/.ec2
echo "export EC2_TYPE=$EC2_TYPE"                   >> ~/.ec2
echo "export EC2_ARN=$EC2_ARN"                     >> ~/.ec2
echo "export EC2_REGION=$EC2_REGION"               >> ~/.ec2
echo "export EC2_EXTERNAL_SRC=$EC2_EXTERNAL_SRC"   >> ~/.ec2
echo "export EC2_EXTERNAL_DST=$EC2_EXTERNAL_DST"   >> ~/.ec2

if [[ -z `grep /.ec2  ~/.bashrc` ]]; then 
echo 'modifying bashrc'
echo "source ~/.ec2"          >> ~/.bashrc
echo "PATH=$PATH:$BASE/tools" >> ~/.bashrc

else
grep /.ec2  ~/.bashrc
fi

cp ~/.ec2    ~ec2-user/
cp ~/.boto   ~ec2-user/
cp ~/.bashrc ~ec2-user/

for file in $BASE/init.sh.*.sh; do
	if [[ ! -e "${file}.skip" ]]; then
		source $file
		touch ${file}.skip
	fi
done

echo "DONE BEGIN"
python ~/ec2init/tools/sendsns --subject "I'm on baby" --file ~/.ec2
echo "SENDING MESSAGE"
