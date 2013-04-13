#!/bin/bash
set -e -x
BASE=/mnt/external/init
su -c 'yum install -y git'
cd $BASE
git pull
source $BASE/begin.sh
