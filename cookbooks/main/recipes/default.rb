# Downgrade to PHP 5.3
#include_recipe "php::php53"

# Add custom environment variables to PHP
#include_recipe "php::environment_variables"

#include_recipe "php::composer"
#include_recipe "newrelic_rpm"
#include_recipe "newrelic_server_monitoring"
include_recipe "newrelic"