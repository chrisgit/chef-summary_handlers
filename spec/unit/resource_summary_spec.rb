# Test recipe summary handler
require 'spec_helper'
require 'unit/summary_helper'

describe Handler::ResourceSummary::Report  do

    before(:each) do
        run_context = create_run_context
        load_resources(run_context)
        load_recipes(run_context)
        @run_status = Chef::RunStatus.new(run_context.node, run_context.events)
        @run_status.run_context = run_context
        @handler_report = Handler::ResourceSummary::Report.new @run_status
    end

    describe '#report_type' do
        [:by_cookbook, :by_type].each do |report_type|
            it "when node set to #{report_type} returns #{report_type}" do
                @run_status.node.set['summary-handlers']['resource-summary']['report_type'] = report_type

                expect(@handler_report.report_type).to eq report_type
            end
        end

        describe 'when node report type not valid' do
            it 'defaults to :by_cookbook' do
                @run_status.node.set['summary-handlers']['resource-summary']['report_type'] = :not_valid

                expect(@handler_report.report_type).to eq :by_cookbook
            end
        end
   end
    describe '#report_format' do
        [:template, :json, :yaml].each do |report_format|
            it "when node set to #{report_format} returns #{report_format}" do
                @run_status.node.set['summary-handlers']['resource-summary']['report_format'] = report_format

                expect(@handler_report.report_format).to eq report_format
            end
        end

        describe 'when report format not valid' do
            it 'defaults to :template' do
                @run_status.node.set['summary-handlers']['resource-summary']['report_format'] = :not_valid

                expect(@handler_report.report_format).to eq :template
            end
        end
   end

    describe '#updated_only' do
        [true, false].each do |updated_setting|
            it "when #{updated_setting}  returns #{updated_setting}" do
                @run_status.node.set['summary-handlers']['resource-summary']['updated_only'] = updated_setting

                expect(@handler_report.updated_only).to eq updated_setting
            end
        end
   end

    describe '#user_filter' do
        ['', nil, proc {'hello world'}].each do |user_filter|
            it "when set to #{user_filter} returns #{user_filter}" do
                @run_status.node.set['summary-handlers']['resource-summary']['user_filter'] = user_filter

                expect(@handler_report.user_filter).to eq user_filter
            end
        end
   end

    describe '#resources_to_report' do
        it "when updated_only attribute true returns updated resources" do
            @run_status.node.set['summary-handlers']['resource-summary']['updated_only'] = true

            expect(@handler_report.resources_to_report.map(&:to_s)).to eq(updated_ngnix_resources.map(&:to_s))
        end
    end

    describe '#resources_to_report' do
        it "when updated_only attribute false returns all resources" do
            @run_status.node.set['summary-handlers']['resource-summary']['updated_only'] = true

            expect(@handler_report.resources_to_report.map(&:to_s)).to eq(updated_ngnix_resources.map(&:to_s))
        end
    end
end
