Provision using Chef-Solo
=========================

```Shell
sudo apt-get -y update
sudo apt-get -y install build-essential ruby-dev git curl build-essential libxml2-dev libxslt-dev libssl-dev
curl -L https://www.opscode.com/chef/install.sh | sudo bash
git clone git@github.com:fbrnc/integrationserver.git ~/chef
sudo /opt/chef/embedded/bin/gem install berkshelf --no-ri --no-rdoc
sudo ln -s /opt/chef/embedded/bin/berks /usr/local/bin/berks
cd ~/chef && berks vendor ~/chef/cookbooks
sudo /opt/chef/bin/chef-solo -c ~/chef/solo.rb -j ~/chef/solo.json -l info
```
