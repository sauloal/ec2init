#modifications to setup

if [[ 0 -eq 1 ]]; then

##################
# iSCSI
##################
#/etc/tgt/targets.conf
#ignore-errors yes

#<target iqn.2012-04.ec2-54-228-22-35.eu-west-1.compute.amazonaws.com:disk>
#        backing-store /dev/xvdg
#        #initiator-address 54.228.22.35
#        incominguser saulo pass
#</target>


#/lib/systemd/system/tgtd.service
## see bz 848942. workaround for a race for now.
#ExecStartPost=sleep 5

## see bz 848942. workaround for a race for now.
#ExecStartPost=/bin/sleep 10



##################
# NFS
##################
#TODO:
#http://www.learnbydoingit.org/2013/01/configuring-nfs-server-on-fedora-18/
vi /etc/idmapd.conf

# line 5: uncomment and change to your domain name

Domain = server.world

[root@master ~]# vi /etc/exports

# write like below *note 
/home 10.0.0.0/24(rw,sync,no_root_squash,no_all_squash)

# *note 
/home ⇒ shared directory 
10.0.0.0/24 ⇒ range of networks NFS permits accesses 
rw ⇒ writable 
sync ⇒ synchronize 
no_root_squash ⇒ enable root privilege 
no_all_squash ⇒ enable users’ authority




##################
# SAMBA
##################
#http://www.howtoforge.com/fedora-18-samba-standalone-server-with-tdbsam-backend
vi /etc/samba/smb.conf

[...]
[allusers]
  comment = All Users
  path = /home/shares/allusers
  valid users = @users
  force group = users
  create mask = 0660
  directory mask = 0771
  writable = yes
If you want all users to be able to read and write to their home directories via Samba, add the following lines to /etc/samba/smb.conf (make sure you comment out or remove the other [homes] section in the smb.conf file!):

[...]
[homes]
   comment = Home Directories
   browseable = no
   valid users = %S
   writable = yes
   create mask = 0700
   directory mask = 0700

useradd tom -m -G users

Set a password for tom in the Linux system user database. If the user tom should not be able to log into the Linux system, skip this step.

passwd tom

-> Enter the password for the new user.

Now add the user to the Samba user database:

smbpasswd -a tom

fi
