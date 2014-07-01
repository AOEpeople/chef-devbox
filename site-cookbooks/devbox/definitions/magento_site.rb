define :magento_site, :path => "/var/www/phpapp", :database => "phpapp", :db_username => "phpapp", :db_password => "phpapp", :template => "site.conf.erb" do

  magento_latest = Chef::Config[:file_cache_path] + '/magento-latest.tar.gz'

  remote_file magento_latest do
    source 'http://magento.org/latest.tar.gz'
    mode 0644
  end

  directory params[:path] do
    owner 'root'
    group 'root'
    mode 0755
    action :create
    recursive true
  end

  execute 'untar-magento' do
    cwd params[:path]
    command 'tar --strip-components 1 -xzf ' + magento_latest
    creates params[:path] + '/wp-settings.php'
  end

  wp_secrets = Chef::Config[:file_cache_path] + '/wp-secrets.php'

  remote_file wp_secrets do
    source 'https://api.magento.org/secret-key/1.1/salt/'
    action :create_if_missing
    mode 0644
  end

  salt_data = ''

  ruby_block 'fetch-salt-data' do
    block do
      salt_data = File.read(wp_secrets)
    end
    action :create
  end

  template params[:path] + '/wp-config.php' do
    source 'wp-config.php.erb'
    mode 0755
    owner 'root'
    group 'root'
    variables(
      :database        => params[:database],
      :user            => params[:db_username],
      :password        => params[:db_password],
      :wp_secrets      => salt_data)
  end

  # Due to a Chef quirk we can't pass our params to another definition
  docroot = params[:path]
  server_name = params[:name]

  web_app server_name do
    template "site.conf.erb"
    docroot docroot
    server_name server_name
  end
end