#!/bin/bash

# Assuming all packages were installed if build-essential is present. Might be a wrong assumption
if [ `dpkg-query -W -f='${Status}' build-essential 2>/dev/null | grep -c "ok installed"` -eq 0 ]; then
    apt-get -y update
    apt-get -y install build-essential ruby-dev git curl build-essential libxml2-dev libxslt-dev libssl-dev
fi
if [ ! -e /opt/chef/bin/chef-solo ] ; then
    curl -L https://www.opscode.com/chef/install.sh | bash
fi
if [ ! -e /opt/chef/embedded/bin/berks ] ; then
    /opt/chef/embedded/bin/gem install berkshelf --no-ri --no-rdoc
    ln -s /opt/chef/embedded/bin/berks /usr/local/bin/berks
fi
if [ ! -d /etc/chef-devbox ] ; then
    git clone -b devbox https://github.com/fbrnc/integrationserver.git /etc/chef-devbox || { echo "Cloning failed"; exit 1; }
fi

echo
echo "Fetching dependencies via Berkshelf..."
echo "--------------------------------------"
echo

rm -rf /etc/chef-devbox/cookbooks
cd /etc/chef-devbox && berks vendor /etc/chef-devbox/cookbooks || { echo "Installing berkshelf depenencies failed"; exit 1; }

echo
echo "Running Chef..."
echo "---------------"
echo
/opt/chef/bin/chef-solo -c /etc/chef-devbox/solo.rb -j /etc/chef-devbox/solo.json -l info || { echo "Chef provsioning failed"; exit 1; }