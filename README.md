summary-handlers Cookbook
=========================
This cookbook includes two report handlers.

The recipe handler is designed for situations where a community cookbook has been added as a dependency but no longer required and any include_recipe statements or LWRP have been removed making the cookbook redundant. The recipe handler will tell you what cookbooks have been read in (dependencies) and what recipes have been loaded.

The resource handler is for larger cookbooks with a lot of resources to summerise the resources that have been loaded into the resource queue. The report has two modes, output the resources grouped by type or by cookbook recipe. 
The output for resource handler by type was originally designed to see how much overlap there was in the cookbooks.
The output for resource handler by cookbook was originally designed to ensure that we could make the recipes have a single responsibility, meaning easier to deploy as a self-contained entity.

Intention of the handler is for development time using Test Kitchen, not production.

If the cookbook proves to be popular I will distribute the core as a gem to make it even easier to install and use!

Requirements
------------
ChefDK, can be found here https://downloads.chef.io/chef-dk/ 
Tested with ChefDK 0.62
If tested in Windows then you will need to supply a Windows box file, a test kitchen .kitchen.yml file is supplied as a template.

Attributes
----------
#### summary-handlers::default
 Key                                               | Type    | Description                                   | Default        
---------------------------------------------------|---------|-----------------------------------------------|---------
`['summary-handlers']['resource-summary-report']`  | boolean | If default recipe called add resource-summary | `true`
`['summary-handlers']['recipe-summary-report']`    | boolean | If default recipe called add recipe-summary   | `true`

#### summary-handlers::resource_summary
NB: Key is abbreviated, the key path starts with ['summary-handlers']['resource-summary']
Simple add below for full attribute name, i.e ['summary-handlers']['resource-summary']['report_type']

 Key                  | Type   | Description                | Default        
 ---------------------|--------|----------------------------|----------------
`['report_type']`     | Symbol | :by_cookbook or :by_type   | :by_cookbook
`['report_format']`   | Symbol | :template, :json or :yaml  | :template
`['report_writer']`   | Symbol | :stdio                     | :stdio
`['user_filter']`     | Proc   | Proc for user filter       | :template


The user_filter will allow you to filter resource summary to just the resources you are interested in, the filter can be any valid resouce property.

Example setting for 
 default['summary-handlers']['resource-summary']['user_filter'] = proc {|resource| resource. == user_criteria}

Usage
-----
Add this cookbook as a dependency in your cookbook.
In your cookbook add an include_recipe 'summary_handlers'

Contributing
------------
Branch the source, make the changes, add tests as appropriate, make a pull request.

License and Authors
-------------------
Authors: Chris Sullivan
