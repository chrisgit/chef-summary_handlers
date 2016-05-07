require 'chef'
require 'chef/handler'
require 'erubis'

# Handler
class Chef
    class Handler
        class RecipeSummary < Chef::Handler

			def is_loaded?(cookbook_recipe)
				run_context.loaded_recipes.include?(cookbook_recipe)
			end
			
			def has_resources?(cookbook_recipe)
				cookbook, recipe = cookbook_recipe.split('::')
				run_status.all_resources.any? {|r| r.cookbook_name == cookbook && r.recipe_name == recipe}
			end
			
			def summerise_recipe(cookbook, recipe)
				recipe_name = recipe[:name]
				recipe_name = File.basename(recipe_name,File.extname(recipe_name))
				cookbook_recipe = "#{cookbook}::#{recipe_name}"
				loaded = is_loaded?(cookbook_recipe)
				contains_resources = has_resources?(cookbook_recipe)
				{
					:cookbook => cookbook_recipe,
					:loaded => loaded, 
					:resources => contains_resources
				}
			end
			
            def report
                all_recipes = []
                run_context.cookbook_collection.each_pair do |cookbook, cookbook_version|
                    cookbook_version.manifest["recipes"].each do |recipe|
		                all_recipes << summerise_recipe(cookbook, recipe)
                    end
                end

                summary_report = generate_report({:all_recipes => all_recipes})

                output_report(summary_report)
            end

            def generate_report(report_data)
                template = ::File.join(File.dirname(__FILE__), 'Templates', 'recipe_summary.erb')
                erb = ::Erubis::Eruby.new(File.read(template))
                erb.evaluate(report_data)
            end

            def output_report(report)
                puts report
            end
        end
    end
end
