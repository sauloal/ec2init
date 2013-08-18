#!/bin/python
#http://stackoverflow.com/questions/5251057/using-boto-to-find-to-which-device-and-ebs-volume-is-mounted
import os, sys
import time
import datetime
import subprocess
import argparse
import boto
import boto.ec2
import re
import shutil

DEFAULT_FS_TYPE='ext4'
DEFAULT_FS_OPTIONS='rw,user,auto,noatime,exec,relatime,seclabel,data=writeback,barrier=0,nobh,errors=remount-ro'

#http://devblog.seomoz.org/2011/08/launching-and-deploying-instances-with-boto-and-fabric/

parser = argparse.ArgumentParser(description='Attach EBS volume.')
parser.add_argument('-i', '--instance-id', dest='instance'   , default=None , action='store'      , metavar='INSTANCE'   , type=str, nargs='?', help='instance id [i-???????][EC2_INST_ID]')
parser.add_argument('-v', '--volume-id'  , dest='volume'     , default=None , action='store'      , metavar='VOLUME'     , type=str, nargs='?', help='volume id [vol-?????][EC2_EXTERNAL_VOL]')
parser.add_argument('-d', '--device'     , dest='device'     , default=None , action='store'      , metavar='DEVICE'     , type=str, nargs='?', help='destination device [/dev/????][EC2_EXTERNAL_SRC]')
parser.add_argument('-m', '--mount-point', dest='mount'      , default=None , action='store'      , metavar='MOUNT'      , type=str, nargs='?', help='mount point [/mnt/????][EC2_EXTERNAL_DST]')
parser.add_argument('-r', '--region'     , dest='region'     , default=None , action='store'      , metavar='REGION'     , type=str, nargs='?', help='region [eu-west-1b][EC2_REGION]')
parser.add_argument('-c', '--config-file', dest='config'     , default=None , action='store'      , metavar='CONFIG'     , type=str, nargs='?', help='config file')
parser.add_argument('-n', '--dry-run'    , dest='real'       , default=True , action='store_false',                                             help='dry run')

args     = parser.parse_args()
respaces = re.compile('\s+')
for_real = args.real

def main():
	fstab, setup = loadconfig()

	print "FSTAB", fstab
	print "SETUP", setup

	for vol in setup:
		print "checking", vol
		checksetup( setup[vol] )

	for vol in setup:
		print "ATTACHING", vol

		if setup[vol] is None: 
			print "ATTACHING", vol, "EMPTY. SKIPPING"
			continue

		if not setup[vol]['test']['exists'  ]: 
			print "ATTACHING", vol, "DOES NOT EXISTS. SKIPPING"
			continue

		if     setup[vol]['test']['attached']: 
			print "ATTACHING", vol, "ALREADY ATTACHED. SKIPPING"
			continue

		if not for_real: 
			print "ATTACHING", vol, "NOT FOR REAL. NOT ATTACHING. SKIPPING"
			continue

		attachvol(setup[vol])

	for vol in setup:
		if setup[vol] is None: continue
		mountvol(setup[vol], fstab)


def attachvol(vars):
	print "mapping volume %s to instance %s at device %s" % (vars['volume'], vars['instance'], vars['device'])

	vars['VOL'].attach(vars['instance'], vars['device'])

	print "mapped. waiting"
	time.sleep(10)
	print "checking mapping"

	if os.path.exists(vars['device']):
		print "  success"
	else:
		print "  failed"
		#sys.exit(1)


def mountvol(vars, fstab):
	mounted = subprocess.check_output(['mount'])
	vol     = vars['volume']
	dev     = vars['device']
	mount   = vars['mount' ]
	fstype  = vars['fstype']
	fsopt   = vars['fsopt' ]

	print "MOUNTING"
	print "MOUNTING :: DEV", dev,"MOUNT POINT",mount
	print "MOUNTING :: DEV", dev,"MOUNT POINT",mount,"FS TYPE", fstype,"FS OPT", fsopt



	if not mount in mounted:
		print "MOUNTING :: DEV", dev,"MOUNT POINT",mount,"MOUNTING"

		if not os.path.exists( mount ):
			print "MOUNTING :: DEV", dev,"MOUNT POINT",mount,"MOUNTING :: CREATING DIR"
			os.makedirs( mount )

		print "MOUNTING :: DEV", dev,"MOUNT POINT",mount,"MOUNTING :: MOUNTING :: RUNNING"

		res1 = subprocess.call( [ 'mount', dev, mount ] )

		if res1 != 0:
			print "MOUNTING :: DEV", dev,"MOUNT POINT",mount,"MOUNTING :: MOUNTING :: RUNNING :: FAILED", res1
			sys.exit(1)

		print "MOUNTING :: DEV", dev,"MOUNT POINT",mount,"MOUNTING :: MOUNTING :: RUNNING :: success"

	else:
		print "MOUNTING :: DEV", dev,"MOUNT POINT",mount,"ALREADY MOUNTED. SKIPPING"




	if args.config is not None and len(args.config) != 0 and os.path.exists(args.config):
		print "MOUNTING :: DEV", dev,"MOUNT POINT",mount,"ADDING TO FSTAB"
		if dev not in fstab:
			print "MOUNTING :: DEV", dev,"MOUNT POINT",mount,"ADDING TO FSTAB :: NOT IN FSTAB"
			ts  = time.time()
			st  = datetime.datetime.fromtimestamp(ts).strftime('%Y%m%d%H%M%S')
			bkp = "/tmp/fstab-" + st + '-' + vol
			shutil.copy( "/etc/fstab", bkp )
			print "MOUNTING :: DEV", dev,"MOUNT POINT",mount,"ADDING TO FSTAB :: NOT IN FSTAB :: BKP", bkp

			#dev, tgt, type, conf, st, nd
			#rw,user,auto,noatime,exec,relatime,seclabel,data=writeback,barrier=0,nobh,errors=remount-ro
			fscmd= "\n\n#%s\t%s\n%s\t%s\t%s\t%s\t%s" % ( vol, st, dev, mount, fstype, fsopt, '0\t0' )
			print "MOUNTING :: DEV", dev,"MOUNT POINT",mount,"ADDING TO FSTAB :: NOT IN FSTAB ::", fscmd
			open( '/etc/fstab', 'a+' ).write( fscmd )
		else:
			print "MOUNTING :: DEV", dev,"MOUNT POINT",mount,"ADDING TO FSTAB :: ALREADY IN FSTAB"

	else:
		print "MOUNTING :: DEV", dev,"MOUNT POINT",mount,"NOT ADDING TO FSTAB"


	#TODO: add to fstab
	#if [[ -z `grep $EC2_EXTERNAL_CONFIG_SRC /etc/fstab` ]]; then
	#    echo "adding external $EC2_EXTERNAL_CONFIG_SRC to fstab"
	#    #http://blog.smartlogicsolutions.com/2009/06/04/mount-options-to-improve-ext4-file-system-performance/
	#    #gid 19 = floppy
	#    #data=ordered
	  
	#    echo "$EC2_EXTERNAL_CONFIG_SRC   $EC2_EXTERNAL_CONFIG_DST        ext4    rw,user,auto,noatime,exec,relatime,seclabel,data=writeback,barrier=0,nobh,errors=remount-ro    0 0" >> /etc/fstab
	  
	#  else
	#    echo "external already in fstab"
	#  fi


def loadconfig():
	setup  = {}
	fstab  = {}
	
	vars   = loadvars()
	config = args.config
	
	if config is not None:
		if len(config) == 0:
			print "empty config file"
			sys.exit(1)

		if not os.path.exists(config):
			print "config file %s does not exists" % config
			sys.exit(1)

		with open('/etc/fstab', 'r') as ftb:
			for line in ftb:
				line         =       line.strip()
				if len(line) ==   0: continue
				if line[0]   == "#": continue
				cols = respaces.split( line )
				print "FSTAB COLS", cols
				#dev, tgt, type, conf, st, nd
				dev   = cols[0]
				mount = cols[1]
				fstab[ dev ] = mount

		with open(config, 'r') as cfg:
			for line in cfg:
				line         =       line.strip()
				if len(line) == 0  : continue
				if line[0]   == "#": continue

				cols = line.split(';')

				if len( cols ) != 7:
					print "wrong number of colums. %d. should be 7" % len(cols)
					print "VOLUME NAME;DEVICE NAME;MOUNT POINT;FS TYPE;FS MOUNT OPTIONS;REGION;INSTANCE"
					print line
					sys.exit( 1 )

				print "CONFIG COLS", cols
				##VOLUME NAME;DEVICE NAME;MOUNT POINT;FS TYPE;FS MOUNT OPTIONS;REGION;INSTANCE
				volume   = cols[0]
				device   = cols[1]
				mount    = cols[2]
			        fstype   = cols[3]
			        fsopt    = cols[4]
				region   = cols[5]
				instance = cols[6]

				if len(volume  ) == 0: volume   = None
				if len(device  ) == 0: device   = None
				if len(mount   ) == 0: mount    = None
				if len(fstype  ) == 0: fstype   = None
				if len(fsopt   ) == 0: fsopt    = None
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
					print "no mount defined in config file"
					parser.print_help()
					sys.exit(1)

				if fstype is None:
					print "no fs type defined in config file. using default", DEFAULT_FS_TYPE
					fstype = DEFAULT_FS_TYPE

				if fsopt is None:
					print "no fs mount options defined in config file. using default", DEFAULT_FS_OPTIONS
					fsopt = DEFAULT_FS_OPTIONS

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


				if volume in setup:
					print "repeated volume", volume
					print line
					print setup
					sys.exit( 1 )

				setup[ volume ] = {
							'device'  : device,
							'volume'  : volume,
							'mount'   : mount,
						        'fstype'  : fstype,
						        'fsopt'   : fsopt,
							'region'  : region,
							'instance': instance
						}

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

		setup[ vars['volume'] ] = {
						'device'  : vars['device'  ],
						'volume'  : vars['volume'  ],
						'mount'   : vars['mount'   ],
						'region'  : vars['region'  ],
						'instance': vars['instance']
					}

	vols   = []
	devs   = []
	mounts = []
	print "CHECKING CONFIG"
	for vol in setup:
		print "CHECKING CONFIG :: VOL", vol
		if vol in vols:
			print "repeated volume", vol
			sys.exit(1)
		vols.append( vol )

		dev = setup[ vol ][ 'device' ]
		print "CHECKING CONFIG :: VOL", vol,"DEV",dev
		if dev in devs:
			print "repeated device", dev
			sys.exit(1)
		devs.append( dev )

		mount = setup[ vol ][ 'mount' ]
		print "CHECKING CONFIG :: VOL", vol,"DEV",dev,"MOUNT",mount
		if mount in mounts:
			print "repeated mount point", mount
			sys.exit( 1 )
		mounts.append( mount )

		if dev in fstab:
			print "CHECKING CONFIG :: VOL", vol,"DEV",dev,"IN FSTAB"
			tgt = fstab[ dev ]
			if tgt != mount:
				print "CHECKING CONFIG :: VOL", vol,"DEV",dev,"IN FSTAB. TARGETS DO NOT MATCH"
				print "  FSTAB MOUNT POINT", tgt, "DOES NOT MATCH CONFIG MOUNT POINT", tgt
			else:
				print "CHECKING CONFIG :: VOL", vol,"DEV",dev,"IN FSTAB. TARGETS MATCH"
		else:
			print "CHECKING CONFIG :: VOL", vol,"DEV",dev,"not IN FSTAB"

	return (fstab, setup )


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


	vars['test'] = { }
	vols         = getavailablevolumes(region)
	if vars['volume'] in vols:
		print "volume %s found" % vars['volume']
		vars['test']['exists'] = True
		if vols[vars['volume']] is None:
			vars['test']['attached'] = True
			print "volume %s is already attached" % vars['volume']
			return None
		else:
			vars['test']['attached'] = False
			print "volume %s not attached. proceeding" % vars['volume']

	else:
		vars['test']['exists'] = False
		print "volume %s not found" % vars['volume']
		sys.exit(1)

	vars['VOL'] = vols[ vars['volume'] ]

	insts  = getavailableinstances(region)
	if vars['instance'] not in insts:
		vars['test']['hasinstance'] = False
		print "instance %s not found" % vars['instance']
		sys.exit(1)
	vars['test']['hasinstance'] = True
	

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
