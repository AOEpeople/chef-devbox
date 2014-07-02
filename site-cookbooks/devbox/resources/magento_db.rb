actions :create, :remove

default_action :create

attribute :name, kind_of: String, regex: [/^([a-z]|[A-Z]|[0-9]|_|-)[1,16]$/],  name_attribute: true
attribute :password, kind_of: String
