set -xeu
#yum install gitolite3

#http://wasil.org/gitlab-installation-on-fedora-16-with-gitolite

#yum install -y make openssh-clients gcc libxml2 libxml2-devel  libxslt libxslt-devel python-devel libicu libicu-devel

#yum install -y ruby ruby-devel rubygems rubygem-rails rubygem-passenger rubygem-passenger-native rubygem-passenger-native-libs rubygem-bundler rubygems-devel

#yum install -y gcc-c++ curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel libcurl-devel redis

#easy_install pygments

#gem install charlock_holmes --version '0.6.9' &


#http://rickfoosusa.blogspot.nl/2011/08/gitolite-tutorial-senawario.html
sed -i 's/\/gitolite3\:\/bin\/sh/\/gitolite3\:\/bin\/bash/' /etc/passwd

sed 's/$password/'$GITLAB_PASS'/' mods/gitlab.sql | mysql -h localhost -u root -p$MYSQL_PASS


cp mods/gitlab1.sh /tmp/gitlab1.sh
cp mods/gitlab2.sh /tmp/gitlab2.sh





su - gitolite3 -c 'bash /tmp/gitlab1.sh'



if [[ -f "/var/lib/gitolite3/gitlab-shell/config.yml" ]]; then
	rm /var/lib/gitolite3/gitlab-shell/config.yml
fi
cp mods/gitlab-shell-config.yml.new /var/lib/gitolite3/gitlab-shell/config.yml
chown gitolite3:gitolite3 /var/lib/gitolite3/gitlab-shell/config.yml


if [[ -f "/var/lib/gitolite3/gitlab/config.yml" ]]; then
	rm /var/lib/gitolite3/gitlab/config.yml
fi
cp mods/gitlab-config.yml.new /var/lib/gitolite3/gitlab/config/config.yml
chown gitolite3:gitolite3 /var/lib/gitolite3/gitlab/config/config.yml

sed 's/\<PASSWORD\>/'$GITLAB_PASS'/' mods/gitlab-database.yml.new > /var/lib/gitolite3/gitlab/config/database.yml

curl --output /etc/init.d/gitlab https://raw.github.com/gitlabhq/gitlabhq/master/lib/support/init.d/gitlab
chmod +x /etc/init.d/gitlab
chkconfig --level 2345 gitlab on
chkconfig gitlab on


su - gitolite3 -c 'bash /tmp/gitlab2.sh'

