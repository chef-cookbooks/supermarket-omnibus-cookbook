#
# Cookbook Name:: supermarket-omnibus-cookbook
# Recipe:: default
#
# Copyright (c) 2014 The Authors, All Rights Reserved.

# # Configure Supermarket server hostname in /etc/hosts if it isn't there (AWS)
# hostsfile_entry node['ipaddress'] do
#   hostname node.hostname
#   not_if "grep #{node.hostname} /etc/hosts"
# end

directory '/etc/supermarket' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
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

template '/etc/supermarket/supermarket.json' do
  source 'supermarket.json.erb'
  owner 'root'
  group 'root'
  mode "0644"
  variables(
        :chef_server_url => node['supermarket_omnibus']['chef_server_url'],
        :chef_oauth2_app_id => get_supermarket_attribute('uid'),
        :chef_oauth2_secret => get_supermarket_attribute('secret'),
        :chef_oauth2_verify_ssl => node['supermarket_omnibus']['chef_oauth2_verify_ssl']
  )
  action :create
  notifies :reconfigure, 'chef_server_ingredient[supermarket]'
end