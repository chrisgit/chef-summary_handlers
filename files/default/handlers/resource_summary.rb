# Libraries used for the handlers
require 'chef'
require 'chef/handler'
require 'erubis'
require 'json'
require 'yaml'

# Handler
class Chef
  class Handler
    class ResourceSummary < Chef::Handler
      def report
        report = ::Handler::ResourceSummary::Report.new(run_status).generate
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
  module ResourceSummary
    # Take data and build report
    class Report
      TEMPLATES = {
        :by_cookbook => 'resource_by_cookbook.erb',
        :by_type => 'resource_by_type.erb' }.freeze

      def initialize(run_status)
        @run_status = run_status
        @node = @run_status.node
        @data = []
      end

      def report_type
        type = @node.attributes['summary-handlers']['resource-summary']['report_type']
        return type if [:by_cookbook, :by_type].include?(type)
        :by_cookbook
      end

      def report_format
        format = @node.attributes['summary-handlers']['resource-summary']['report_format']
        return format if [:json, :template, :yaml].include?(format)
        :template
      end

      def updated_only
        @node.attributes['summary-handlers']['resource-summary']['updated_only']
      end

      def user_filter
        @node.attributes['summary-handlers']['resource-summary']['user_filter']
      end

      # Generate method is factory and also runs one of the generators?
      def generate
        filtered_resources = remove_resources_from_this_cookbook(resources_to_report)
        filtered_resources = apply_user_filter(filtered_resources, user_filter)

        @data = group_data(filtered_resources)
        case report_format
        when :template
          return generate_template
        when :json
          return JSON.pretty_generate(@data)
        when :yaml
          return @data.to_yaml
        end
      end

      private

      def resources_to_report
        updated_only ? @run_status.updated_resources.dup : @run_status.all_resources.dup
      end

      def remove_resources_from_this_cookbook(report_data)
        handler_cookbook = report_data.select { |resource| resource.respond_to?(:handler_class) && resource.handler_class == Chef::Handler::ResourceSummary.to_s }
        return report_data unless handler_cookbook[0]
        report_data.reject { |resource| resource.cookbook_name == handler_cookbook[0].cookbook_name }
      end

      def apply_user_filter(report_data, user_filter)
        return report_data unless user_filter
        return report_data unless user_filter.class == Proc || user_filter.arity != 1
        report_data.select { |resource| user_filter.call(resource) }
      end

      def group_data(report_data)
        return report_data.group_by { |r| "#{r.cookbook_name}::#{r.recipe_name}" } if report_type == :by_cookbook
        report_data.group_by { |r| "#{r.resource_name}::#{r.cookbook_name}::#{r.recipe_name}" }
      end

      def generate_template
        template = TEMPLATES[report_type]
        # In Template can call resource.name, resource.updated etc
        template = ::File.join(File.dirname(__FILE__), 'Templates', template)
        erb = ::Erubis::Eruby.new(File.read(template))
        erb.evaluate(self)
      end
    end
  end
end
