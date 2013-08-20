#puppet apply --verbose --noop --debug --graph profile.pp

$DYN_HOST="as"
$DEFAULT_USER=fedora

$EC2_ACCESS_KEY="as"
$EC2_SECRET_ACCESS_KEY="as"


#puppetlabs-stdlib
#puppetlabs-ruby
#puppetlabs-rsync
#puppetlabs-mysql
#puppetlabs-java
#puppetlabs-git
#puppetlabs-gcc
#puppetlabs-apache

#include httpd



include essentials


#class { 'sshd': conf => 'puppet:///modules/sshd/sshd_config' }
class { 'sshd': conf => '/root/ec2init/mods/sshd_config' }


nologinuser{ 'guests': user => 'guests', gid=>6006 } ->


#'puppet:///modules/sshd/authorized keys'
ssh { 'guests'     : source => '/root/ec2init/mods/authorized_keys_guests',  } ->
ssh { $DEFAULT_USER: source => '/root/ec2init/mods/authorized_keys_default', } ->



ec2{ 'root'  : user => 'root',  } ->
ec2{ 'fedora': user => 'fedora',} 





define ssh ( $user=$title, $source ) {
	file {
		"/home/${user}/.ssh":
			ensure  => directory,
			mode    => 0700,
			owner   => $user,
			group   => $user,
	}

	file {
		"/home/${user}/.ssh/authorized_keys":
			ensure  => present,
			path    => "/home/${user}/.ssh/authorized_keys",
			mode    => 0600,
			owner   => $user,
			group   => $user,
			#TODO
			source  => $source,
	}

	notify {
		"finished ssh ${user}":
			require => File["/home/${user}/.ssh", "/home/${user}/.ssh/authorized_keys"],
	}

	File["/home/${user}/.ssh"]->File["/home/${user}/.ssh/authorized_keys"]
}



class sshd ( $conf ) {
	package {
		'openssh-server':
			ensure => present,
			before => File['/etc/ssh/sshd_config'],
	}

	file {
		'/etc/ssh/sshd_config':
			ensure => file,
			mode   => 600,
			owner  => 'root',
			group  => 'root',
			source => $conf,
	}

	service {
		'sshd':
			ensure    => running,
			enable    => true,
			subscribe => File['/etc/ssh/sshd_config'],
	}
}



class httpd {
	case $operatingsystem {
		centos, redhat: { $apache = "httpd" }
		debian, ubuntu: { $apache = "apache2" }
		default: { fail("Unrecognized operating system for webserver") }
	}
	
	package {
		$apache:
			ensure => installed,
	}
}



define nologinuser ( $user=$title, $gid ) {
	user { 
		$user:
			ensure     => present,
			comment    => "{$user} user account",
			uid        => $gid,
			gid        => $gid,
			shell      => '/sbin/nologin',
			home       => "/home/${user}",
			managehome => true,
			password   => '',
	}
}



define ec2 ($user=$title) {
	if ( $user == 'root' ) {
		$home='/root'
	} else {
		$home="/home/${user}"
	}
	
	file {
		"${home}/.boto":
			ensure  => file,
			mode    => 0400,
			owner   => $user,
			group   => $user,
			content =>"\
[Credentials]
aws_access_key_id = ${EC2_ACCESS_KEY}
aws_secret_access_key = ${EC2_SECRET_ACCESS_KEY}
"
	}
	
	file {
		"${home}/.passwd-s3fs":
			ensure  => file,
			mode    => 0400,
			owner   => $user,
			group   => $user,
			content => "${EC2_ACCESS_KEY}:${EC2_SECRET_ACCESS_KEY}"
	}

	#TODO: curl "https://${DYN_LOGIN}:${DYN_PASS}@www.dnsdynamic.org/api/?hostname=$DYN_HOST&myip=$EC2_PUB_IPV4" 2>/dev/null

	#  ec2_{EC2 INSTANCE DATA}: 
	#    ec2_ami_id         , ec2_hostname   , 
	#    ec2_instance_id    , ec2_local_hostname , 
	#    ec2_local_ipv4     , ec2_placement_availability_zone, 
	#    ec2_public_hostname, ec2_public_ipv4, 
	#    ec2_public_keys_0_openssh_key

	#TODO: EC2_ARN, EC2_TYPE
	file {
		"${home}/.ec2":
			ensure  => file,
			mode    => 0400,
			owner   => $user,
			group   => $user,
			content => "\
export EC2_HOSTNAME=${ec2_hostname}
export EC2_INST_ID=${ec2_instance_id}
export EC2_PUB_HOSTNAME=${ec2_public_hostname}
export EC2_PUB_IPV4=${ec2_public_ipv4}
export EC2_PRIV_HOSTNAME=${ec2_local_hostname}
export EC2_PRIV_IPV4=${ec2_local_ipv4}
#export EC2_TYPE=${EC2_TYPE}
#export EC2_ARN=${EC2_ARN}
export EC2_REGION=${ec2_placement_availability_zone}
export DYN_HOST=${DYN_HOST}"
	}


	#TODO
	#if [[ -z `grep /.ec2 /etc/profile.d/saulo.sh` ]]; then 
	#	echo 'modifying bashrc'
	#	echo 'if [[ -f "~/.ec2" ]]; then' >> /etc/profile.d/saulo.sh
	#        echo '	source ~/.ec2'            >> /etc/profile.d/saulo.sh
	#	echo 'fi'                         >> /etc/profile.d/saulo.sh
	#	echo "PATH=$PATH:$BASE/tools" >> /etc/profile.d/saulo.sh

	#else
	#	echo 'bashrc already modified'
	#	grep /.ec2 /etc/profile.d/saulo.sh
	#fi
}


class essentials {
	Package { ensure => installed }

	exec { 'clean 1': command => '/usr/bin/yum clean all' }
	exec { 'update' : command => '/usr/bin/yum update'    }
	exec { 'clean 2': command => '/usr/bin/yum clean all' }

	$deps = [
				'deltarpm', 
				'psmisc', 
				'mlocate', 
				'which', 
				'htop', 
				'audit', 
				'glibc-headers', 
				'binutils', 
				'coreutils', 
				'moreutils', 
				'libxml', 
				'libxml-devel', 
				'libxml2', 
				'libxml2-devel', 
				'cloud-utils', 
				'wget', 
				'screen', 
				'byobu', 
				'nano', 
				'patch', 
				'unzip', 
				'perl-CPAN ', 
				'libcurl', 
				'libcurl-devel', 
				'fuse-devel', 
				'fuse', 
				'kernel-devel', 
				'gcc-c++', 
				'gcc', 
				'automake', 
				'make', 
				'python-devel', 
				'sqlite', 
			]
	
	package { $deps: }

	exec { 'clean 3': command => '/usr/bin/yum clean all' }

	Exec['clean 1']->Exec['update']->Exec['clean 2']->Package[$deps]->Exec['clean 3']
}











#if [[ -z `yum list installed | gawk '{print $1}' | grep rpmfusion-free` ]]; then
#	wget -O /tmp/fusion_free.rpm  http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-18.noarch.rpm
#	yum install -yt --skip-broken /tmp/fusion_free.rpm
#else
#	echo "rpm fusion free alaready installed"
#fi



#if [[ -z `yum list installed | gawk '{print $1}' | grep rpmfusion-nonfree` ]]; then
#	wget -O /tmp/fusion_nfree.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-18.noarch.rpm
#	yum install -yt --skip-broken /tmp/fusion_nfree.rpm
#else
#	echo "rpm fusion non free alaready installed"
#fi



#yum remove java java-devel

#if [[ -z `yum list installed | grep jre.i586` ]]; then
#	wget -O /tmp/jre.rpm 'http://javadl.sun.com/webapps/download/AutoDL?BundleId=76850'
#	yum install -yt --skip-broken /tmp/jre.rpm
#else
#	echo "jre already installed"
#fi





#easy_install boto
#easy_install boto_rsync
#easy_install boto_utils
#echo 'export JAVA_HOME=/usr/java/latest' >> /etc/profile.d/saulo.sh


#python ~/ec2init/tools/attachvolume.py -c ~/ec2init/mods/disks.cfg -r $EC2_REGION -i $EC2_INST_ID
#yum clean all
#updatedb
#python ~/ec2init/tools/sendsns --subject "I'm on baby" --file ~/.ec2





#http://forge.puppetlabs.com/
#facts: http://docs.puppetlabs.com/facter/latest/core_facts.html
#  blockdevices (Returns a comma-separated list of block devices)
#  ec2_{EC2 INSTANCE DATA}: ec2_ami_id, ec2_hostname, ec2_instance_id, ec2_local_hostname, ec2_local_ipv4, ec2_placement_availability_zone, ec2_public_hostname, ec2_public_ipv4, ec2_public_keys_0_openssh_key
#  fqdn (Returns the fully qualified domain name of the host)
#  hostname
#  interfaces
#  ipaddress
#  kernel
#  macaddress
#  memorytotal
#  path
#  physicalprocessorcount
#  processorcount
#  selinux (Determine whether SE Linux is enabled on the node)
#  selinux_config_mode (Returns the configured SE Linux mode)
#  selinux_enforced (Returns whether SE Linux is enabled)


