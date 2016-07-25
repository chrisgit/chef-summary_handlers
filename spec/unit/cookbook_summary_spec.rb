# Test recipe summary handler
require 'spec_helper'
require 'unit/summary_helper'

describe Handler::CookbookSummary::Report  do

    before(:each) do
        run_context = create_run_context
        load_resources(run_context)
        load_recipes(run_context)
        run_status = Chef::RunStatus.new(run_context.node, run_context.events)
        run_status.run_context = run_context
        @handler_report = Handler::CookbookSummary::Report.new run_status
    end
    
    describe '#cookbooks' do 
        it 'lists cookbook names' do
            expect(@handler_report.cookbooks).to eq(["apache2", "java", "openldap"])
        end
    end

    describe '#recipes' do 
        { 
            'apache2' => 1,
            'java' => 0,
            'openldap' => 4
        }.each_pair do |cookbook, recipe_count|
            it "returns #{recipe_count} recipes for cookbook #{cookbook}" do

                expect(@handler_report.recipes(cookbook).count).to eq(recipe_count)
            end
        end
   end

    describe '#loaded_recipes' do 
        it 'loaded recipes for the specified cookbook' do
            expect(@handler_report.loaded_recipes('apache2')).to eq(['apache2::default'])
        end
    end

    describe '#description' do 
        it 'description for specified cookbook' do
            expect(@handler_report.description('openldap')).to eq('Installs and configures all aspects of openldap using Debian style symlinks with helper definitions')
        end
    end

end
