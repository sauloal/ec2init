echo "ATTACHING VOLUME"
echo "ATTACHING VOLUME $EC2_EXTERNAL_DATA_VOL TO INSTANCE $EC2_INST_ID TO DEVICE $EC2_EXTERNAL_DATA_SRC"
echo "ATTACHING VOLUME $EC2_EXTERNAL_CONFIG_VOL TO INSTANCE $EC2_INST_ID TO DEVICE $EC2_EXTERNAL_CONFIG_SRC"

python ~/ec2init/tools/attachvolume.py -i $EC2_INST_ID -r $EC2_REGION -c ~/ec2init/mods/disks.cfg
#-v $EC2_EXTERNAL_VOL -d $EC2_EXTERNAL_SRC -r $EC2_REGION

echo "VOLUME ATTACHED"


