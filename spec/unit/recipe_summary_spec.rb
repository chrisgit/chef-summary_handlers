# Test recipe summary handler
# Ensures that the report receives the correct loaded_recipes, unused_recipes and recipes_without_resources
require 'spec_helper'
require_relative './recipe_summary_helper'

# Testing is a moot point here ...
# If I used Mocks/Stubs/Fakes the underlying Chef code could change and the tests may not break
# If I use the real Chef objects (as below) then my tests could break should Chef change (but then it's likely my handler will fail too)
describe Chef::Handler::RecipeSummary  do

    before(:each) do
        @handler = Chef::Handler::RecipeSummary.new 
        run_context = create_run_context
        load_resources(run_context)
        load_recipes(run_context)
        run_status = Chef::RunStatus.new(run_context.node, run_context.events)
        run_status.run_context = run_context
        
        @handler.instance_variable_set(:@run_status, run_status)
    end
    
    describe 'when handler is run' do 
        it 'supplies loaded_recipes, unused_recipes and recipes_without_resources' do
            expect(@handler).to receive(:generate_report).with({
                :loaded_recipes=>['nginx::default', 'hipchat::default'],
                :unused_recipes=>['apache2::default', 'openldap::default', 'openldap::gigantor', 'openldap::one', 'openldap::return'],
                :recipes_without_resources=>['hipchat::default']})
                            
        @handler.report
        end
   end
end
