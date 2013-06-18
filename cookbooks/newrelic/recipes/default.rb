if has_newrelic
  include_recipe "newrelic::server_monitoring"
  include_recipe "newrelic::rpm"
end