action :create do

  user 'systemstorage' do
    home '/home/systemstorage'
  end

  group 'systemstorage' do
    action :create
  end

  group 'www-data' do
    action :modify
    members 'systemstorage'
    append true
  end

  group 'www-data' do
    action :modify
    members 'vagrant'
    append true
  end

  %w(database files).each do |name|
    directory "/home/systemstorage/systemstorage/#{new_resource.project}/backup/#{new_resource.environment}/#{name}" do
      owner 'systemstorage'
      group 'systemstorage'
      mode 00775
      recursive true
      action :create
    end
  end

end
