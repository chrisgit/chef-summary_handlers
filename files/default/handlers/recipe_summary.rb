require 'chef'
require 'chef/handler'
require 'erubis'

# Handler
class Chef
    class Handler
        class RecipeSummary < Chef::Handler

            def report
                report = ::Handler::RecipeSummary::ReportGenerator.new(run_status).generate
                show_report(report)
            end
            
            def show_report(report)
                puts report
            end
        end
    end
end

module Handler
    module RecipeSummary

        # Take data and build report
        class ReportGenerator
            
            def initialize(run_status)
                @run_status = run_status
                @run_context = run_status.run_context
            end
            
			def is_loaded?(cookbook_recipe)
				@run_context.loaded_recipes.include?(cookbook_recipe)
			end

            def resource_count(cookbook_recipe)
				cookbook, recipe = cookbook_recipe.split('::')
				@run_status.all_resources.count {|r| r.cookbook_name == cookbook && r.recipe_name == recipe}
            end
						
            def updated_resource_count(cookbook_recipe)
				cookbook, recipe = cookbook_recipe.split('::')
                @run_status.updated_resources.count {|r| r.cookbook_name == cookbook && r.recipe_name == recipe}
            end
                        
			def summerise_recipe(cookbook, recipe)
                # Stored as filename, such as default.rb, remove the .rb
				recipe_name = recipe[:name]
				recipe_name = File.basename(recipe_name,File.extname(recipe_name))
				cookbook_recipe = "#{cookbook}::#{recipe_name}"
			end
            
            def cookbook_recipes
                all_recipes = []
                @run_context.cookbook_collection.each_pair do |cookbook, cookbook_version|
                    cookbook_version.manifest["recipes"].each do |recipe|
		                all_recipes << summerise_recipe(cookbook, recipe)
                    end
                end
				all_recipes
            end
            
            def generate()
                template = ::File.join(File.dirname(__FILE__), 'Templates', 'recipe_summary.erb')
                erb = ::Erubis::Eruby.new(File.read(template))
                erb.evaluate(self)
            end
            
        end
    end
end
