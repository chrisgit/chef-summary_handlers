require 'chef'
require 'chef/handler'
require 'erubis'

# Handler
class Chef
  class Handler
    class RecipeSummary < Chef::Handler
      def report
        report = ::Handler::RecipeSummary::Report.new(run_status).generate
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
    class Report
      def initialize(run_status)
        @run_status = run_status
        @run_context = run_status.run_context
      end

      def loaded?(cookbook_recipe)
        @run_context.loaded_recipes.include?(cookbook_recipe)
      end

      def resources(cookbook_recipe)
        cookbook, recipe = cookbook_recipe.split('::')
        @run_status.all_resources.select { |r| r.cookbook_name == cookbook && r.recipe_name == recipe }
      end

      def updated_resources(cookbook_recipe)
        cookbook, recipe = cookbook_recipe.split('::')
        @run_status.updated_resources.select { |r| r.cookbook_name == cookbook && r.recipe_name == recipe }
      end

      def cookbook_recipe_shortname(cookbook, recipe_name)
        # Recipe name is in format of filename plus extension, i.e. default.rb, therefore remove the .rb
        recipe = File.basename(recipe_name, File.extname(recipe_name))
        "#{cookbook}::#{recipe}"
      end

      def cookbook_recipes
        all_recipes = []
        @run_context.cookbook_collection.each_pair do |cookbook, cookbook_version|
          cookbook_version.manifest['recipes'].each do |recipe|
            all_recipes << cookbook_recipe_shortname(cookbook, recipe[:name])
          end
        end
        all_recipes
      end

      def generate
        template = ::File.join(File.dirname(__FILE__), 'Templates', 'recipe_summary.erb')
        erb = ::Erubis::Eruby.new(File.read(template))
        erb.evaluate(self)
      end
    end
  end
end
