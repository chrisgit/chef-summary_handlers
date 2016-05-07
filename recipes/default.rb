# Author:: Chris Sullivan
# Cookbook Name:: SUMMARY_handlers

include_recipe 'summary_handlers::cookbook_summary' if node['summary-handlers']['cookbook-summary-report']
include_recipe 'summary_handlers::recipe_summary' if node['summary-handlers']['recipe-summary-report']
include_recipe 'summary_handlers::resource_summary' if node['summary-handlers']['resource-summary-report']
