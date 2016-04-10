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

            report_data = ::Handler::ResourceSummary::DataCollector.create(report_type, filtered_resources).format_data
            report = ::Handler::ResourceSummary::ReportGenerator.create(report_format, report_type, report_data).generate
            ::Handler::ResourceSummary::ReportWriter.create(report_writer, report).write
        end

        def remove_resources_from_this_cookbook(report_data)
            handler_cookbook = report_data.select{|resource| resource.name == self.class.to_s}
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
        class DataCollector

            def initialize(report_data)
                @report_data = report_data
            end

            def  self.create(report_type, report_data)
                return DataCollector.new unless SUPPORTED_TYPES.keys.include?(report_type)
                SUPPORTED_TYPES[report_type].new report_data
            end

            def format_data
            end
        end

        # Structure the hash for cookbook => recipe => resources
        class DataCollectorCookbook < DataCollector
            def format_data
                formatted_data = Hash.new()
                @report_data.each do |resource|
                    formatted_data[resource.cookbook_name] = {} unless formatted_data.key?(resource.cookbook_name)
                    formatted_data[resource.cookbook_name][resource.recipe_name] = [] unless formatted_data[resource.cookbook_name].key?(resource.recipe_name)
                    formatted_data[resource.cookbook_name][resource.recipe_name] << resource
                end
                formatted_data
            end
        end

        # Structure the hash for resource type => cookbook => recipe => resources (matching type)
        class DataCollectorType < DataCollector
            def format_data
                formatted_data = Hash.new()
                @report_data.each do |resource|
                    formatted_data[resource.resource_name] = {} unless formatted_data.key?(resource.resource_name)
                    formatted_data[resource.resource_name][resource.cookbook_name] =  {} unless formatted_data[resource.resource_name].key?(resource.cookbook_name)
                    formatted_data[resource.resource_name][resource.cookbook_name][resource.recipe_name] =  [] unless formatted_data[resource.resource_name][resource.cookbook_name].key?(resource.recipe_name)
                    formatted_data[resource.resource_name][resource.cookbook_name][resource.recipe_name] << resource
                end
                formatted_data
            end
        end

        class DataCollector
            SUPPORTED_TYPES = {:by_cookbook => DataCollectorCookbook, :by_type => DataCollectorType}
        end

        # Take data and build report
        class ReportGenerator

            def initialize(report_type = nil, report_data = nil)
                @report_type = report_type
                @report_data = report_data
            end

            # Generate method is factory and also runs one of the generators?
            def self.create(report_format, report_type, report_data)
                return ReportGenerator.new unless SUPPORTED_TYPES.keys.include?(report_format)
                SUPPORTED_TYPES[report_format].new report_type, report_data
            end

            def generate()
                # Raise not implimented, leave for time being as will act as Null object
                ''
            end
        end

        # Raw data to JSON
        class ReportGeneratorJson < ReportGenerator
            def generate()
                #@report_data.to_json
                JSON.pretty_generate(@report_data)
            end
        end

        # Raw data to YAML
        class ReportGeneratorYAML < ReportGenerator
            def generate()
                @report_data.to_yaml
            end
        end

        # Raw data formatted with Template
        class ReportGeneratorTemplate < ReportGenerator
            TEMPLATES = {:by_cookbook => 'resource_by_cookbook.erb', :by_type => 'resource_by_type.erb'}

            def generate()
                template = TEMPLATES[@report_type]
                report = {:data => @report_data}
                # In Template can call resource.name, resource.updated etc
                template = ::File.join(File.dirname(__FILE__), 'Templates', template)
                erb = ::Erubis::Eruby.new(File.read(template))
                erb.evaluate(report)
            end
        end

        class ReportGenerator
            SUPPORTED_TYPES = {:template => ReportGeneratorTemplate, :json => ReportGeneratorJson, :yaml => ReportGeneratorYAML}
        end

        # Output report
        class ReportWriter
            def initialize(report)
                @report = report
            end

            def self.create(report_writer, report)
                ReportWriterStdio.new report
            end
        end

        class ReportWriterStdio < ReportWriter
            def write
                puts @report
            end
        end
    end
end
