ey_cloud_report "new relic - server monitoring" do
  message "New Relic - Server Monitoring"
end

package "sys-apps/newrelic-sysmond" do
  action :install
end

# Make blocks work
nr_key = newrelic_license_key

template "/etc/newrelic/nrsysmond.cfg" do
  source "nrsysmond.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  backup 0
  variables(
    :license_key   => nr_key)
end

remote_file "/etc/monit.d/nrsysmond.monitrc" do
  owner "root"
  group "root"
  mode 0644
  backup 0
  source "nrsysmond.monitrc"
end

directory "/var/log/newrelic" do
  action :create
  recursive true
  owner "root"
  group "root"
end

execute "monit reload" do
  action :run
end
