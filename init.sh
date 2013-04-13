#!/bin/bash
set -e -x
BASE=~/ec2init


#pull updates
cd $BASE
git pull

sleep 5

#run scripts
source $BASE/begin.sh

echo "DONE INIT"
