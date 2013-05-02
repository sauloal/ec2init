#!/usr/bin/python
import subprocess
import os, sys
import re

randon_seqs = subprocess.check_output("pwgen -sy 50 200 | grep -v \\' | grep -v '\\\\'", shell=True)

randon_seqs = randon_seqs.split("\n")

#sys.stderr.write( str( randon_seqs ) )

data = {
	'WP DB NAME'  : os.environ['WP_DB_NAME'],
	'WP USER NAME': os.environ['WP_USER_NAME'],
	'WP PASSWORD' : os.environ['WP_PASSWORD'],
}

for i in range(1,9):
	data['WP PHRASE '+str(i)] = randon_seqs[i]

#sys.stderr.write( str( data ) )

#<WP DB NAME>
#<WP USER NAME>
#<WP PASSWORD>
#<WP PHRASE 1>
#<WP PHRASE 2>
#<WP PHRASE 3>
#<WP PHRASE 4>
#<WP PHRASE 5>
#<WP PHRASE 6>
#<WP PHRASE 7>
#<WP PHRASE 8>


try:
	template = sys.argv[1]
except:
	sys.stderr.write( "not template given\n" )
	sys.exit(1)


if not os.path.exists(template):
	sys.stderr.write( "template file %s does not exists\n" )
	sys.exit(1)

m = re.compile("\<(.+?)\>")

with open(template, 'r') as tpl:
	for line in tpl:
		line    = line.strip()
		results = m.finditer(line)
		if results is not None:
			nline = line
			for result in results:
				tgt = result.group(0)
				grp = result.group(1)
				if grp in data:
					val   = data[grp]
					nline = nline.replace(tgt, val)
			print nline
		else:
			print line
