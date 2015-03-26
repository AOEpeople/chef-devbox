# Chef Devbox


## Introduction

The purpose of this project is to provide a very simple way to set up a Ubuntu server that runs one or more web applications.
Although this is designed with Magento projects in mind this should be usable for every application relying on a LAMP stack.

There are way too many chef cookbooks out there that do way too many things. This solution doesn't claim to be perfect or
complete, but it's supposed to be as lightweight as possible.

We use this setup to provision
* a developer's local development environment using Vagrant and VirtualBox
* Jenkins server on EC2

Since this should be as portable as possible (and since dealing with Ruby, Chef and especially Berkshelf is really painful on
Windows hosts) this solution abstracts completely from provisioning the actual server. It assumes there's already a vanilla Ubuntu
server up and running.

### Screencast

https://youtu.be/MsPedp5v1Yo

### In a hurry? Here's the quick run:

* Install Virtualbox and Vagrant if you haven't already
* Create a project directory on your host system (e.g. "demo") and 'cd' into it
* Download this file https://raw.githubusercontent.com/AOEpeople/chef-devbox/master/Vagrantfile
* run `vagrant up`
* Create some project json files in /etc/chef-devbox/data_bags/magento-sites/
* Reprovision: `sudo /etc/chef-devbox/provision.sh`

### Provisioning the 'box'

Using Vagrant and VirtualBox you can simply start any Ubuntu 14.04 image without further provisioning. This is what I like to do:

```
Vagrant.configure("2") do |config|
    config.vm.box = "trusty64"
    config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
    config.ssh.forward_agent = true
    config.vm.network :private_network, ip: "192.168.41.11"
    config.vm.provider "virtualbox" do |v|
        v.name = "unibox"
        v.customize ["modifyvm", :id, "--memory", "4096"]
        v.customize ["modifyvm", :id, "--cpuexecutioncap","90"]
        v.customize ["modifyvm", :id, "--cpus",4]
        #v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        #v.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
        #v.auto_nat_dns_proxy = false
    end
end
```

On EC2 I just start a regular EC2 instance with the default Ubuntu 14.04 image.

Alternatively you can just download this [Vagrantfile](https://raw.githubusercontent.com/AOEpeople/chef-devbox/master/Vagrantfile) that will automatically trigger the setup script. 

## Initial Setup

After logging you just run this line that takes care of

* downloading the basic provisioning script that
  * installs git
  * clones the rest of this repository
  * installs ChefDK that comes with Berkshelf and all required dependencies (and doesn't take forever to install)
  * fetches all the configured cookbook dependencies

```Shell
curl https://raw.githubusercontent.com/AOEpeople/chef-devbox/master/setup.sh | sudo bash
```

### Configuration

Before provisioning (running Chef Solo) you need to
* configure the run list (and maybe the user) unless you want to create a simple devbox without Jenkins or Samba
* configure the web projects

#### Run lists

By default solo.json contains following run list which will provision a devbox and install all configured web projects:
```
{
    "run_list": [ "recipe[devbox::default]", "recipe[devbox::motd]", "recipe[devbox::hostsfile]" ],
    "devbox": {
        "main_user": "vagrant"
    }
}
```
The default main user (the user you'll use to work with) is 'ubuntu' which is fine for EC2 instances. Your devbox will most likely be a vagrant box. So check
if the main_user is configured to be 'vagrant'. 

If you like using Samba to access the files in the devbox from your host (I do) you can add run an additional runlist that will take care of installing and
configuring Samba to expose /var/www:
```
{
    "run_list": [ "recipe[devbox::samba]" ]
}
```

Simply run this: `sudo cd /etc/chef-devbox && sudo chef-solo -c solo.rb -j solo.samba.json`


If you want a Jenkins server to be installed in addition to the web projects check solo.jenkins.json and change solo.json to contain this
```
{
    "run_list": [ "recipe[aoe-jenkins::default]" ]
}
```
This assumes that your Jenkins server will have to interact with instances (e.g. 'integration', 'deploy') that exists locally. The exact same setup scripts we use in the
devbox are used to prepare the instances for Jenkins.

#### Adding a web project

By default this setup doesn't create any web project. And instead of introducing a new cookbook for every project it will check /etc/chef-devbox/data_bags/magento-sites/*.json for any project definition.

These json files contain all information to prepare 
* the file structure for the webroot (including release folders and symlinks)
* a vhost
* one or more local databases (username == dbname == password <- keeping it simple, remember? :)
* prepare the systemstorage backup

It will NOT attempt to download/clone your project files and install the project. 
This is usually so project specific and/or required access to private repositories that I don't want this to be part of the generic solution.
Having everything prepared is already doing all the ugly work and downloading and installing a build should be easy enough so that it can be done manually.

#### JSON file format

Check out the example file in this repo:
https://github.com/AOEpeople/chef-devbox/blob/master/data_bags/magento-sites/demo_devbox.json.example

### Provisioning

After configuring the run list and creating the project configuration (or after adding new projects) run chef:

```Shell
sudo /etc/chef-devbox/provision.sh
```
