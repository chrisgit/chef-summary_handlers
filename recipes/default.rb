# Author:: Chris Sullivan
# Cookbook Name:: SUMMARY_handlers
# Cookbook:: default

include_recipe 'summary_handlers::resource_summary' if node['summary-handlers']['resource-summary-report']
include_recipe 'summary_handlers::recipe_summary' if node['summary-handlers']['recipe-summary-report']
