set -xeu
#yum install gitolite3

#http://wasil.org/gitlab-installation-on-fedora-16-with-gitolite

#yum install make openssh-clients gcc libxml2 libxml2-devel  libxslt libxslt-devel python-devel 

#yum install ruby rubygems rubygem-rails rubygem-passenger rubygem-passenger-native rubygem-passenger-native-libs rubygem-bundler

#yum install -y gcc-c++ curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel libcurl-devel redis

#easy_install pygments




#http://rickfoosusa.blogspot.nl/2011/08/gitolite-tutorial-senawario.html
sed -i 's/\/gitolite3\:\/bin\/sh/\/gitolite3\:\/bin\/bash/' /etc/passwd

sed 's/$password/'$GITLAB_PASS'/' mods/gitlab.sql | mysql -h localhost -u root -p$MYSQL_PASS


cp mods/gitlab1.sh /tmp/gitlab1.sh
cp mods/gitlab2.sh /tmp/gitlab2.sh


su - gitolite3 -c 'bash /tmp/gitlab1.sh'

if [[ -f "/var/lib/gitolite3/gitlab-shell/config.yml" ]]; then
	rm /var/lib/gitolite3/gitlab-shell/config.yml
fi

cp mods/gitlab-config.yml.new /var/lib/gitolite3/gitlab-shell/config.yml

chown gitolite3:gitolite3 /var/lib/gitolite3/gitlab-shell/config.yml

su - gitolite3 -c 'bash /tmp/gitlab2.sh'

