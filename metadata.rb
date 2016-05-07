name             'summary_handlers'
maintainer       'Chris Sullivan'
maintainer_email 'n/a'
license          'All rights reserved'
description      'Installs/Configures some handlers that summerise the Chef run in terms of Resource and Recipe'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.1'

recipe            'summary_handlers', 'Default recipe, will include recipe_summary and resource_summary if the appropriate attributes set.'
recipe            'summary_handlers::recipe_summary', 'Will add a handler to provide a recipe summary at the end of the Chef run.'
recipe            'summary_handlers::resource_summary', 'Will add a handler to provide a resource summary at the end of the Chef run.'

%w{ centos windows }.each do |os|
  supports os
end

%w{ chef_handler }.each do |cb|
  depends cb
end

grouping 'summary_handlers',
  title: 'Cookbook with resource and recipe handlers'
attribute 'summary-handlers/resource-summary/report_type',
  required: "required",
  default: :by_cookbook,
  choices: [
    :by_cookbook,
    :by_type
  ]
attribute "summary-handlers/resource-summary/report_format",
  required: "required",
  default: :template,
  choices: [
    :template,
    :json,
    :yaml
  ]
