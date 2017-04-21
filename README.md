summary-handlers Cookbook
=========================
This cookbook includes three report handlers.

## Cookbook Summary
The cookbook summary is a list of cookbooks that have been pulled down as part of the run list (or dependencies).

## Recipe Summary
The recipe summary is designed for situations for helping to see if a community cookbook has been added as a dependency but no longer required as it lists all recipes and marks those that have not been loaded.

## Resource Summary
The resource summary is for larger cookbooks with a lot of resources to summerise the resources that have been loaded into the resource queue. The report has two modes, output the resources grouped by type or by cookbook recipe. 
There are two sorting options
* By Type; the output is resource type followed by recipe name
* By Cookbook; the output is recipe name followed by resources

The overall intention of the summary handlers is for development time using Test Kitchen, not production but it could be added as part of a regular run list.

Output is using puts rather than Chef::Log, if you fork and change the code to use Chef::Log and there is no output check your Log level!

If the cookbook proves to be popular I will distribute the core as a gem to make it even easier to install and use!

Requirements
------------
* ChefDK, can be found here https://downloads.chef.io/chef-dk/ 
* Vagrant
* Virtual Box
* Windows/Linux box file
* Cookbook to add the summary handlers to

Tested with ChefDK 0.62

Attributes
----------
#### summary-handlers::default
 Key                                                | Type    | Description                                    | Default        
----------------------------------------------------|---------|------------------------------------------------|---------
`['summary-handlers']['cookbook-summary-report']`   | boolean | If default recipe called add cookbook-summary  | `true`
`['summary-handlers']['recipe-summary-report']`     | boolean | If default recipe called add recipe-summary    | `true`
`['summary-handlers']['resource-summary-report']`   | boolean | If default recipe called add resource-summary  | `true`

#### summary-handlers::resource_summary
NB: Key is abbreviated, the key path starts with ['summary-handlers']['resource-summary']
Simple add below for full attribute name, i.e ['summary-handlers']['resource-summary']['report_type']

 Key                  | Type    | Description                  | Default        
 ---------------------|---------|------------------------------|----------------
`['report_type']`     | Symbol  | :by_cookbook or :by_type     | :by_cookbook
`['report_format']`   | Symbol  | :template, :json or :yaml    | :template
`['updated_only']`    | boolean | Show only updated resources  | false
`['user_filter']`     | Proc    | Proc for user filter         | nil


The user_filter will allow you to filter resource summary to just the resources you are interested in, the filter can be any valid resouce property.

Example setting for 
default['summary-handlers']['resource-summary']['user_filter'] = proc {|resource| resource.method == user_criteria}

This setting will need to be done in your wrapper cookbook attributes or recipe file as it requires Ruby proc.

Usage
-----
If using Test Kitchen and Berkshelf then add to your Berksfile, summary_handlers is available on Git or Public Chef Supermarket.

Git
````
cookbook 'summary_handlers', git: 'https://github.com/chrisgit/chef-summary_handlers'
````

Public Supermarket
````
source 'https://supermarket.chef.io'

metadata

cookbook 'summary_handlers'
````

Change you test suite run list to include summary handlers (.kitchen.yml or .kitchen.local.yml)
````
suites:
- name: default
  run_list: ["recipe[summary_handlers]","recipe[my_cookbook]"]
  attributes: { ... }
````

Use the attributes section of the test suite to get the desired behavior.

Alternatively, you can add this cookbook as a dependency in your cookbook, to do that update your cookbooks metadata file
````
depends 'summary_handlers'
````

Then add an include_recipe in default.rb (or one of the recipes used by your cookbook)
````
include_recipe 'summary_handlers
````

Contributing
------------
Please see [CONTRIBUTING.md][contributor] and read the [CODE_OF_CONDUCT.md][conduct]

License and Authors
-------------------
Please see [LICENSE][licence]
Authors: Chris Sullivan

[contributor]: https://github.com/chrisgit/chef-summary_handlers/blob/master/CONTRIBUTING.md
[conduct]: https://github.com/chrisgit/chef-summary_handlers/blob/master/CODE_OF_CONDUCT.md
[licence]: https://github.com/chrisgit/chef-summary_handlers/blob/master/LICENSE