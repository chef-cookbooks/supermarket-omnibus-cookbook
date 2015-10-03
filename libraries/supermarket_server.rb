require 'chef/resource/lwrp_base'
require 'chef/provider/lwrp_base'

class Chef
  class Resource
    # Missing top-level class documentation comment
    class SupermarketServer < Chef::Resource::LWRPBase
      resource_name :supermarket_server
      default_action :create

      attribute :chef_server_url, kind_of: String
      attribute :chef_oauth2_verify_ssl, kind_of: [TrueClass, FalseClass]
      attribute :chef_oauth2_app_id, kind_of: String
      attribute :chef_oauth2_secret, kind_of: String
    end
  end
end

class Chef
  class Provider
    # Missing top-level class documentation comment
    class SupermarketServer < Chef::Provider::LWRPBase
      provides :supermarket_server
      use_inline_resources

      def supermarket_config
        {
          'chef_server_url' => new_resource.chef_server_url,
          'chef_oauth2_app_id' => new_resource.chef_oauth2_app_id,
          'chef_oauth2_secret' => new_resource.chef_oauth2_secret,
          'chef_oauth2_verify_ssl' => new_resource.chef_oauth2_verify_ssl
        }
      end

      action :create do
        %w(chef_server_url chef_oauth2_app_id chef_oauth2_secret).each do |attr|
          unless supermarket_config[attr].is_a?(String)
            Chef::Log.fatal("You did not provide the node #{attr} value!")
            fail
          end
        end

        template '/etc/supermarket/supermarket.json' do
          source 'supermarket.json.erb'
          mode '0644'
          variables chef_server_url: supermarket_config['chef_server_url'],
                    chef_oauth2_app_id: supermarket_config['chef_oauth2_app_id'],
                    chef_oauth2_secret: supermarket_config['chef_oauth2_secret'],
                    chef_oauth2_verify_ssl: supermarket_config['chef_oauth2_verify_ssl']
          sensitive true
          notifies :reconfigure, 'chef_ingredient[supermarket]'
        end

        if node['supermarket_omnibus']['package_url']
          pkgname = ::File.basename(node['supermarket_omnibus']['package_url'])
          cache_path = ::File.join(Chef::Config[:file_cache_path], pkgname).gsub(/~/, '-')

          # recipe
          remote_file cache_path do
            source node['supermarket_omnibus']['package_url']
            mode '0644'
          end
        end

        case node['platform_family']
        when 'debian'
          node.default['apt-chef']['repo_name'] = node['supermarket_omnibus']['package_repo']
        when 'rhel'
          node.default['yum-chef']['repositoryid'] = node['supermarket_omnibus']['package_repo']
        end

        chef_ingredient 'supermarket' do
          ctl_command '/opt/supermarket/bin/supermarket-ctl'

          # Prefer package_url if set over custom repository
          if node['supermarket_omnibus']['package_url']
            Chef::Log.info "Using Supermarket package source: #{node['supermarket_omnibus']['package_url']}"
            package_source cache_path
          else
            Chef::Log.info "Using CHEF's public repository #{node['supermarket_omnibus']['package_repo']}"
            version node['supermarket_omnibus']['package_version']
          end
        end
      end
    end
  end
end
