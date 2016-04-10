# Supporting methods for testing resource summary

# ReportWriter sends report to stdout, suppress that
module Handler
    module ResourceSummary
        class ReportWriterStdio < ReportWriter
            def write
            end
        end
   end
end

# Put items into resource collection
def build_resources
    nginx_resources + apache_resources
end

# Fake resources from a fictional nginx cookbook
def nginx_resources
    [
    create_resource(Chef::Resource::Log, 'Creating nginx folders', {:cookbook_name= => 'nginx', :recipe_name= => 'default'}),
    create_resource(Chef::Resource::Directory, '/etc/nginx', {:cookbook_name= => 'nginx', :recipe_name= => 'default'}),
    create_resource(Chef::Resource::Log, 'Starting nginx', {:cookbook_name= => 'nginx', :recipe_name= => 'service'}),
    create_resource(Chef::Resource::Service, 'nginx', {:cookbook_name= => 'nginx', :recipe_name= => 'service'})
    ]
end

# Fake resources from a fictional apache cookbook
def apache_resources
    [
    create_resource(Chef::Resource::Log, 'Installing Apache', {:cookbook_name= => 'apache', :recipe_name= => 'default'}),
    create_resource(Chef::Resource::Template, '/etc/apache/conf', {:cookbook_name= => 'apache', :recipe_name= => 'configuration'}),
    create_resource(Chef::Resource::Service, 'apache', {:cookbook_name= => 'apache', :recipe_name= => 'configuration'})
    ]
end

# If report is generated by cookbook then the source hash looks like this
def by_cookbook_hash
    {
        'nginx' =>
        {
            'default' => [create_resource(Chef::Resource::Log, 'Creating nginx folders', {:cookbook_name= => 'nginx', :recipe_name= => 'default'}),
                           create_resource(Chef::Resource::Directory, '/etc/nginx', {:cookbook_name= => 'nginx', :recipe_name= => 'default'})],
            'service' => [create_resource(Chef::Resource::Log, 'Starting nginx', {:cookbook_name= => 'nginx', :recipe_name= => 'service'}),
                        create_resource(Chef::Resource::Service, 'nginx', {:cookbook_name= => 'nginx', :recipe_name= => 'service'})]
        },
        'apache' => 
        {
            'default' => [create_resource(Chef::Resource::Log, 'Installing Apache', {:cookbook_name= => 'apache', :recipe_name= => 'default'})],
            'configuration' => [create_resource(Chef::Resource::Template, '/etc/apache/conf', {:cookbook_name= => 'apache', :recipe_name= => 'configuration'}),
                                create_resource(Chef::Resource::Service, 'apache', {:cookbook_name= => 'apache', :recipe_name= => 'configuration'})],   
        }
    }
end

# If report is generated by type then the source hash looks like this
def by_type_hash
    {
        'log' => 
        {
            'nginx' =>
            {
                'default' => [create_resource(Chef::Resource::Log, 'Creating nginx folders', {:cookbook_name= => 'nginx', :recipe_name= => 'default'})],
                'service' => [create_resource(Chef::Resource::Log, 'Starting nginx', {:cookbook_name= => 'nginx', :recipe_name= => 'service'})]
            },
            'apache' =>
            {
                'default' => [create_resource(Chef::Resource::Log, 'Installing Apache', {:cookbook_name= => 'apache', :recipe_name= => 'default'})]            
            }
        },
        'directory' =>
        {
            'nginx' =>
            {
                'default' => [create_resource(Chef::Resource::Directory, '/etc/nginx', {:cookbook_name= => 'nginx', :recipe_name= => 'default'})]               
            }
        },
        'service' =>
        {
            'nginx' => 
            {
                'service' => [create_resource(Chef::Resource::Service, 'nginx', {:cookbook_name= => 'nginx', :recipe_name= => 'service'})]      
            },
            'apache' => 
            {
                'configuration' => [create_resource(Chef::Resource::Service, 'apache', {:cookbook_name= => 'apache', :recipe_name= => 'configuration'})]
            }
        },
        'template' =>
        {
            'apache' => 
            {
                'configuration' => [create_resource(Chef::Resource::Template, '/etc/apache/conf', {:cookbook_name= => 'apache', :recipe_name= => 'configuration'})] 
            }
        }
    }
end

# If report is generated by cookbook and the test filter applied then the source hash looks like this
def filtered_hash
    {
        'apache' => 
        {
            'default' => [create_resource(Chef::Resource::Log, 'Installing Apache', {:cookbook_name= => 'apache', :recipe_name= => 'default'})],
            'configuration' => [create_resource(Chef::Resource::Template, '/etc/apache/conf', {:cookbook_name= => 'apache', :recipe_name= => 'configuration'}),
                                create_resource(Chef::Resource::Service, 'apache', {:cookbook_name= => 'apache', :recipe_name= => 'configuration'})],   
        }
    }
end

# Originally de-serialized from JSON report back to source hash to validate
=begin
# Take resource, serialize then de-serialize
      json = Chef::JSONCompat.to_json(resource)
      serialized_node = Chef::JSONCompat.from_json(json)
# Serialize a single resource
log = Chef::Resource::Log.new 'Hello'
log_json = log.to_json
log_restored = Chef::Resource::Log.json_create(JSON.parse(log_json))
=end