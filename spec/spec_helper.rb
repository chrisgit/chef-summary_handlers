# Load handler
['files/default/handlers/cookbook_summary.rb', 'files/default/handlers/recipe_summary.rb', 'files/default/handlers/resource_summary.rb'].each { |f| require File.expand_path(f) }
