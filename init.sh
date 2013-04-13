#!/bin/bash
set -e -x
BASE=/mnt/external/init

#install git
su -c 'yum install -y git'

EC2_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/hostname`

EC2_PRIV_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/local-hostname`
EC2_PRIV_IPV4=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

EC2_PUB_IPV4=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
EC2_PUB_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/public-hostname`
EC2_TYPE=`curl http://169.254.169.254/latest/meta-data/instance-type`


#pull updates
cd $BASE
git pull

sleep 5

#run scripts
source $BASE/begin.sh

echo "DONE INIT"
