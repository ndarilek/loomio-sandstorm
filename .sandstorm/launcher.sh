#!/bin/bash
# set -euo pipefail
# This script is run every time an instance of our app - aka grain - starts up.
# This is the entry point for your application both when a grain is first launched
# and when a grain resumes after being previously shut down.
#
# This script is responsible for launching everything your app needs to run.  The
# thing it should do *last* is:
#
#   * Start a process in the foreground listening on port 8000 for HTTP requests.
#
# This is how you indicate to the platform that your application is up and
# ready to receive requests.  Often, this will be something like nginx serving
# static files and reverse proxying for some other dynamic backend service.
#
# Other things you probably want to do in this script include:
#
#   * Building folder structures in /var.  /var is the only non-tmpfs folder
#     mounted read-write in the sandbox, and when a grain is first launched, it
#     will start out empty.  It will persist between runs of the same grain, but
#     be unique per app instance.  That is, two instances of the same app have
#     separate instances of /var.
#   * Preparing a database and running migrations.  As your package changes
#     over time and you release updates, you will need to deal with migrating
#     data from previous schema versions to new ones, since users should not have
#     to think about such things.
#   * Launching other daemons your app needs (e.g. mysqld, redis-server, etc.)

# By default, this script does nothing.  You'll have to modify it as
# appropriate for your application.

export HOME=/tmp
export PGDATA=/var/lib/postgresql
export RBENV_VERSION=2.2.2
export PATH=/usr/lib/postgresql/9.4/bin:/usr/local/rbenv/versions/$RBENV_VERSION/bin:$PATH
export RAILS_ENV=production
export SECRET_COOKIE_TOKEN=`base64 /dev/urandom | head -c 30`
export DEVISE_SECRET=`base64 /dev/urandom | head -c 30`
export CANONICAL_HOST=Sandstorm
export VERSION=0
export VERSION_FILE=/var/version

cd /opt/app

if [ ! -e /var/lib/postgresql ]; then
  mkdir -p /var/lib
  pg_ctl init -o "-E UTF8"
  cp *.conf /var/lib/postgresql
fi

if [ ! -e /var/run/postgresql ]; then
  mkdir -p /var/run/postgresql
fi

pg_ctl start
cd loomio

if [ ! -f $VERSION_FILE ]; then
  echo New install. Setting up database.
  rake db:setup
  echo $VERSION >$VERSION_FILE
fi

if [ $(cat $VERSION_FILE) != $VERSION ]; then
  echo Upgrading database.
  bundle exec rake db:migrate
  echo $VERSION >$VERSION_FILE
fi

bundle exec rails server -b 127.0.0.1 -p 8000