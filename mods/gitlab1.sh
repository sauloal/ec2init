set -xeu

cd ~

echo $PWD

if [[ ! -d 'gitlab-shell' ]]; then
	git clone https://github.com/gitlabhq/gitlab-shell.git
fi

cd gitlab-shell/

git checkout v1.4.0


