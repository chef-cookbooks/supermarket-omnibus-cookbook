#
# Cookbook Name:: supermarket-omnibus-cookbook
# Recipe:: default
#
# Copyright (c) 2014 The Authors, All Rights Reserved.

# Configure Supermarket server hostname in /etc/hosts if it isn't there (AWS)

include_recipe 'chef-vault'

hostsfile_entry node['ipaddress'] do
  hostname node['hostname']
  not_if "grep #{node['hostname']} /etc/hosts"
end

directory '/etc/supermarket' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Sanity check the chef_server_url attribute for supermarket
unless node['supermarket_omnibus']['chef_server_url'].is_a?(String)
  Chef::Log.fatal("You did not set the node['supermarket_omnibus']['chef_server_url'] value!")
  Chef::Log.fatal('Please set this attribute before continuing')
  fail
end

supermarket_secrets = chef_vault_item('supermarket', 'secrets')

template '/etc/supermarket/supermarket.json' do
  source 'supermarket.json.erb'
  mode '0644'
  variables chef_server_url: node['supermarket_omnibus']['chef_server_url'],
            chef_oauth2_app_id: supermarket_secrets['chef_oauth2_app_id'],
            chef_oauth2_secret: supermarket_secrets['chef_oauth2_secret'],
            chef_oauth2_verify_ssl: node['supermarket_omnibus']['chef_oauth2_verify_ssl']
  sensitive true
  notifies :reconfigure, 'chef_ingredient[supermarket]'
end

if node['supermarket_omnibus']['package_url']
  pkgname = ::File.basename(node['supermarket_omnibus']['package_url'])
  cache_path = ::File.join(Chef::Config[:file_cache_path], pkgname).gsub(/~/, '-')

  # recipe
  remote_file cache_path do
    source node['supermarket_omnibus']['package_url']
    mode '0644'
  end
end

case node['platform_family']
when 'debian'
  node.default['apt-chef']['repo_name'] = node['supermarket_omnibus']['package_repo']
when 'rhel'
  node.default['yum-chef']['repositoryid'] = node['supermarket_omnibus']['package_repo']
end

chef_ingredient 'supermarket' do
  ctl_command '/opt/supermarket/bin/supermarket-ctl'

  # Prefer package_url if set over custom repository
  if node['supermarket_omnibus']['package_url']
    Chef::Log.info "Using Supermarket package source: #{node['supermarket_omnibus']['package_url']}"
    package_source cache_path
  else
    Chef::Log.info "Using CHEF's public repository #{node['supermarket_omnibus']['package_repo']}"
    version node['supermarket_omnibus']['package_version']
  end

  notifies :reconfigure, 'chef_ingredient[supermarket]'
end
