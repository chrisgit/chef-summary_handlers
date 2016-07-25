# Create a resource and apply values
def create_resource(resource_type, resource_name, options = {})
    resource = resource_type.new resource_name
    options.each_pair do |attribute, value|
        resource.send(attribute, value)
    end
    resource
end

def all_resources
    nginx_resources + updated_ngnix_resources
end

def nginx_resources
   [
    create_resource(Chef::Resource::Directory, '/etc/nginx', {:cookbook_name= => 'nginx', :recipe_name= => 'folder'})
   ]
end

def updated_ngnix_resources
   [
    create_resource(Chef::Resource::Log, 'Creating nginx folder', {:cookbook_name= => 'nginx', :recipe_name= => 'default', :updated_by_last_action => true}),
    create_resource(Chef::Resource::CookbookFile, '/etc/nginx/default.conf', {:cookbook_name= => 'nginx', :recipe_name= => 'folder', :updated_by_last_action => true}),
   ]
end

def load_cookbooks
    cookbook_repo = File.expand_path(File.join(File.dirname(__FILE__), "data", "cookbooks")) # apache2, java, openldap
    cookbook_loader = Chef::CookbookLoader.new(cookbook_repo)
    cookbook_loader.load_cookbooks        
    cookbook_collection = Chef::CookbookCollection.new(cookbook_loader)
end

def load_resources(run_context)
    run_context.resource_collection.all_resources.replace(all_resources)
end

def load_recipes(run_context)
    run_context.instance_variable_set(:@loaded_recipes_hash, {'nginx::default' => '', 'hipchat::default' => '', 'apache2::default' => ''})
end

def create_run_context
    cookbook_collection = load_cookbooks        
    node = Chef::Node.new
    events = Chef::EventDispatch::Dispatcher.new
    run_context = Chef::RunContext.new(node, cookbook_collection, events) # Node, cookbook collection, events
end