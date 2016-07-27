# Test recipe summary handler
require 'spec_helper'
require 'unit/summary_helper'

describe Handler::RecipeSummary::Report do
  before(:each) do
    run_context = create_run_context
    load_resources(run_context)
    load_recipes(run_context)
    run_status = Chef::RunStatus.new(run_context.node, run_context.events)
    run_status.run_context = run_context
    @handler_report = Handler::RecipeSummary::Report.new run_status
  end

  describe '#loaded?' do
    it 'boolean to determine if the cookbook is loaded' do
      expect(@handler_report.loaded?('nginx::default')).to be true
      expect(@handler_report.loaded?('test::recipe')).to be false
    end
  end

  describe '#resources' do
    it 'collection of resources matching specified cookbook and recipe' do
      matching_resources = @handler_report.resources('nginx::default')

      expect(matching_resources.count).to eq(1)
      expect(matching_resources[0].name).to eq('Creating nginx folder')
      expect(matching_resources[0].class).to eq(Chef::Resource::Log)
    end
  end

  describe '#updated_resources' do
    it 'collection of updated resources matching cookbook and recipe' do
      matching_resources = @handler_report.updated_resources('nginx::folder')

      expect(matching_resources.count).to eq(1)
      expect(matching_resources[0].name).to eq('/etc/nginx/default.conf')
      expect(matching_resources[0].class).to eq(Chef::Resource::CookbookFile)
    end
  end

  describe '#cookbook_recipe_shortname' do
    it 'merges cookbook and recipe separated by double colon' do
      cookbook_recipe = @handler_report.cookbook_recipe_shortname('test', 'default.rb')

      expect(cookbook_recipe).to eq('test::default')
    end
  end

  describe '#cookbook_recipes' do
    it 'array of cookbook and recipes' do
      cookbook_recipes = @handler_report.cookbook_recipes

      expect(cookbook_recipes).to eq([
        'apache2::default',
        'openldap::default',
        'openldap::gigantor',
        'openldap::one',
        'openldap::return'])
    end
  end
end
