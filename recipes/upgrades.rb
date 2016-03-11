## Cookbook Name:: supermarket-omnibus-cookbook
## Recipe:: upgrade
##
## Copyright (c) 2014 The Authors, All Rights Reserved.
#

unless node['supermarket_omnibus']['upgrades_enabled']
  Chef::Log.warn('The attribute `node["supermarket_omnibus"]["upgrades_enabled"]` is not set to true.')
  Chef::Log.warn('Will not attempt upgrades on this node.')
  return
end

resources(supermarket_server: 'supermarket').action :upgrade
