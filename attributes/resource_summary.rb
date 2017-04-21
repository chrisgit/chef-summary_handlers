default['summary-handlers']['resource-summary']['report_type'] = :by_cookbook
default['summary-handlers']['resource-summary']['report_format'] = :template
default['summary-handlers']['resource-summary']['updated_only'] = false
default['summary-handlers']['resource-summary']['user_filter'] = nil

# Examples of user_filter, for use with large cookbooks
# proc {|resource| resource.method == user_criteria}
=begin
# Specific cookbook
proc {|resource| resource.cookbook_name == 'my_cookbook' }

# Specific resource
proc {|resource| resource.resource_name == :chef_gem }

# Specific recipe
proc {|resource| resource.cookbook_name == 'my_cookbook' && resource.recipe_name == 'default'}
=end
