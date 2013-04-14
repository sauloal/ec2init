#!/bin/bash
set -e -x

cd $BASE
echo "IN BASE $PWD"

# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AESDG-chapter-instancedata.html
EC2_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/hostname`

EC2_PRIV_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/local-hostname`
EC2_PRIV_IPV4=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

EC2_PUB_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/public-hostname`
EC2_PUB_IPV4=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
EC2_TYPE=`curl http://169.254.169.254/latest/meta-data/instance-type`
EC2_REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`

echo "HOSTNAME      $EC2_HOSTNAME"
echo "PRIV HOSTNAME $EC2_PRIV_HOSTNAME"
echo "PRIV IPV4     $EC2_PRIV_IPV4"
echo "PUB  IPV4     $EC2_PUB_IPV4"
echo "PUB  HOSTNAME $EC2_PUB_HOSTNAME"
echo "EC2  TYPE     $EC2_TYPE"
echo "EC2  ARN      $EC2_ARN"
echo "EC2  REGION   $EC2_REGION"


echo "export EC2_HOSTNAME=$EC2_HOSTNAME"            > ~/.ec2
echo "export EC2_PRIV_HOSTNAME=$EC2_PRIV_HOSTNAME" >> ~/.ec2
echo "export EC2_PRIV_IPV4=$EC2_PRIV_IPV4"         >> ~/.ec2
echo "export EC2_PUB_IPV4=$EC2_PUB_IPV4"           >> ~/.ec2
echo "export EC2_PUB_HOSTNAME=$EC2_PUB_HOSTNAME"   >> ~/.ec2
echo "export EC2_TYPE=$EC2_TYPE"                   >> ~/.ec2
echo "export EC2_ARN=$EC2_ARN"                     >> ~/.ec2
echo "export EC2_REGION=$EC2_REGION"               >> ~/.ec2

echo "source ~/.ec2"          >> ~/.bashrc
echo "PATH=$PATH:$BASE/tools" >> ~/.bashrc

cp ~/.ec2    ~ec2-user/
cp ~/.boto   ~ec2-user/
cp ~/.bashrc ~ec2-user/

for file in $BASE/init.sh.*.sh; do
	if [[ ! -e "${file}.skip" ]]; then
		source $file
	fi
done

echo "DONE BEGIN"
