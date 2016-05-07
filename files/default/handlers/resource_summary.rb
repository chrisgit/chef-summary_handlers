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
            report_type, report_format, user_filter = report_settings

            filtered_resources = remove_resources_from_this_cookbook(resources_to_report)
            filtered_resources = apply_user_filter(filtered_resources, user_filter)

            report_data = group_data(report_type, filtered_resources)
            report = ::Handler::ResourceSummary::ReportGenerator.new(report_format, report_type, report_data).generate
            show_report(report)
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
            [resource_summary_settings['report_type'], resource_summary_settings['report_format'], resource_summary_settings['user_filter']]
        end
        
        def  group_data(report_type, report_data)
            return report_data.group_by {|r| "#{r.cookbook_name}::#{r.recipe_name}"} if report_type == :by_cookbook
            report_data.group_by {|r| "#{r.resource_name}::#{r.cookbook_name}::#{r.recipe_name}" }                
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
        class ReportGenerator
            
            TEMPLATES = {:by_cookbook => 'resource_by_cookbook.erb', :by_type => 'resource_by_type.erb'}
            def initialize(report_format, report_type, report_data)
                @report_format = report_format
                @report_type = report_type
                @data = report_data
            end
            
            # Generate method is factory and also runs one of the generators?
            def generate()
                case @report_format
                    when :template
                        return generate_template
                    when :json
                        return JSON.pretty_generate(@report_data)
                    when :yaml
                        return @report_data.to_yaml
                end
            end
            
            private
            def generate_template()
                template = TEMPLATES[@report_type]
                # In Template can call resource.name, resource.updated etc
                template = ::File.join(File.dirname(__FILE__), 'Templates', template)
                erb = ::Erubis::Eruby.new(File.read(template))
                erb.evaluate(self)
           end            
        end

    end
end
