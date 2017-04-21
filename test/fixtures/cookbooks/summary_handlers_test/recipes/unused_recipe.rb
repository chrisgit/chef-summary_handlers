#
# Cookbook Name:: summary_handlers_test
# Recipe:: default
#
# Copyright (c) 2017 ChrisGit, All Rights Reserved.

directory 'c:\temp\license' do
  recursive true
  action :create
end

file 'c:\temp\license\license.txt' do
  content 'LICENCE_KEY=1234'
  action :create
end

