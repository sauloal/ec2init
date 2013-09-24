echo "ATTACHING VOLUMES"

python ~/ec2init/tools/attachvolume.py -c ~/ec2init/mods/disks.cfg -r $EC2_REGION -i $EC2_INST_ID

#python ~/ec2init/tools/attachvolume.py -i $EC2_INST_ID -r $EC2_REGION -c ~/ec2init/mods/disks.cfg
#-v $EC2_EXTERNAL_VOL -d $EC2_EXTERNAL_SRC -r $EC2_REGION

echo "VOLUMES ATTACHED"


