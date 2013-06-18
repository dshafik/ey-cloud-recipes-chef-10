class Chef
  class Recipe
    def has_newrelic
      nr_count = 0
      node[:engineyard][:environment][:apps].each do |app|
        app[:components][0][:collection].each do |addon|
          nr_count += 1 if addon[:name] == "New Relic"
        end
      end
      nr_count > 0
    end
    def newrelic_license_key
      node[:engineyard][:environment][:apps].each do |app|
        app[:components][0][:collection].each do |addon|
          return addon[:config][:vars][:license_key]
        end
      end
    end
  end
end
