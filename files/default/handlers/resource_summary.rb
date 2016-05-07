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
            report_type, report_format, report_writer, user_filter = report_settings

            filtered_resources = remove_resources_from_this_cookbook(resources_to_report)
            filtered_resources = apply_user_filter(filtered_resources, user_filter)

            report_data = ::Handler::ResourceSummary::DataFormatter.format(report_type, filtered_resources)
            report = ::Handler::ResourceSummary::ReportGenerator.generate(report_format, report_type, report_data)
            ::Handler::ResourceSummary::ReportWriter.output(report)
        end

        def remove_resources_from_this_cookbook(report_data)
            handler_cookbook = report_data.select{|resource| resource.respond_to?(:handler_class) && resource.handler_class == self.class.to_s}
            return report_data unless handler_cookbook[0]
            report_data.reject  {|resource| resource.cookbook_name == handler_cookbook[0].cookbook_name}
        end

        def apply_user_filter(report_data, user_filter)
            return report_data unless user_filter
            return report_data unless user_filter.class == Proc || user_filter.arity != 1
            report_data.select {|resource| user_filter.call(resource)}
        end

        def resources_to_report
            run_status.all_resources.dup
        end

        def report_settings
            resource_summary_settings = node.attributes['summary-handlers']['resource-summary']
            [resource_summary_settings['report_type'], resource_summary_settings['report_format'], resource_summary_settings['report_writer'], resource_summary_settings['user_filter']]
        end
    end
  end
end

# Supporting methods
module Handler
    module ResourceSummary
    # Take the report resources and change the structure for reporting :by_cookbook or :by_type
        class DataFormatter
            def  self.format(report_type, report_data)
                return report_data.group_by {|r| "#{r.cookbook_name}::#{r.recipe_name}"} if report_type == :by_cookbook
                report_data.group_by {|r| "#{r.resource_name}::#{r.cookbook_name}::#{r.recipe_name}" }                
            end
        end

        # Take data and build report
        class ReportGenerator

            TEMPLATES = {:by_cookbook => 'resource_by_cookbook.erb', :by_type => 'resource_by_type.erb'}
            # Generate method is factory and also runs one of the generators?
            def self.generate(report_format, report_type, report_data)
                case report_format
                    when :template
                        return generate_template(report_type, report_data)
                    when :json
                        return JSON.pretty_generate(report_data)
                    when :yaml
                        return report_data.to_yaml
                end
            end
            
            private
            def self.generate_template(report_type, report_data)
                template = TEMPLATES[report_type]
                report = {:data => report_data}
                # In Template can call resource.name, resource.updated etc
                template = ::File.join(File.dirname(__FILE__), 'Templates', template)
                erb = ::Erubis::Eruby.new(File.read(template))
                erb.evaluate(report)
           end            
        end

        # Output report
        class ReportWriter
            def self.output(report)
                puts report
            end
        end
    end
end
