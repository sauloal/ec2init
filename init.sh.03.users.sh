
if [[ ! -d "/home/guests" ]]; then
	echo "adding guests user"
	useradd -s /sbin/nologin guests
else
	echo "guests user already exists"
fi


if [[ ! -d "/home/guests/.ssh" ]]; then
	echo "creating .ssh folder"
 	mkdir ~guests/.ssh
else
	echo ".ssh folder already exists"
fi

echo copying authorized keys
cp mods/authorized_keys ~guests/.ssh

echo changing permission of authorized keys
chmod 400 ~guests/.ssh
chmod 400 ~guests/.ssh/authorized_keys
