def nginx_resources
   [
    create_resource(Chef::Resource::Log, 'Creating nginx folder', {:cookbook_name= => 'nginx', :recipe_name= => 'default'}),
    create_resource(Chef::Resource::Directory, '/etc/nginx', {:cookbook_name= => 'nginx', :recipe_name= => 'default'}),
   ]
end

def load_cookbooks
    cookbook_repo = File.expand_path(File.join(File.dirname(__FILE__), "data", "cookbooks")) # apache2, java, openldap
    cookbook_loader = Chef::CookbookLoader.new(cookbook_repo)
    cookbook_loader.load_cookbooks        
    cookbook_collection = Chef::CookbookCollection.new(cookbook_loader)
end

def load_resources(run_context)
    run_context.resource_collection.all_resources.replace(nginx_resources)
end

def load_recipes(run_context)
    run_context.instance_variable_set(:@loaded_recipes_hash, {'nginx::default' => '', 'hipchat::default' => ''})
end

def create_run_context
    cookbook_collection = load_cookbooks        
    node = Chef::Node.new
    events = Chef::EventDispatch::Dispatcher.new
    run_context = Chef::RunContext.new(node, cookbook_collection, events) # Node, cookbook collection, events
end