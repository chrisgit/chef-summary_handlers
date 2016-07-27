#
# Cookbook Name:: summary_handlers
# Providers:: install_handler
#
use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :install do
  handler_name = @new_resource.name
  handler_name = "#{handler_name}.rb" unless handler_name.end_with?('.rb')

  converge_by("#{new_resource.name}: Creating #{node['chef_handler']['handler_path']}/Templates directory") do
    directory "#{node['chef_handler']['handler_path']}/Templates" do
      mode '0755'
      recursive true
      action :create
    end
  end

  handler = ::File.join(node['chef_handler']['handler_path'], handler_name)
  converge_by("#{new_resource.name}: Copying handler file #{handler_name}") do
    cookbook_file handler do
      source "handlers/#{handler_name}"
      mode '0644'
      action :create
    end
  end

  @new_resource.templates.each do |template|
    template_file = ::File.join(node['chef_handler']['handler_path'], 'Templates', template)
    converge_by("#{new_resource.name}: Copying template file #{template_file}") do
      cookbook_file template_file do
        source "handlers/Templates/#{template}"
        mode '0644'
        action :create
      end
    end
  end

  converge_by("#{new_resource.name}: Registering handler #{new_resource.handler_class}") do
    chef_handler @new_resource.handler_class do
      source handler
      action :enable
      only_if { ::File.exist?(handler) }
    end
  end
end
