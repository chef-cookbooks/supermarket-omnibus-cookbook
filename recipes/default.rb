#
# Cookbook Name:: supermarket-omnibus-cookbook
# Recipe:: default
#
# Copyright (c) 2014 The Authors, All Rights Reserved.

# Configure Supermarket server hostname in /etc/hosts if it isn't there (AWS)
hostsfile_entry node['ipaddress'] do
  hostname node.hostname
  not_if "grep #{node.hostname} /etc/hosts"
end

directory '/etc/supermarket' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Sanity check the oc-id attributes
%w(chef_server_url chef_oauth2_app_id chef_oauth2_secret).each do |attr|
  unless node['supermarket_omnibus'][attr].is_a?(String)
    Chef::Log.fatal("You did not set the node['supermarket_omnibus']['#{attr}'] value!")
    Chef::Log.fatal('Please set this attribute before continuing')
    raise
  end
end

file '/etc/supermarket/supermarket.json' do
  action :create
  owner "root"
  group "root"
  mode "0644"
  content JSON.pretty_generate(node['supermarket_omnibus'])
  notifies :reconfigure, 'chef_server_ingredient[supermarket]'
end

chef_server_ingredient 'supermarket' do
  ctl_command '/opt/supermarket/bin/supermarket-ctl'

  # Prefer package_source if set over custom repository
  if node['supermarket_package']['package_source']
    Chef::Log.info "Using Supermarket package source: #{node['supermarket_package']['package_source']}"
    package_source node['supermarket_package']['package_source']
  else
    Chef::Log.info "Using Supermarket packagecloud repo #{node['supermarket_package']['packagecloud_repo']}"
    repository node['supermarket_package']['packagecloud_repo']
  end

  notifies :reconfigure, 'chef_server_ingredient[supermarket]'
end
