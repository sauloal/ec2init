useradd -s /sbin/nologin guests

if [[ ! -d "~/guests/.ssh" ]]; then
  mkdir ~/guests/.ssh
fi

cp mods/authorized_keys ~/guests/.ssh

chmod 400 ~/guests/.ssh
chmod 400 ~/guests/.ssh/authorized_keys
