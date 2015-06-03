#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "Please run this script as root"
    exit 1
fi

if ! hash git 2>/dev/null; then
    apt-get -y update
    apt-get -y install git
fi

if [ ! -d /etc/chef-devbox ] || [ ! -f /etc/chef-devbox/Berksfile ] ; then
    git clone https://github.com/aoepeople/chef-devbox.git /etc/chef-devbox || { echo >&2 "Cloning failed"; exit 1; }
else 
    cd /etc/chef-devbox && git pull
fi

if [ ! -f /opt/chefdk/bin/chef ] || [ "$(/opt/chefdk/bin/chef --version)" != "Chef Development Kit Version: 0.3.5" ] ; then
    echo
    echo "Installing ChefDK (includes Berkshelf)..."
    echo "-----------------------------------------"
    echo
    wget -q https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.4.0-1_amd64.deb -O /tmp/chefdk.deb || { echo >&2 "Downloading ChefDK package failed"; exit 1; }
    dpkg -i /tmp/chefdk.deb || { echo >&2 "Installing ChefDK failed"; exit 1; }
fi

echo
echo "Fetching dependencies via Berkshelf..."
echo "--------------------------------------"
echo
if [ -f /etc/chef-devbox/Berksfile.lock ] ; then rm /etc/chef-devbox/Berksfile.lock; fi
if [ -d ~/.berkshelf ] ; then rm -rf ~/.berkshelf; fi
if [ -d /etc/chef-devbox/cookbooks ] ; then rm -rf /etc/chef-devbox/cookbooks; fi
cd /etc/chef-devbox && berks vendor /etc/chef-devbox/cookbooks || { echo >&2 "Installing berkshelf dependencies failed"; exit 1; }

echo
echo "Running Chef..."
echo "---------------"
echo
/etc/chef-devbox/provision.sh || { echo >&2 "Chef provisioning failed"; exit 1; }

echo ""
echo "What's next?"
echo "------------"
echo ""
echo "(0. Log in to this machine if you're not already here: 'vagrant ssh' or use Putty to connect to 127.0.0.1, port 2222)"
echo "1. Go to /etc/chef-devbox/data_bags/magento-sites/ and create one or more project json files. Look at 'demo_devbox.json.example' for an example"
echo "2. Run provisioning again:"
echo "    sudo /etc/chef-devbox/provision.sh"
echo "3. Copy the contents of /var/www/hosts.hosts and paste it into you host system's host file (Windows: 'C:\\Windows\\System32\\drivers\\etc\\hosts')"
echo "4. If you want to install and configure Samba run this command:"
echo "    sudo cd /etc/chef-devbox && sudo chef-solo -c solo.rb -j solo.samba.json"
echo "5. Follow the instructions on the login screen (log out and log in again) for more information on how to install/update a build package"
echo ""
echo "Have a great day!"
echo ""
