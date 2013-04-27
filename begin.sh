#!/bin/bash
set -e -x -u

cd $BASE
echo "IN BASE $PWD"

# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AESDG-chapter-instancedata.html
EC2_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/hostname`

EC2_INST_ID=`curl http://169.254.169.254/latest/meta-data/instance-id`

EC2_PRIV_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/local-hostname`
EC2_PRIV_IPV4=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

EC2_PUB_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/public-hostname`
EC2_PUB_IPV4=`curl http://169.254.169.254/latest/meta-data/public-ipv4`

EC2_TYPE=`curl http://169.254.169.254/latest/meta-data/instance-type`
# http://stackoverflow.com/questions/4249488/find-region-from-within-ec2-instance
EC2_REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`


curl https://$DYN_LOGIN:$DYN_PASS@www.dnsdynamic.org/api/?hostname=$DYN_HOST&myip=$EC2_PUB_IPV4

#TODO:
# CHECK IF VARIABLE IS SET
# EXPORT PUT AND PRIVATE KEYS
# INSTALL EC2 TOOLS
# LIST VOLUMES:
#   ec2-describe-volumes
# IF EXISTS, ATTACH VOL
#   http://docs.aws.amazon.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-AttachVolume.html
#   ec2-attach-volume -d /dev/sdh -i i-11111111 vol-0000000
#export AWS_ACCESS_KEY=`cat ~/.boto | grep aws_access_key        | gawk '{print $3}'`
#export AWS_SECRET_ACCESS_KEY=`cat ~/.boto | grep aws_secret_access_key | gawk '{print $3}'`


if [[ ! -f "~/ec2init/init.install.sh.skip" ]]; then
	source ~/ec2init/init.install.sh
	touch ~/ec2init/init.install.sh.skip
else
	echo "yum libraries already installed"
fi

python ~/ec2init/tools/attachvolume.py
sleep 10






if [[ ! -z "$EC2_EXTERNAL_SRC" ]]; then
	if [[ -z `fdisk -l | grep $EC2_EXTERNAL_SRC` ]]; then
		EC2_EXTERNAL_PRESENT=""
	else
		EC2_EXTERNAL_PRESENT="OK"
	fi
else
	EC2_EXTERNAL_PRESENT=""
fi



echo "HOSTNAME          $EC2_HOSTNAME"
echo "INSTANCE ID       $EC2_INST_ID"
echo "PRIV HOSTNAME     $EC2_PRIV_HOSTNAME"
echo "PRIV IPV4         $EC2_PRIV_IPV4"
echo "PUB  IPV4         $EC2_PUB_IPV4"
echo "PUB  HOSTNAME     $EC2_PUB_HOSTNAME"
echo "EC2  TYPE         $EC2_TYPE"
echo "EC2  ARN          $EC2_ARN"
echo "EC2  REGION       $EC2_REGION"
echo "EC2  EXTERNAL VOL $EC2_EXTERNAL_VOL"
echo "EC2  EXTERNAL SRC $EC2_EXTERNAL_SRC"
echo "EC2  EXTERNAL DST $EC2_EXTERNAL_DST"
echo "EC2  EXTERNAL PRE $EC2_EXTERNAL_PRESENT"


echo "export EC2_HOSTNAME=$EC2_HOSTNAME"                  > ~/.ec2
echo "export EC2_INST_ID=$EC2_INST_ID"                   >> ~/.ec2
echo "export EC2_PRIV_HOSTNAME=$EC2_PRIV_HOSTNAME"       >> ~/.ec2
echo "export EC2_PRIV_IPV4=$EC2_PRIV_IPV4"               >> ~/.ec2
echo "export EC2_PUB_IPV4=$EC2_PUB_IPV4"                 >> ~/.ec2
echo "export EC2_PUB_HOSTNAME=$EC2_PUB_HOSTNAME"         >> ~/.ec2
echo "export EC2_TYPE=$EC2_TYPE"                         >> ~/.ec2
echo "export EC2_ARN=$EC2_ARN"                           >> ~/.ec2
echo "export EC2_REGION=$EC2_REGION"                     >> ~/.ec2
echo "export EC2_EXTERNAL_VOL=$EC2_EXTERNAL_VOL"         >> ~/.ec2
echo "export EC2_EXTERNAL_SRC=$EC2_EXTERNAL_SRC"         >> ~/.ec2
echo "export EC2_EXTERNAL_DST=$EC2_EXTERNAL_DST"         >> ~/.ec2
echo "export EC2_EXTERNAL_PRESENT=$EC2_EXTERNAL_PRESENT" >> ~/.ec2




if [[ -z `grep /.ec2 /etc/profile.d/saulo.sh` ]]; then 
	echo 'modifying bashrc'
	echo "source ~/.ec2"          >> /etc/profile.d/saulo.sh
	echo "PATH=$PATH:$BASE/tools" >> /etc/profile.d/saulo.sh

else
	echo 'bashrc already modified'
	grep /.ec2 /etc/profile.d/saulo.sh
fi

cp ~/.ec2    ~ec2-user/
cp ~/.boto   ~ec2-user/
cp ~/.bashrc ~ec2-user/



for file in $BASE/init.sh.*.sh; do
	if [[ ! -e "${file}.skip" ]]; then
		echo "running $file"
		source $file
		touch ${file}.skip
		echo "running $file done"
	else
		echo "$file already run. skipping"
	fi
done

yum clean all

echo "DONE BEGIN"
python ~/ec2init/tools/sendsns --subject "I'm on baby" --file ~/.ec2
echo "SENDING MESSAGE"
