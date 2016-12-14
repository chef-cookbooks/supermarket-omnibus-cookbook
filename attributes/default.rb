
default['supermarket_omnibus']['chef_server_url'] = nil
default['supermarket_omnibus']['chef_oauth2_app_id'] = nil
default['supermarket_omnibus']['chef_oauth2_secret'] = nil
default['supermarket_omnibus']['chef_oauth2_verify_ssl'] = false
default['supermarket_omnibus']['config'] = {}

default['supermarket_omnibus']['package_url'] = nil
default['supermarket_omnibus']['package_version'] = :latest
default['supermarket_omnibus']['package_repo'] = 'stable'

# Specify a recipe to install supermarket from a custom repo.
default['supermarket_omnibus']['custom_repo_recipe'] = nil

# Enable collaborator groups
default['supermarket_omnibus']['config']['features'] = 'tools, gravatar, collaborator_groups'

# use the following to consume integration builds:
# default['supermarket_omnibus']['package_repo'] = 'current'
