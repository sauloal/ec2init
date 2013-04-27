#!/bin/python
#http://stackoverflow.com/questions/5251057/using-boto-to-find-to-which-device-and-ebs-volume-is-mounted
import os
import argparse
import boto
import boto.ec2


#http://devblog.seomoz.org/2011/08/launching-and-deploying-instances-with-boto-and-fabric/
svo       = os.environ.get('EC2_EXTERNAL_VOL')
src       = os.environ.get('EC2_EXTERNAL_SRC')
iid       = os.environ.get('EC2_INST_ID')
envregion = os.environ.get('EC2_REGION')


parser = argparse.ArgumentParser(description='Attach EBS volume.')
parser.add_argument('-i', '--instance-id', metavar='INSTANCE'   , type=str, nargs=1, help='instance id [i-???????][EC2_INST_ID]')
parser.add_argument('-v', '--volume-id'  , metavar='VOLUME'     , type=str, nargs=1, help='volume id [vol-?????][EC2_EXTERNAL_VOL]')
parser.add_argument('-d', '--destination', metavar='DESTINATION', type=str, nargs=1, help='destination device [/dev/????][EC2_EXTERNAL_SRC]')
parser.add_argument('-r', '--region'     , metavar='REGION'     , type=str, nargs=1, help='region [eu-west][EC2_REGION]')


if svo       is None: sys.exit(0)
if src       is None: sys.exit(0)
if iid       is None: sys.exit(0)
if envregion is None: sys.exit(0)


#desiredregion = 'eu-west'

desiredregion  = envregion

region         = None

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


# Get a list of unattached volumes
def unattachedvolumes():
   for unattachedvol in vol:
       state = unattachedvol.attachment_state()

       if state == None:
           print unattachedvol.id, state

def attachosvol():
   print "mapping volume %s to instance %s from %s to %s" % (svo, iid, src, dst)

   for unattachedvol in vol:
       state = unattachedvol.attachment_state()

       if state == None:
           print unattachedvol.id, state
           if unattachedvol.id == svo:
               print "  mapping volume %s to instance %s at device %s" % (unattachedvol.id, iid, src)
               unattachedvol.attach(iid, src)

print vol
unattachedvolumes()

attachosvol()
