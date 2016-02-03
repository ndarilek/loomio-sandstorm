# Loomio for Sandstorm

Quickly spin up [Loomio](https://www.loomio.org) instances on the [Sandstorm](https://sandstorm.io) app platform.

## Developing

To launch a local Sandstorm instance with Loomio pre-installed, do the following.

 1. [Install Vagrant](https://www.vagrantup.com/downloads.html).
 2. [Install Vagrant-SPK](https://github.com/sandstorm-io/vagrant-spk).
 3. From the top-level directory, run `vagrant-spk up && vagrant-spk dev`.
 4. When you are told the app is running, access http://local.sandstorm.io:6080. Log in with a dev account, then click the button to spin up a new Loomio instance.

Note that startup in dev mode takes a *very* long time due to issues with Rails. This is not representative of production startup times which are significantly faster. You may also have to reload the page on first run in dev mode since the browser connection will likely time out. See the `Log` button in the topbar for server logs, and if the initial load times out, simply reload the page when the logs indicate that the server is up.
