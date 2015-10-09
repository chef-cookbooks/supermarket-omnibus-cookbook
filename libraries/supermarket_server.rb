require 'chef/resource'
require 'chef/provider'

class Chef
  class Resource
    # Missing top-level class documentation comment
    class SupermarketServer < Chef::Resource
      def initialize(name, run_context = nil)
        super
        @resource_name = :supermarket_server
        @provider = Chef::Provider::SupermarketServer
        @action = :create
        @allowed_actions = [:create]
      end

      def chef_server_url(arg = nil)
        set_or_return(:chef_server_url, arg, kind_of: [String], required: true)
      end

      def chef_oauth2_app_id(arg = nil)
        set_or_return(:chef_oauth2_app_id, arg, kind_of: [String], required: true)
      end

      def chef_oauth2_secret(arg = nil)
        set_or_return(:chef_oauth2_secret, arg, kind_of: [String], required: true)
      end

      def chef_oauth2_verify_ssl(arg = nil)
        set_or_return(:chef_oauth2_verify_ssl, arg, kind_of: [TrueClass, FalseClass], required: true)
      end

      def config(arg = nil)
        set_or_return(:config, arg, kind_of: [Hash])
      end
    end
  end
end

class Chef
  class Provider
    # Missing top-level class documentation comment
    class SupermarketServer < Chef::Provider::LWRPBase
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      def supermarket_config
        {
          'chef_server_url' => new_resource.chef_server_url,
          'chef_oauth2_app_id' => new_resource.chef_oauth2_app_id,
          'chef_oauth2_secret' => new_resource.chef_oauth2_secret,
          'chef_oauth2_verify_ssl' => new_resource.chef_oauth2_verify_ssl
        }
      end

      def merged_supermarket_config
        new_resource.config.merge(supermarket_config)
      end

      action :create do
        hostsfile_entry node['ipaddress'] do
          hostname node['hostname']
          not_if "grep #{node['hostname']} /etc/hosts"
        end

        directory '/etc/supermarket' do
          owner 'root'
          group 'root'
          mode '0755'
        end

        file '/etc/supermarket/supermarket.json' do
          owner 'root'
          group 'root'
          mode '0644'
          content JSON.pretty_generate(merged_supermarket_config)
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
