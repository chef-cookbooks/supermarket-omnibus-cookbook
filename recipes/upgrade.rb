node.set['supermarket_omnibus']['upgrade_enabled'] = true
node.set['supermarket_omnibus']['restart_after_upgrades'] = true

unless node['supermarket_omnibus']['upgrade_enabled']
  Chef::Log.fatal('The supermarket-omnibus-cookbook::upgrade recipe was added to the node,')
  Chef::Log.fatal('however the attribute `node["supermarket_omnibus"]["upgrade_enabled"]` was not set.')
  Chef::Log.fatal('Bailing out here so this node does not upgrade.')
  raise
end

  require 'set'

  file "/root/chef_resources-#{node.name}.json" do
    resource_clxn = Chef::ResourceCollection.new
    run_context.resource_collection.each do |r|
      next if r.class.to_s == 'Chef::Resource::NodeMetadata'
      r = r.dup
      r.instance_eval do
        content('')   if respond_to?(:content)
        variables({}) if respond_to?(:variables)
        remove_instance_variable('@options') rescue nil
        params.delete(:options) if respond_to?(:params)
        # if respond_to?(:options)
        #   begin ; options({})  ; rescue options('') ; end
        # end
        @delayed_notifications = []
        @immediate_notifications = []
      end
      resource_clxn << r
    end
    content       resource_clxn.to_json(JSON::PRETTY_STATE_PROTOTYPE)+"\n"
    action        :create
    owner         'root'
    group         'root'
    mode          "0600" # only readable by root
  end

#walk_resource_path

#resources(apt_package: 'supermarket').notifies :reconfigure, 'supermarket_server[supermarket]'
#resources(supermarket_server: 'supermarket').notifies :reconfigure, 'supermarket_server[supermarket]'
#resources(Chef::Resource::SupermarketServer::chef_ingredient: 'supermarket').notifies :reconfigure, 'supermarket_server[supermarket]'
#resources(supermarket_server: 'supermarket').action :upgrade
