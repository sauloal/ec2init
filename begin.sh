#!/bin/bash
set -e -x

cd $BASE
echo "IN BASE $PWD"

for file in $BASE/init.sh.*.sh; do
	source $file
done

echo "DONE BEGIN"
