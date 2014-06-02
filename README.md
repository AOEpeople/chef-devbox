Setup Jenkins from scratch in less than 2 min
=============================================

```Shell
curl -L https://www.opscode.com/chef/install.sh | sudo bash
git clone --recursive git@github.com:fbrnc/integrationserver.git ~/chef
sudo /opt/chef/bin/chef-solo -c ~/chef/solo.rb -j ~/chef/solo.json
```

Jenkins will run using port 8080 by default.
