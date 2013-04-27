#!/bin/python
#http://stackoverflow.com/questions/5251057/using-boto-to-find-to-which-device-and-ebs-volume-is-mounted
import os, sys
import argparse
import boto
import boto.ec2


#http://devblog.seomoz.org/2011/08/launching-and-deploying-instances-with-boto-and-fabric/

parser = argparse.ArgumentParser(description='Attach EBS volume.')
parser.add_argument('-i', '--instance-id', dest='instance'   , default=None, action='store', metavar='INSTANCE'   , type=str, nargs='?', help='instance id [i-???????][EC2_INST_ID]')
parser.add_argument('-v', '--volume-id'  , dest='volume'     , default=None, action='store', metavar='VOLUME'     , type=str, nargs='?', help='volume id [vol-?????][EC2_EXTERNAL_VOL]')
parser.add_argument('-d', '--destination', dest='destination', default=None, action='store', metavar='DESTINATION', type=str, nargs='?', help='destination device [/dev/????][EC2_EXTERNAL_SRC]')
parser.add_argument('-r', '--region'     , dest='region'     , default=None, action='store', metavar='REGION'     , type=str, nargs='?', help='region [eu-west][EC2_REGION]')

args = parser.parse_args()

svo  = args.volume
if svo       is None: 
	svo       = os.environ.get('EC2_EXTERNAL_VOL')
	if svo is None:
		print "no volume defined"
		parser.print_help()
		sys.exit(1)

src = args.destination
if src       is None:
	src       = os.environ.get('EC2_EXTERNAL_SRC')
	if src is None:
		print "no src defined" 
		parser.print_help()
		sys.exit(1)

iid = args.instance
if iid       is None: 
	iid       = os.environ.get('EC2_INST_ID')
	if iid is None:
		print "no instance id"
		parser.print_help()
		sys.exit(1)

envregion = args.region
if envregion is None: 
	envregion = os.environ.get('EC2_REGION')
	if envregion is None:
		print "no region"
		parser.print_help()
		sys.exit(1)

print "volume %s src %s instance id %s region %s" % (svo, src, iid, envregion)


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
   print "mapping volume %s to instance %s from %s" % (svo, iid, src)

   success = False
   for unattachedvol in vol:
       state = unattachedvol.attachment_state()

       if state == None:
           print unattachedvol.id, state
           if unattachedvol.id == svo:
               success = True
               print "  mapping volume %s to instance %s at device %s" % (unattachedvol.id, iid, src)
               unattachedvol.attach(iid, src)
   if success:
      print "success"
   else:
      print "not found"

print vol
unattachedvolumes()

attachosvol()
