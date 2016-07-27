# Author:: Chris Sullivan
# Cookbook Name:: summary_handlers
# Cookbook:: resource_summary

summary_handlers_install_handler 'resource_summary' do
  handler_class 'Chef::Handler::ResourceSummary'
  templates ['resource_by_cookbook.erb', 'resource_by_type.erb']
end
