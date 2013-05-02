cd ~/.ssh

ssh-keygen -t rsa -b 5120 -C saulo_git_aws -f id_rsa -N ''

chown gitolite3:gitolite3 *

#http://rickfoosusa.blogspot.nl/2011/08/gitolite-tutorial-senawario.html

gitolite setup -pk id_rsa.pub

cd ~

cp /etc/skel/.* ~

ln -s ~/.bashrc ~/.profile

git clone gitolite3@localhost:gitolite-admin

