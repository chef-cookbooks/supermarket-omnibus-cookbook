# Configure a custom repository setup recipe
node.normal['supermarket_omnibus']['custom_repo_recipe'] = 'custom_repo::custom_repo_recipe'

supermarket_server 'supermarket' do
  chef_server_url node['supermarket_omnibus']['chef_server_url']
  chef_oauth2_app_id node['supermarket_omnibus']['chef_oauth2_app_id']
  chef_oauth2_secret node['supermarket_omnibus']['chef_oauth2_secret']
  chef_oauth2_verify_ssl node['supermarket_omnibus']['chef_oauth2_verify_ssl']
  config node['supermarket_omnibus']['config'].to_hash
end
