yum install gitolite3
cd /var/lib/gitolite3/.ssh

ssh-keygen -t rsa -b 5120 -C saulo_git_aws -f id_rsa -N ''

chown gitolite3:gitolite3 *

su gitolite3 -c 'gitolite setup -pk id_rsa.pub'

#http://rickfoosusa.blogspot.nl/2011/08/gitolite-tutorial-senawario.html
sed -i 's/\/gitolite3\:\/bin\/sh/\/gitolite3\:\/bin\/bash/' /etc/passwd

su - gitolite3 -c 'cp /etc/skel/.* ~'

su - gitolite3 -c 'ln -s ~/.bashrc ~/.profile'

su - gitolite3 -c 'git clone gitolite3@localhost:gitolite-admin'


#http://wasil.org/gitlab-installation-on-fedora-16-with-gitolite

yum install make openssh-clients gcc libxml2 libxml2-devel  libxslt libxslt-devel python-devel 

yum install ruby rubygems rubygem-rails rubygem-passenger rubygem-passenger-native rubygem-passenger-native-libs rubygem-bundler

yum install -y gcc-c++ curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel libcurl-devel redis

easy_install pygments



