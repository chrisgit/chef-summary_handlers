#
# Cookbook Name:: summary_handlers_test
# Recipe:: simple_config
#
# Copyright (c) 2017 ChrisGit, All Rights Reserved.

directory 'c:\temp\config' do
  recursive true
  action :create
end

file 'c:\temp\config\keys.txt' do
  content 'ACCESS_KEY=let_me_in'
  action :create
end

execute 'I am not idempotent!' do
  command 'echo Hello World'
  action :run
end

execute 'I do nothing' do
  command 'echo Goodbye world'
  action :nothing
end
