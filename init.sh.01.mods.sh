#modifications to setup

#iSCSI
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
