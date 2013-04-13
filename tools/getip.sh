ifconfig | perl -ne '
BEGIN { print "my IPs are :: " } 
END { 
  my $out = `curl -s http://checkip.dyndns.com/`; 
	if ( $out =~ /Current IP Address: ([0-9\.]+)/ ) 
	{ 
		print "; OUT: $1";
	} 
} 

if (/inet addr:(\S+)/) 
{ 
	print "$1"
}; 

if (/^(\S+)/) 
{ 
	print "; $1: "
}'
