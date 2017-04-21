#
# Cookbook Name:: summary_handlers_test
# Recipe:: web_site
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

directory 'c:\inetpub\wwwroot' do
  rights :read, 'IIS_IUSRS'
  recursive true
  action :create
end

template 'c:\inetpub\wwwroot\Default.htm' do
  source 'Default.htm.erb'
end
