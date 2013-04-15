#!/bin/bash
set -e -x
BASE=~/ec2init

###########
# LOG
###########
#http://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions
LOG="init.sh."`data +%Y%m%d_%H%M%S`".log"

#Saves file descriptors so they can be restored to whatever they were before redirection or used themselves to output to whatever they were before the following redirect.
exec 3>&1 4>&2

#Restore file descriptors for particular signals. Not generally necessary since they should be restored when the sub-shell exits.
trap 'exec 2>&4 1>&3' 0 1 2 3

#Redirect stdout to file log.out then redirect stderr to stdout. Note that the order is important when you want them going to the same file. stdout must be redirected before stderr is redirected to stdout.
exec 1>${LOG} 2>&1


##########
# pull updates
##########
cd $BASE
git pull

sleep 5

###########
#run scripts
###########
source $BASE/begin.sh

echo "DONE INIT"
