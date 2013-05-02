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

