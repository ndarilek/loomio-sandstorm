#!/bin/bash
set -euo pipefail
# This script is run in the VM once when you first run `vagrant-spk up`.  It is
# useful for installing system-global dependencies.  It is run exactly once
# over the lifetime of the VM.
#

curl -sL https://deb.nodesource.com/setup_0.10 | sudo -E bash -
apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get dist-upgrade -y
apt-get install -y git postgresql postgresql-contrib libpq-dev g++ imagemagick libmagickcore-6.q16-dev libmagickwand-6-headers pkg-config nodejs
git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
export RBENV_ROOT=/usr/local/rbenv
export PATH="$RBENV_ROOT/bin:$PATH"
export RBENV_VERSION=2.2.3
eval "$(rbenv init -)"
rbenv install $RBENV_VERSION
gem install bundler uuid
npm install -g bower lineman
su postgres -c "createuser -s vagrant"
mkdir /usr/local/lib/bundle
systemctl stop postgresql
systemctl disable postgresql
cp /opt/app/postgresql.conf /opt/app/pg_hba.conf /etc/postgresql/9.4/main
mkdir -p /var/files
chown -R 1000.1000 /var/lib/postgresql /var/run/postgresql /etc/postgresql /usr/local/lib/bundle /var/files
