root = File.absolute_path(File.dirname(__FILE__))

file_cache_path root
data_bag_path root + '/data_bags'
role_path root + '/roles'
cookbook_path [ root + '/site-cookbooks', root + '/cookbooks']