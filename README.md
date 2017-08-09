# Moodle Habitat Plans

This repo contains the habitat plans for the 'my' origin.

## Setup a vanilla environment to build and test the habitat plans

This paragragh is added to help with setting up your own habitat build
environment. There are off course several ways to accomplish the same results.

* Install Virtualbox + Vagrant
* Change to a designated development directory (e.g. /src/habitat)
* Clone this repo inside the development directory
* Put this Vagrantfile inside your development directory:

```
Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.synced_folder '', '/my'
  config.vm.network 'forwarded_port', guest: 80, host: 80

  config.vm.provider 'virtualbox' do |vb|
    vb.gui = false
    vb.memory = '1024'
    vb.cpus = 2
  end
  config.vm.provision 'shell', inline: <<-SHELL
    apt-get update
    apt-get install git -y
    adduser --system --group hab
    useradd --system --group hab hab
    curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
    SHELL
end
```

* Start the virtual machine: `vagrant up`
* Login to the VM: `vagrant ssh`
* Setup habitat: `hab setup`
  * create a 'my' origin
	* providing a github token or enabling analytics is not required
* Entering the studio and build a package:

```shell
cd /my
hab studio enter
build <packagepath>
```

* Start and stop a package service inside the studio

```shell
hab sup start <packagepath>
sup-log # see the output
hab sup stop <packagepath>
```

* Install the package on the local machine (first exit the studio)

```shell
hab origin key export my --type public | sudo hab origin key import

# replace <version> with the pkg_version from plan.sh and <timestamp> with timestamp of the package
sudo hab pkg install /my/results/my-moodle-nginx-proxy-<version>-<timestamp>-x86_64-linux.hart
```

## [Building Moodle see here](moodle/README.md)