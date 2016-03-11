#
# Cookbook Name:: supermarket-omnibus-cookbook
# Recipe:: default
#
# Copyright (c) 2014 The Authors, All Rights Reserved.

# Build the Supermarket server with this recipe if you use the node attributes.
# If you wish to not use attributes, you may use the supermarket_server
# resource/provider within your cookbook and pass attributes to the resource.

supermarket_server 'supermarket' do
  chef_server_url node['supermarket_omnibus']['chef_server_url']
  chef_oauth2_app_id node['supermarket_omnibus']['chef_oauth2_app_id']
  chef_oauth2_secret node['supermarket_omnibus']['chef_oauth2_secret']
  chef_oauth2_verify_ssl node['supermarket_omnibus']['chef_oauth2_verify_ssl']
  config node['supermarket_omnibus']['config'].to_hash
  reconfig_after_upgrades node['supermarket_omnibus']['reconfig_after_upgrades']
  restart_after_upgrades node['supermarket_omnibus']['restart_after_upgrades']
  supermarket_version node['supermarket_omnibus']['package_version']
  action :create
end

include_recipe 'supermarket-omnibus-cookbook::upgrades'
