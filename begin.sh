#!/bin/bash
set -e -x -u

cd $BASE
echo "IN BASE $PWD"


if [[ ! -f "/root/ec2init/init.install.sh.skip" ]]; then
	echo "yum libraries not installed. installing"
	source ~/ec2init/init.install.sh
	touch  ~/ec2init/init.install.sh.skip
else
	echo "yum libraries already installed"
fi



ec2metadata --instance-id
ec2metadata --instance-type

ec2metadata --local-hostname
ec2metadata --local-ipv4

ec2metadata --public-hostname
ec2metadata --public-ipv4

ec2metadata --block-device-mapping
ec2metadata --security-groups
ec2metadata --mac
ec2metadata --profile
ec2metadata --instance-action
ec2metadata --public-keys
ec2metadata --user-data
ec2metadata --availability-zone



# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AESDG-chapter-instancedata.html
# http://stackoverflow.com/questions/4249488/find-region-from-within-ec2-instance
EC2_HOSTNAME=`     ec2metadata --public-hostname`
EC2_INST_ID=`      ec2metadata --instance-id`
EC2_PRIV_HOSTNAME=`ec2metadata --local-hostname`
EC2_PRIV_IPV4=`    ec2metadata --local-ipv4`
EC2_PUB_HOSTNAME=` ec2metadata --public-hostname`
EC2_PUB_IPV4=`     ec2metadata --public-ipv4`
EC2_TYPE=`         ec2metadata --instance-type`
EC2_REGION=`       ec2metadata --availability-zone`

EC2_ACCESS_KEY=<your access key>
EC2_SECRET_ACCESS_KEY=<your secret key>

echo "[Credentials]"                                   > ~/.boto
echo "aws_access_key_id = $EC2_ACCESS_KEY"            >> ~/.boto
echo "aws_secret_access_key = $EC2_SECRET_ACCESS_KEY" >> ~/.boto
chmod 400 ~/.boto 

echo "$EC2_ACCESS_KEY:$EC2_SECRET_ACCESS_KEY" > /etc/passwd-s3fs
chmod 400 /etc/passwd-s3fs



curl https://$DYN_LOGIN:$DYN_PASS@www.dnsdynamic.org/api/?hostname=$DYN_HOST&myip=$EC2_PUB_IPV4 2>/dev/null

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






if [[ ! -f "/root/ec2init/init.attach.sh.skip" ]]; then
	echo "disks not attached yet. attaching"
	source ~/ec2init/init.attach.sh
	touch  ~/ec2init/init.attach.sh.skip
else
	echo "disks already attached"
fi







if [[ ! -z "$EC2_EXTERNAL_CONFIG_SRC" ]]; then
	if [[ -z `fdisk -l | grep $EC2_EXTERNAL_CONFIG_SRC` ]]; then
		EC2_EXTERNAL_CONFIG_PRESENT=""
	else
		EC2_EXTERNAL_CONFIG_PRESENT="OK"
	fi
else
	EC2_EXTERNAL_CONFIG_PRESENT=""
fi

if [[ ! -z "$EC2_EXTERNAL_DATA_SRC" ]]; then
	if [[ -z `fdisk -l | grep $EC2_EXTERNAL_DATA_SRC` ]]; then
		EC2_EXTERNAL_DATA_PRESENT=""
	else
		EC2_EXTERNAL_DATA_PRESENT="OK"
	fi
else
	EC2_EXTERNAL_DATA_PRESENT=""
fi






echo "HOSTNAME                 $EC2_HOSTNAME"
echo "INSTANCE ID              $EC2_INST_ID"
echo "PRIV HOSTNAME            $EC2_PRIV_HOSTNAME"
echo "PRIV IPV4                $EC2_PRIV_IPV4"
echo "PUB  HOSTNAME            $EC2_PUB_HOSTNAME"
echo "PUB  IPV4                $EC2_PUB_IPV4"
echo "EC2  TYPE                $EC2_TYPE"
echo "EC2  ARN                 $EC2_ARN"
echo "EC2  REGION              $EC2_REGION"

echo "EC2  EXTERNAL CONFIG VOL $EC2_EXTERNAL_DATA_VOL"
echo "EC2  EXTERNAL CONFIG SRC $EC2_EXTERNAL_DATA_SRC"
echo "EC2  EXTERNAL CONFIG DST $EC2_EXTERNAL_DATA_DST"
echo "EC2  EXTERNAL CONFIG PRE $EC2_EXTERNAL_DATA_PRESENT"

echo "EC2  EXTERNAL DATA   VOL $EC2_EXTERNAL_DATA_VOL"
echo "EC2  EXTERNAL DATA   SRC $EC2_EXTERNAL_DATA_SRC"
echo "EC2  EXTERNAL DATA   DST $EC2_EXTERNAL_DATA_DST"
echo "EC2  EXTERNAL DATA   PRE $EC2_EXTERNAL_DATA_PRESENT"




echo "export EC2_HOSTNAME=$EC2_HOSTNAME"                                > ~/.ec2
echo "export EC2_INST_ID=$EC2_INST_ID"                                 >> ~/.ec2
echo "export EC2_PUB_HOSTNAME=$EC2_PUB_HOSTNAME"                       >> ~/.ec2
echo "export EC2_PUB_IPV4=$EC2_PUB_IPV4"                               >> ~/.ec2
echo "export EC2_PRIV_HOSTNAME=$EC2_PRIV_HOSTNAME"                     >> ~/.ec2
echo "export EC2_PRIV_IPV4=$EC2_PRIV_IPV4"                             >> ~/.ec2
echo "export EC2_TYPE=$EC2_TYPE"                                       >> ~/.ec2
echo "export EC2_ARN=$EC2_ARN"                                         >> ~/.ec2
echo "export EC2_REGION=$EC2_REGION"                                   >> ~/.ec2

echo "export EC2_EXTERNAL_CONFIG_VOL=$EC2_EXTERNAL_CONFIG_VOL"         >> ~/.ec2
echo "export EC2_EXTERNAL_CONFIG_SRC=$EC2_EXTERNAL_CONFIG_SRC"         >> ~/.ec2
echo "export EC2_EXTERNAL_CONFIG_DST=$EC2_EXTERNAL_CONFIG_DST"         >> ~/.ec2
echo "export EC2_EXTERNAL_CONFIG_PRESENT=$EC2_EXTERNAL_CONFIG_PRESENT" >> ~/.ec2

echo "export EC2_EXTERNAL_DATA_VOL=$EC2_EXTERNAL_DATA_VOL"             >> ~/.ec2
echo "export EC2_EXTERNAL_DATA_SRC=$EC2_EXTERNAL_DATA_SRC"             >> ~/.ec2
echo "export EC2_EXTERNAL_DATA_DST=$EC2_EXTERNAL_DATA_DST"             >> ~/.ec2
echo "export EC2_EXTERNAL_DATA_PRESENT=$EC2_EXTERNAL_DATA_PRESENT"     >> ~/.ec2

echo "export DYN_HOST=$DYN_HOST"                                       >> ~/.ec2



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

updatedb

echo "DONE BEGIN"
python ~/ec2init/tools/sendsns --subject "I'm on baby" --file ~/.ec2
echo "SENDING MESSAGE"
