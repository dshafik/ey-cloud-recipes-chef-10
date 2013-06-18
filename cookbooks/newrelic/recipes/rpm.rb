ey_cloud_report "new relic - RPM" do
  message "New Relic - RPM"
end

if ['app_master', 'app', 'solo'].include? node['instance_role']
  # Download newrelic PHP at specified version
  remote_file "#{Chef::Config['file_cache_path']}newrelic-php5-#{node['newrelicrpm']['rpm_version']}-linux.tar.gz" do
    source "http://download.newrelic.com/php_agent/archive/#{node['newrelicrpm']['rpm_version']}/newrelic-php5-#{node['newrelicrpm']['rpm_version']}-linux.tar.gz"
    action :create_if_missing
  end
  
  # Make blocks work
  nr_key = newrelic_license_key
  
  # Install newrelic PHP as 'root' user using silent install
  bash "install_newrelic_php" do
    user 'root'
    cwd Chef::Config['file_cache_path']
    code <<-EOH
      export NR_INSTALL_SILENT='true'
      export NR_INSTALL_KEY="#{nr_key}"
      gzip -dc newrelic-php5-#{node['newrelicrpm']['rpm_version']}-linux.tar.gz | tar xf -
      cd newrelic-php5-#{node['newrelicrpm']['rpm_version']}-linux
      ./newrelic-install install
    EOH
    action :run
  end
  
  # Write custom newrelic.ini information
  template "/etc/php/fpm-php5.4/ext-active/newrelic.ini" do
    owner "root"
    group "root"
    mode 0644
    backup 0
    source "newrelic.ini.erb"
    variables(
      :license_key   => nr_key)
  end
  
  # Write newrelic.cfg information
  template "/etc/newrelic/newrelic.cfg" do
    owner "root"
    group "root"
    mode 0644
    backup 0
    source "newrelic.cfg.erb"
  end
  
  directory "/var/log/newrelic" do
    action :create
    recursive true
    owner 'root'
    group 'root'
  end
  
  node[:applications].each do |app, data|
    file = Chef::Util::FileEdit.new("/data/#{app}/shared/config/fpm-pool.conf")
    file.insert_line_if_no_match("/php_value[newrelic.appname] = \"#{app}\"/", "php_value[newrelic.appname] = \"#{app}\"")
    file.write_file
  end
  
  # Add newrelic-daemon to monit
  template "/etc/monit.d/newrelic-daemon.monitrc" do
    owner "root"
    group "root"
    mode 0644
    source "newrelic-daemon.monitrc.erb"
  end
  
  execute "monit reload" do
    action :run
  end
  
  execute "monit reload php-fpm" do
    action :run
  end
  
  execute "monit reload newrelic-daemon" do
    action :run
  end
end