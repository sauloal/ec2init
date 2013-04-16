#modifications to setup
cp --no-preserve=all mods/sshd_config.new /etc/ssh/sshd_config

######################
# SSH
######################
#https://wiki.archlinux.org/index.php/Sshfs
#http://ubuntuforums.org/showthread.php?t=1182295
#TODO:
# /etc/passwd:
# user:1003:1003:User,,,:/:/usr/sbin/nologin
#
#/etc/group:
#sftp:1004:user
#
#/etc/ssh/sshd_config:
# Logging
#SyslogFacility AUTH
#LogLevel DEBUG
#Subsystem sftp internal-sftp
#Match group sftp
#ForceCommand internal-sftp
#ChrootDirectory /var/sshbox

#http://serverfault.com/questions/431169/is-it-possible-to-allow-key-based-authentication-for-sshd-cofnig-chroot-sftp-use
#OR:
#Match Group sftpusers
#        ChrootDirectory /sftp/%u
#        ForceCommand internal-sftp
#        PubkeyAuthentication yes
#        AuthorizedKeysFile     %h/.ssh/authorized_keys

