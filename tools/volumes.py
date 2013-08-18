#!/bin/python
#http://stackoverflow.com/questions/5251057/using-boto-to-find-to-which-device-and-ebs-volume-is-mounted
import os, sys
import boto
import boto.ec2

#desiredregion = 'eu-west'

envregion = os.environ.get('EC2_REGION')
if envregion is None:
	print "no env EC2_REGION"
	sys.exit( 0 )

desiredregion = envregion


region  = None

regions = boto.ec2.regions()
for regioninfo in regions:
    #print regioninfo.name,
    if regioninfo.name == desiredregion:
         region = regioninfo
         print "%s *" % regioninfo.name
    #print

if region is None:
    print "not able to find to region %s" % desiredregion
    sys.exit(1)



ec2       = boto.connect_ec2( region=region )
res       = ec2.get_all_instances()
instances = [i for r in res for i in r.instances]
vol       = ec2.get_all_volumes()

def attachedvolumes():
    print 'Attached Volume ID - Instance ID','-','Device Name'
    for volumes in vol:
        if volumes.attachment_state() == 'attached':
            filter          = {'block-device-mapping.volume-id':volumes.id}
            volumesinstance = ec2.get_all_instances(filters=filter)
            ids             = [z for k in volumesinstance for z in k.instances]

            for s in ids:
                 print volumes.id,'-',s.id,'-',volumes.attach_data.device


# Get a list of unattached volumes
def unattachedvolumes():
   for unattachedvol in vol:
       state = unattachedvol.attachment_state()

       if state == None:
           print unattachedvol.id, state

print vol
attachedvolumes()
unattachedvolumes()

