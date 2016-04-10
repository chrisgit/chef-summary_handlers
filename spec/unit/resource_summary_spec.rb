# Test resource summary report
require 'spec_helper'
require_relative './resource_summary_helper'

describe Chef::Handler::ResourceSummary do

    before(:each) do
        @handler = Chef::Handler::ResourceSummary.new 
        allow(@handler).to receive(:resources_to_report).and_return(build_resources)
    end
    
    # Not too bothered about checking the output of the template as the content can change, user can print any of the attributes available on resouce
    # Data is subject to change too but if we take JSON output we should be able to convert back to original source data to ensure information supplied to 
    # report is correct 
    describe 'when setting is by cookbook' do
        describe 'when the generator is JSON' do
            it 'report JSON pretty by cookbook' do
               allow(@handler).to receive(:report_settings).and_return([:by_cookbook, :json, :stdio, nil])
               expect(Handler::ResourceSummary::ReportWriter).to receive(:create).with(:stdio, JSON.pretty_generate(by_cookbook_hash)).and_call_original
               
               @handler.report
            end
        end
    end


    describe 'when setting is by type' do
        describe 'when the generator is JSON' do
            it 'report JSON pretty by type by cookbook' do
               allow(@handler).to receive(:report_settings).and_return([:by_type, :json, :stdio, nil])
               expect(Handler::ResourceSummary::ReportWriter).to receive(:create).with(:stdio, JSON.pretty_generate(by_type_hash)).and_call_original
                
               @handler.report
            end
        end
        
        describe 'when user filter is applied' do
            it 'report displays only matching items' do
                allow(@handler).to receive(:report_settings).and_return([:by_cookbook, :json, :stdio, Proc.new {|resource| resource.cookbook_name == 'apache'}])
                expect(Handler::ResourceSummary::ReportWriter).to receive(:create).with(:stdio, JSON.pretty_generate(filtered_hash)).and_call_original
                
                @handler.report
            end
        end
    end   
end
