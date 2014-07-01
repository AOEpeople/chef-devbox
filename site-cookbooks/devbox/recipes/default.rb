#
# Cookbook Name:: devbox
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
Chef::Log.info("Recipe devbox::default")

include_recipe "apache2"
include_recipe "mysql::client"
include_recipe "mysql::server"
include_recipe "php"
include_recipe "php::module_mysql"
include_recipe "apache2::mod_php5"

#apache_site "default" do
#  enable false
#end

Chef::Log.info("Preparing Magento instances");

sites = data_bag("magento-sites")
sites.each do |site|
  opts = data_bag_item("magento-sites", site)

  Chef::Log.info("Found Magento site #{opts["id"]}")

  directory "/var/www/#{opts["project"]}/#{opts["environment"]}" do
    owner "www-data"
    group "www-data"
    recursive true
    mode 0664
    action :create
  end
end