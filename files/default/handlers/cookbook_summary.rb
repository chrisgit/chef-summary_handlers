# Libraries used for the handlers
require 'chef'
require 'chef/handler'
require 'erubis'

# Handler
class Chef
  class Handler
    class CookbookSummary < Chef::Handler

        def report
            report = ::Handler::CookbookSummary::ReportGenerator.new(run_status).generate
            show_report(report)
        end
        
        def show_report(report_data)
            puts report_data
        end
    end
  end
end

# Supporting methods
module Handler
    module CookbookSummary

        # Take data and build report
        class ReportGenerator
            
            def initialize(run_status)
                @run_status = run_status
                @run_context = run_status.run_context
            end
            
            def cookbooks
                @run_context.cookbook_collection.keys
            end
            
            def cookbook_recipe_count(cookbook)
                @run_context.cookbook_collection[cookbook].manifest['recipes'].count
            end
            
            def cookbook_loaded_recipe_count(cookbook)
                @run_context.loaded_recipes.count {|recipe| recipe.split('::')[0] == cookbook}
            end
            
            def description(cookbook)
                @run_context.cookbook_collection[cookbook].metadata.description
            end
            
            def maintainer(cookbook)
                @run_context.cookbook_collection[cookbook].metadata.maintainer
            end
            
            def version(cookbook)
                @run_context.cookbook_collection[cookbook].metadata.version
            end
            
            # Generate method is factory and also runs one of the generators?
            def generate()
                template = ::File.join(File.dirname(__FILE__), 'Templates', 'cookbook_summary.erb')
                erb = ::Erubis::Eruby.new(File.read(template))
                erb.evaluate(self)
           end            
        end

    end
end
