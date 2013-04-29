cd /tmp	


#wget -O s3cmd-1.5.0-alpha3.tar.gz 'http://downloads.sourceforge.net/project/s3tools/s3cmd/1.5.0-alpha3/s3cmd-1.5.0-alpha3.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fs3tools%2Ffiles%2Fs3cmd%2F1.5.0-alpha1%2F&ts=1365723111&use_mirror=heanet'

#./s3cmd ls | gawk '{print $3}' | xargs -I{} bash -c 'echo "mkdir /mnt/external/s3/`basename {}`; ./s3cmd --rexclude \"\/\$\" --skip-existing sync {} /mnt/external/s3/"`basename {}`"/"' > cmds

if [[ ! -d "s3cmd" ]]; then
	git clone https://github.com/s3tools/s3cmd
fi

cd s3cmd

git pull

python setup.py install

cd ~/ec2init

cp mods/s3cfg.new ~/.s3cfg
chmod 400 ~/.s3cfg

sed -i "s/<access>/$EC2_ACCESS_KEY/"        ~/.s3cfg
sed -i "s/<secret>/$EC2_SECRET_ACCESS_KEY/" ~/.s3cfg
