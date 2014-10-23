
Chef::Log.info("Recipe aoe-jenkins::default")

include_recipe "jenkins::master"

node.default['devbox']['main_users'] << 'jenkins'

include_recipe "devbox::default"

# We're not installing the plugins here. Instead we'll restore a backup that includes all plugins
# But this is still a good reference of all the plugins that should be in place

jenkinsplugins = %w(
  sauce-ondemand
  s3
  BlazeMeterJenkinsPlugin
  build-pipeline-plugin
  envinject
  greenballs
  htmlpublisher
  matrix-project
  ws-cleanup
  git
  git-client
  build-user-vars-plugin
)
jenkinsplugins.each do |name|
  jenkins_plugin name
end

cookbook_file "/var/lib/jenkins/jenkins_backup.sh" do
  source 'jenkins_backup.sh'
  cookbook 'aoe-jenkins'
  group 'jenkins'
  owner 'jenkins'
  mode '0700'
  action :create_if_missing
end

cron "jenkins-backup" do
  action :create
  minute '0'
  hour '1'
  user 'jenkins'
  # mailto 'addemailhere'
  command "/var/lib/jenkins/jenkins_backup.sh"
end
