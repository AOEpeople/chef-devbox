action :create do

  mysql_connection_info = { host: 'localhost', username: 'root', password: node['mysql']['server_root_password'] }
  name = new_resource.name
  password = new_resource.password || new_resource.name

  db = mysql_database name do
    connection mysql_connection_info
    encoding 'utf8'
    collation 'utf8_general_ci'
    action :create
    notifies :create, "mysql_database_user[#{name}]", :immediately
    notifies :grant, "mysql_database_user[#{name}]", :immediately
  end

  mysql_database 'flush the privileges' do
    connection mysql_connection_info
    sql 'flush privileges'
    action :nothing
  end

  mysql_database_user name do
    connection mysql_connection_info
    password password
    database_name name
    host 'localhost'
    privileges [:all]
    action :nothing
    notifies :query, 'mysql_database[flush the privileges]', :immediately
  end
end