# Load handler
['files/default/handlers/resource_summary.rb', 'files/default/handlers/recipe_summary.rb'].each { |f| require File.expand_path(f) }

# Create a resource and apply values
def create_resource(resource_type, resource_name, options = {})
    resource = resource_type.new resource_name
    options.each_pair do |attribute, value|
        resource.send(attribute, value)
    end
    resource
end

