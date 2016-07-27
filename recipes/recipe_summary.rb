# Author:: Chris Sullivan
# Cookbook Name:: summary_handlers
# Cookbook:: unused_cookbooks

summary_handlers_install_handler 'recipe_summary' do
  handler_class 'Chef::Handler::RecipeSummary'
  templates ['recipe_summary.erb']
end
