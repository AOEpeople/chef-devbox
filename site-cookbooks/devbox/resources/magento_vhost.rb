actions :create

default_action :create

attribute :project, kind_of: String, default: ''
attribute :environment, kind_of: String, default: ''
attribute :server_name, kind_of: String, default: ''