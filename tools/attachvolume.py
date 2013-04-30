#!/bin/python
#http://stackoverflow.com/questions/5251057/using-boto-to-find-to-which-device-and-ebs-volume-is-mounted
import os, sys
import time
import subprocess
import argparse
import boto
import boto.ec2


#http://devblog.seomoz.org/2011/08/launching-and-deploying-instances-with-boto-and-fabric/

parser = argparse.ArgumentParser(description='Attach EBS volume.')
parser.add_argument('-i', '--instance-id', dest='instance'   , default=None, action='store', metavar='INSTANCE'   , type=str, nargs='?', help='instance id [i-???????][EC2_INST_ID]')
parser.add_argument('-v', '--volume-id'  , dest='volume'     , default=None, action='store', metavar='VOLUME'     , type=str, nargs='?', help='volume id [vol-?????][EC2_EXTERNAL_VOL]')
parser.add_argument('-d', '--device'     , dest='device'     , default=None, action='store', metavar='DEVICE'     , type=str, nargs='?', help='destination device [/dev/????][EC2_EXTERNAL_SRC]')
parser.add_argument('-m', '--mount-point', dest='mount'      , default=None, action='store', metavar='MOUNT'      , type=str, nargs='?', help='mount point [/mnt/????][EC2_EXTERNAL_DST]')
parser.add_argument('-r', '--region'     , dest='region'     , default=None, action='store', metavar='REGION'     , type=str, nargs='?', help='region [eu-west][EC2_REGION]')
parser.add_argument('-c', '--config-file', dest='config'     , default=None, action='store', metavar='CONFIG'     , type=str, nargs='?', help='config file')

args = parser.parse_args()


def main():
	setup = loadconfig()

	for vol in setup:
		print "checking", vol
		setup[vol] = checksetup(setup[vol])

	for vol in setup:
		print "attaching", vol
		if setup[vol] is None: continue
		attachvol(setup[vol])

	for vol in setup:
		print "mounting", vol
		if setup[vol] is None: continue
		mountvol(setup[vol])


def attachvol(vars):
	print "mapping volume %s to instance %s at device %s" % (vars['volume'], vars['instance'], vars['device'])

	vars['VOL'].attach(vars['instance'], vars['device'])

	print "mapped. waiting"
	time.sleep(10)
	print "checking mapping"

	if os.path.exists(vars['device']):
		print "  success"
	else:
		print "  vailed"
		#sys.exit(1)


def mountvol(vars):
	mounted = subprocess.check_output(['mount'])

	if vars['mount'] in mounted:
		print "already mounted"
		return
	else:
		print "not mounted. mounting"

	if not os.path.exists(vars['mount']):
		os.makedirs(vars['mount'])

	res1 = subprocess.call( [ 'mount', vars['device'], vars['mount'] ] )

	if res1 != 0:
		print "  failed"
		sys.exit(1)
	else:
		print "  success"


def loadconfig():
	setup  = {}
	
	vars   = loadvars()
	config = args.config
	
	if config is not None:
		if len(config) == 0:
			print "empty config file"
			sys.exit(1)

		if not os.path.exists(config):
			print "config file %s does not exists" % config
			sys.exit(1)

		with open(config, 'r') as cfg:
			for line in cfg:
				line = line.strip()
				if len(line) == 0: continue
				if line[0] == "#": continue
				cols = line.split("\t")

				print cols
				##VOLUME NAME    DEVICE NAME     MOUNT POINT     REGION  INSTANCE
				volume   = cols[0]
				device   = cols[1]
				mount    = cols[2]
				region   = ""
				instance = ""

				if len(cols)> 3:
					region   = cols[3]
				if len(cols)> 4:
					instance = cols[4]

				if len(volume  ) == 0: volume   = None
				if len(device  ) == 0: device   = None
				if len(mount   ) == 0: mount    = None
				if len(region  ) == 0: region   = None
				if len(instance) == 0: instance = None

				if volume is None:
					print "no volume defined in config file"
					parser.print_help()
					sys.exit(1)

				if device is None:
					print "no device defined in config file"
					parser.print_help()
					sys.exit(1)

				if mount is None:
					print "no mount defined defined in config file"
					parser.print_help()
					sys.exit(1)

				if region is None:
					if vars['region'] is not None:
						region = vars['region']
					else:
						print "no region defined in config file nor command line nor environment"
						parser.print_help()
						sys.exit(1)

				if instance is None:
					if vars['instance'] is not None:
						instance = vars['instance']
					else:
						print "no instance defined in config file nor command line nor environment"
						parser.print_help()
						sys.exit(1)



				setup[ volume ] = {
							'device'  : device,
							'volume'  : volume,
							'mount'   : mount,
							'region'  : region,
							'instance': instance
						}
		return setup

	else: #no config file
		if vars['volume'] is None:
			print "no volume defined"
			parser.print_help()
			sys.exit(1)

		if vars['device'] is None:
			print "no device defined" 
			parser.print_help()
			sys.exit(1)

		if vars['mount'] is None:
			print "no mount point defined" 
			parser.print_help()
			sys.exit(1)

		if vars['instance'] is None:
			print "no instance id defined"
			parser.print_help()
			sys.exit(1)

		if vars['region'] is None:
			print "no region defined"
			parser.print_help()
			sys.exit(1)

		return {
				vars['volume']: {
						'volume'  : vars['volume'  ],
						'device'  : vars['device'  ],
						'mount'   : vars['mount'   ],
						'region'  : vars['region'  ],
						'instance': vars['instance']
					}
			}


def loadvars():
	svo  = args.volume
	if svo       is None: 
		svo       = os.environ.get('EC2_EXTERNAL_VOL')

	dev = args.device
	if dev       is None:
		dev       = os.environ.get('EC2_EXTERNAL_SRC')

	mnt = args.mount
	if mnt       is None:
		mnt       = os.environ.get('EC2_EXTERNAL_DST')

	iid = args.instance
	if iid       is None: 
		iid       = os.environ.get('EC2_INST_ID')

	envregion = args.region
	if envregion is None: 
		envregion = os.environ.get('EC2_REGION')

	return {
		'volume'  : svo,
		'device'  : dev,
		'mount'   : mnt,
		'instance': iid,
		'region'  : envregion
	}


def checksetup(vars):
	#vars['volume']: {
	#	'volume'  : vars['volume'  ],
	#	'device'  : vars['device'  ],
	#	'mount'   : vars['mount'   ],
	#	'region'  : vars['region'  ],
	#	'instance': vars['instance']
	#	}

	print "volume %s src %s instance id %s region %s" % (vars['volume'], vars['device'], vars['instance'], vars['region'])
	print vars

	region = getregion( vars['region'] )


	vols   = getavailablevolumes(region)
	if vars['volume'] in vols:
		print "volume %s found" % vars['volume']
		if vols[vars['volume']] is None:
			print "volume %s is already attached" % vars['volume']
			return None
		else:
			print "volume %s not attached. proceeding" % vars['volume']

	else:
		print "volume %s not found" % vars['volume']
		sys.exit(1)

	vars['VOL'] = vols[ vars['volume'] ]

	insts  = getavailableinstances(region)
	if vars['instance'] not in insts:
		print "instance %s not found" % vars['instance']
		sys.exit(1)

	return vars
	

def getregion(desiredregion):
	#desiredregion = 'eu-west'
	print "checking regions %s" % desiredregion
	region         = None

	regions = boto.ec2.regions()
	for regioninfo in regions:
	    #print regioninfo.name
	    if desiredregion.startswith( regioninfo.name ):
        	 region = regioninfo
	         print "%s *" % regioninfo.name
	    #print

	if region is None:
	    print "not able to find to region %s" % desiredregion
	    sys.exit(1)

	return region


def getavailableinstances(region):
	ec2       = boto.connect_ec2( region=region )
	res       = ec2.get_all_instances()
	instances = [i for r in res for i in r.instances]

	insts     = {}

	for inst in instances:
		print "instance %s running" % inst.id
		insts[inst.id] = inst

	return insts


def getavailablevolumes(region):
	ec2       = boto.connect_ec2( region=region )
	vol       = ec2.get_all_volumes()

	print region
	print vol
	vols      = {}
	# Get a list of unattached volumes
	for unattachedvol in vol:
		state = unattachedvol.attachment_state()

	       	if state == None:
        		print unattachedvol.id, state
			vols[ unattachedvol.id ] = unattachedvol
		else:
			vols[ unattachedvol.id ] = None

	return vols



if __name__ == "__main__": main()
