#!/bin/bash
# This script is run in the VM each time you run `vagrant-spk dev`.  This is
# the ideal place to invoke anything which is normally part of your app's build
# process - transforming the code in your repository into the collection of files
# which can actually run the service in production
#
# Some examples:
#
#   * For a C/C++ application, calling
#       ./configure && make && make install
#   * For a Python application, creating a virtualenv and installing
#     app-specific package dependencies:
#       virtualenv /opt/app/env
#       /opt/app/env/bin/pip install -r /opt/app/requirements.txt
#   * Building static assets from .less or .sass, or bundle and minify JS
#   * Collecting various build artifacts or assets into a deployment-ready
#     directory structure

export SANDSTORM=1
export RBENV_ROOT=/usr/local/rbenv
export RAILS_ENV=production
export DEVISE_SECRET=`base64 /dev/urandom | head -c 30`
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"
set -euo pipefail
cd /opt/app/loomio
bundle install --path /usr/local/lib/bundle --without test development
cp /etc/postgresql/9.4/main/*.conf /var/lib/postgresql/9.4/main
/usr/lib/postgresql/9.4/bin/postgres -D /var/lib/postgresql/9.4/main ||true &
cp /opt/app/database.yml /opt/app/loomio/config
rake db:setup
cd lineman
npm install
bower install --config.interactive=false
lineman build
cp -R dist/* ../public/
cd ..
echo Precompiling assets.
rake assets:precompile
echo Done.
killall postgres
mkdir -p /home/vagrant/scratch
pushd /home/vagrant/scratch
rm -f tmp
ln -s /tmp tmp
popd