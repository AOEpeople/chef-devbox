action :create do
  Chef::Log.info("Create Magento vhost and folders: #{new_resource.name}")

  %w(releases shared/var shared/media).each do |name|
    directory "/var/www/#{new_resource.project}/#{new_resource.environment}/#{name}" do
      owner 'www-data'
      group 'www-data'
      mode 00775
      recursive true
      action :create
    end
  end

  docroot = "/var/www/#{new_resource.project}/#{new_resource.environment}/releases/current/htdocs"
  server_name = new_resource.server_name

  web_app new_resource.server_name do
    docroot docroot
    server_name server_name
    server_aliases []
    allow_override 'All'
  end

end