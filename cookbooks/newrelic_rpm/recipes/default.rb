#
# Cookbook Name:: newrelic_rpm
# Recipe:: default
#
# Copyright 2012, Engine Yard
#
# All rights reserved - Do Not Redistribute

if ['app_master', 'app', 'solo'].include? node['instance_role']
  # Create PHP extensions directory for newrelic.so extension
  directory '/usr/lib/php5.4/lib/extensions/no-debug-non-zts-20090626' do
    owner 'root'
    group 'root'
    mode 0755
    action :create
    recursive true
  end

  # Write custom newrelic.ini information
  template "/etc/php/fpm-php5.4/ext-active/newrelic.ini" do
    owner "root"
    group "root"
    mode 0644
    source "newrelic.ini.erb"
  end

  # Download newrelic PHP at specified version
  remote_file "#{Chef::Config['file_cache_path']}newrelic-php5-#{node['newrelicrpm']['rpm_version']}-linux.tar.gz" do
    source "http://download.newrelic.com/php_agent/archive/#{node['newrelicrpm']['rpm_version']}/newrelic-php5-#{node['newrelicrpm']['rpm_version']}-linux.tar.gz"
    action :create_if_missing
  end

  # Install newrelic PHP as 'root' user using silent install
  bash "install_newrelic_php" do
    user 'root'
    cwd Chef::Config['file_cache_path']
    code <<-EOH
      export NR_INSTALL_SILENT='true'
      export NR_INSTALL_KEY="#{node['newrelic']['license_key']}"
      gzip -dc newrelic-php5-#{node['newrelicrpm']['rpm_version']}-linux.tar.gz | tar xf -
      cd newrelic-php5-#{node['newrelicrpm']['rpm_version']}-linux
      ./newrelic-install install
    EOH
    action :run
  end

  # Add newrelic-daemon to monit
  template "/etc/monit.d/newrelic-daemon.monitrc" do
    owner "root"
    group "root"
    mode 0644
    source "newrelic-daemon.monitrc.erb"
  end

  service "php-fpm" do
    action :restart
  end

  service "newrelic-daemon" do
    action :restart
  end

  service "nginx" do
    action :restart
  end
end