# Libraries used for the handlers
require 'chef'
require 'chef/handler'
require 'erubis'

# Handler
class Chef
  class Handler
    class CookbookSummary < Chef::Handler
      def report
        report = ::Handler::CookbookSummary::Report.new(run_status).generate
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
    class Report
      def initialize(run_status)
        @run_context = run_status.run_context
        @cookbook_collection = @run_context.cookbook_collection
      end

      def cookbooks
        @cookbook_collection.keys
      end

      def recipes(cookbook)
        @cookbook_collection[cookbook].manifest['recipes']
      end

      def loaded_recipes(cookbook)
        @run_context.loaded_recipes.select { |recipe| recipe.split('::')[0] == cookbook }
      end

      def description(cookbook)
        @cookbook_collection[cookbook].metadata.description
      end

      def maintainer(cookbook)
        @cookbook_collection[cookbook].metadata.maintainer
      end

      def version(cookbook)
        @cookbook_collection[cookbook].metadata.version
      end

      def generate
        template = ::File.join(File.dirname(__FILE__), 'Templates', 'cookbook_summary.erb')
        erb = ::Erubis::Eruby.new(File.read(template))
        erb.evaluate(self)
      end
    end
  end
end
