#wget -O s3cmd-1.5.0-alpha3.tar.gz 'http://downloads.sourceforge.net/project/s3tools/s3cmd/1.5.0-alpha3/s3cmd-1.5.0-alpha3.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fs3tools%2Ffiles%2Fs3cmd%2F1.5.0-alpha1%2F&ts=1365723111&use_mirror=heanet'

#./s3cmd ls | gawk '{print $3}' | xargs -I{} bash -c 'echo "mkdir /mnt/external/s3/`basename {}`; ./s3cmd --rexclude \"\/\$\" --skip-existing sync {} /mnt/external/s3/"`basename {}`"/"' > cmds
