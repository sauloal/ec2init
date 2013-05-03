set -xeu

cd ~

echo $PWD

if [[ ! -d 'gitlab-shell' ]]; then
	git clone https://github.com/gitlabhq/gitlab-shell.git
fi

cd gitlab-shell/

git checkout v1.4.0






cd ~
mkdir gitlab-satellites

if [[ ! -d "gitlab" ]]; then
	git clone https://github.com/gitlabhq/gitlabhq.git gitlab
fi

cd gitlab

git checkout 5-1-stable

mkdir tmp/pids
mkdir tmp/sockets

cd config
#if [[ ! -f "puma.rb" ]]; then
	#cp puma.rb.example puma.rb
#fi


