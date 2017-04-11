#
# Cookbook:: supermarket-omnibus-cookbook
# Resource:: supermarket_server
#
# Copyright:: 2015-2017, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

provides :supermarket_server

property :instance_name, String, name_property: true
property :chef_server_url, String, required: true
property :chef_oauth2_app_id, String, required: true
property :chef_oauth2_secret, String, required: true
property :chef_oauth2_verify_ssl, [true, false], required: true
property :config, Hash

action :create do
  hostsfile_entry node['ipaddress'] do
    hostname node['hostname']
    not_if "grep #{node['hostname']} /etc/hosts"
  end

  if node['supermarket_omnibus']['package_url']
    pkgname = ::File.basename(node['supermarket_omnibus']['package_url'])
    cache_path = ::File.join(Chef::Config[:file_cache_path], pkgname).gsub(/~/, '-') # rubocop:disable Performance/StringReplacement

    # recipe
    remote_file cache_path do
      source node['supermarket_omnibus']['package_url']
      mode '0644'
    end
  end

  if node['supermarket_omnibus']['custom_repo_recipe']
    Chef::Log.info "Using custom repo recipe: #{node['supermarket_omnibus']['custom_repo_recipe']}"
    node.normal['chef-ingredient']['custom-repo-recipe'] = node['supermarket_omnibus']['custom_repo_recipe']
  end

  chef_ingredient 'supermarket' do
    channel     node['supermarket_omnibus']['package_repo'].to_sym
    config      JSON.pretty_generate(merged_supermarket_config)
    ctl_command '/opt/supermarket/bin/supermarket-ctl'
    sensitive   true

    # If set, prefer package_url to packages.chef.io.
    if node['supermarket_omnibus']['package_url']
      Chef::Log.info "Using Supermarket package source: #{node['supermarket_omnibus']['package_url']}"
      package_source cache_path
    else
      Chef::Log.info "Using CHEF's public channel #{node['supermarket_omnibus']['package_repo']}"
      version node['supermarket_omnibus']['package_version']
    end
    action [:upgrade, :reconfigure]
  end
end

action_class.class_eval do
  def supermarket_config
    {
      'chef_server_url' => new_resource.chef_server_url,
      'chef_oauth2_app_id' => new_resource.chef_oauth2_app_id,
      'chef_oauth2_secret' => new_resource.chef_oauth2_secret,
      'chef_oauth2_verify_ssl' => new_resource.chef_oauth2_verify_ssl,
    }
  end

  def merged_supermarket_config
    new_resource.config.merge(supermarket_config)
  end
end
