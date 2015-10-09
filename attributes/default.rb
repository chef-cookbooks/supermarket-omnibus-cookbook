
default['supermarket_omnibus']['chef_server_url'] = nil
default['supermarket_omnibus']['chef_oauth2_app_id'] = nil
default['supermarket_omnibus']['chef_oauth2_secret'] = nil
default['supermarket_omnibus']['chef_oauth2_verify_ssl'] = false
default['supermarket_omnibus']['config'] = {}

default['supermarket_omnibus']['package_url'] = nil
default['supermarket_omnibus']['package_version'] = :latest
default['supermarket_omnibus']['package_repo'] = 'chef-stable'
# use the following to consume nightly builds of packagecloud:
# default['supermarket_omnibus']['package_repo'] = 'chef-current'
