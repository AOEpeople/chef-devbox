#!/bin/bash

if ! hash git 2>/dev/null; then
    apt-get -y update
    apt-get -y install git
fi

if [ ! -d /etc/chef-devbox ] ; then
    git clone -b jenkins https://github.com/fbrnc/integrationserver.git /etc/chef-devbox || { echo >&2 "Cloning failed"; exit 1; }
fi

if [ ! -f /opt/chefdk/bin/chef ] ; then
    echo
    echo "Installing ChefDK (includes Berkshelf)..."
    echo "-----------------------------------------"
    echo
    wget http://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.3.0-1_amd64.deb -O /tmp/chefdk_0.3.0-1_amd64.deb || { echo >&2 "Downloading ChefDK package failed"; exit 1; }
    dpkg -i /tmp/chefdk_0.3.0-1_amd64.deb || { echo >&2 "Installing ChefDK failed"; exit 1; }
fi

echo
echo "Fetching dependencies via Berkshelf..."
echo "--------------------------------------"
echo
rm -rf /etc/chef-devbox/cookbooks
cd /etc/chef-devbox && berks vendor /etc/chef-devbox/cookbooks || { echo >&2 "Installing berkshelf depenencies failed"; exit 1; }

echo
echo "Running Chef..."
echo "---------------"
echo
cd /etc/chef-devbox && chef-solo -c solo.rb -j solo.json -l info || { echo >&2 "Chef provsioning failed"; exit 1; }
