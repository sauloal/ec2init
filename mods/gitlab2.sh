set -xeu 

cd ~ 

echo $PWD

cd gitlab-shell

cd bin

./install


cd ~

cd gitlab

bundle install --deployment --without development test postgres

bundle exec rake gitlab:setup RAILS_ENV=production

bundle exec rake db:seed_fu RAILS_ENV=production

nano environment.rb
nano gitlab.yml

bundle exec rake db:seed_fu RAILS_ENV=production

bundle install --deployment --without development test postgres

bundle exec rake gitlab:env:info RAILS_ENV=production

nano /etc/httpd/conf.d/gittab.conf

