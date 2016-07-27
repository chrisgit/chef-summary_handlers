# Author:: Chris Sullivan
# Cookbook Name:: summary_handlers

summary_handlers_install_handler 'cookbook_summary' do
  handler_class 'Chef::Handler::CookbookSummary'
  templates ['cookbook_summary.erb']
end
