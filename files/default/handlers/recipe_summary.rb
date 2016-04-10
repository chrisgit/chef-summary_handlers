require 'chef'
require 'chef/handler'
require 'erubis'

# Handler
class Chef
    class Handler
        class RecipeSummary < Chef::Handler

            def report
                # Wrap methods around run_context and run_status
                context_service = ::Handler::RecipeSummary::RunContextService.new node.run_context
                status_service = ::Handler::RecipeSummary::RunStatusService.new run_status
                
                recipes_without_resources = context_service.loaded_recipes - status_service.recipes_with_resources

                summary_report = generate_report({
                        :loaded_recipes => context_service.loaded_recipes,
                        :unused_recipes => context_service.unused_recipes,
                        :recipes_without_resources => recipes_without_resources})

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

# Supporting classes
module Handler
    module RecipeSummary

        class RunContextService
            def initialize(run_context)
                @run_context = run_context
            end

            def loaded_recipes
                @run_context.loaded_recipes.dup
            end

            def all_recipes
                return @all_recipes unless @all_recipes.nil?
                @all_recipes = []
                @run_context.cookbook_collection.each_pair do |cookbook, cookbook_version|
                    cookbook_version.manifest["recipes"].each do |recipe|
                        recipe_name = recipe[:name]
                        recipe_name = File.basename(recipe_name,File.extname(recipe_name))
                        @all_recipes << "#{cookbook}::#{recipe_name}"
                    end
                end
                @all_recipes
            end

            def unused_recipes
                return @unused_recipes unless @unused_recipes.nil?
                @unused_recipes = all_recipes - loaded_recipes
            end
        end

        class RunStatusService
            def initialize(run_status)
                @run_status = run_status
            end

            def recipes_with_resources
                return @recipes_with_resources unless @recipes_with_resources.nil?
                @recipes_with_resources = @run_status.all_resources.map {|resource| "#{resource.cookbook_name}::#{resource.recipe_name}" }.uniq
            end
        end
    end
end
