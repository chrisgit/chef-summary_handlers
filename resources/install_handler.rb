#
# Cookbook Name:: summary_handlers
# Resources:: install_handler
#

actions :install
default_action :install

attribute :handler_name, :kind_of => String, :name_attribute => true
attribute :templates, :kind_of => Array, :default => []
attribute :handler_class, :kind_of => String, :required => true
