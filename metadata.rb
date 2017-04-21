name             'summary_handlers'
maintainer       'Chris Sullivan'
maintainer_email 'n/a'
license          'MIT'
description      'Installs/Configures some handlers that summerise the Chef run in terms of Resource and Recipe'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.0'

chef_version '~> 12' if respond_to?(:chef_version)

recipe            'summary_handlers', 'Default recipe, will include recipe_summary and resource_summary if the appropriate attributes set.'
recipe            'summary_handlers::cookbook_summary', 'Will add a handler to provide a cookbook summary at the end of the Chef run.'
recipe            'summary_handlers::recipe_summary', 'Will add a handler to provide a recipe summary at the end of the Chef run.'
recipe            'summary_handlers::resource_summary', 'Will add a handler to provide a resource summary at the end of the Chef run.'

issues_url 'https://github.com/chrisgit/chef-summary_handlers/issues' if respond_to?(:issues_url)
source_url 'https://github.com/chrisgit/chef-summary_handlers' if respond_to?(:source_url)

supports 'centos'
supports 'windows'

depends 'chef_handler'
