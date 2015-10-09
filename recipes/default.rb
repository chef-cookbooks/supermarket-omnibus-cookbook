#
# Cookbook Name:: supermarket-omnibus-cookbook
# Recipe:: default
#
# Copyright (c) 2014 The Authors, All Rights Reserved.

# Configure Supermarket server hostname in /etc/hosts if it isn't there (AWS)

supermarket_server 'supermarket' do
  chef_server_url node['supermarket_omnibus']['chef_server_url']
  chef_oauth2_app_id node['supermarket_omnibus']['chef_oauth2_app_id']
  chef_oauth2_secret node['supermarket_omnibus']['chef_oauth2_secret']
  chef_oauth2_verify_ssl node['supermarket_omnibus']['chef_oauth2_verify_ssl']
  config node['supermarket_omnibus']['config'].to_hash
end
