#!/bin/bash
set -e -x
BASE=/mnt/external/init
#install git
su -c 'yum install -y git'
#pull updates
cd $BASE
git pull
#run scripts
source $BASE/begin.sh
