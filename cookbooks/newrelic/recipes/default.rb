if has_newrelic
  require_recipe "newrelic::server_monitoring"
  require_recipe "newrelic::rpm"
end