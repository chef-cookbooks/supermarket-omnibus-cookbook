#
# Cookbook:: supermarket-omnibus-cookbook
# Recipe:: default
#
# Copyright:: 2014-2017, Chef Software, Inc.
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

# Build the Supermarket server with this recipe if you use the node attributes.
# If you wish to not use attributes, you may use the supermarket_server
# resource/provider within your cookbook and pass attributes to the resource.

supermarket_server 'supermarket' do
  chef_server_url node['supermarket_omnibus']['chef_server_url']
  chef_oauth2_app_id node['supermarket_omnibus']['chef_oauth2_app_id']
  chef_oauth2_secret node['supermarket_omnibus']['chef_oauth2_secret']
  chef_oauth2_verify_ssl node['supermarket_omnibus']['chef_oauth2_verify_ssl']
  config node['supermarket_omnibus']['config'].to_hash
end
