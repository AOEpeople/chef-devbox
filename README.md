Setup Jenkins from scratch in less than 2 min
=============================================

```Shell
sudo curl -L https://www.opscode.com/chef/install.sh | bash
git clone --recursive git@github.com:fbrnc/integrationserver.git ~/chef
cd ~/chef
sudo /opt/chef/bin/chef-solo -c solo.rb -j solo.json
```

Jenkins will run using port 8080 by default.
