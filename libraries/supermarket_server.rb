require 'chef/resource'
require 'chef/provider'

class Chef
  class Resource
    # Missing top-level class documentation comment.
    class SupermarketServer < Chef::Resource
      attr_accessor :exists, :supermarket_version

      def initialize(name, run_context = nil)
        super
        @resource_name = :supermarket_server
        @provider = Chef::Provider::SupermarketServer
        @allowed_actions = [:create, :upgrade, :reconfigure]
        @default_action = :create
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

      def reconfig_after_upgrades(arg = nil)
        set_or_return(:reconfig_after_upgrades, arg, kind_of: [TrueClass, FalseClass], required: true)
      end

      def restart_after_upgrades(arg = nil)
        set_or_return(:restart_after_upgrades, arg, kind_of: [TrueClass, FalseClass], required: true)
      end

      def supermarket_version(arg = nil)
        set_or_return(:supermarket_version, arg, kind_of: [String, Symbol], required: true)
      end

      def config(arg = nil)
        set_or_return(:config, arg, kind_of: [Hash])
      end
    end
  end
end

class Chef
  class Provider
    # Missing top-level class documentation comment.
    class SupermarketServer < Chef::Provider::LWRPBase
      SUPERMARKET_VERSION_FILE = '/opt/supermarket/version-manifest.json'.freeze
      SUPERMARKET_CONFIG = '/etc/supermarket/supermarket.json'.freeze

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      def load_current_resource
        @current_resource = Chef::Resource::SupermarketServer.new(@new_resource.name)
        load_version
        Chef::Log.info("Current version: #{@current_resource.supermarket_version}")
        Chef::Log.info("Requested version: #{@new_resource.supermarket_version}")
        @current_resource
      end

      def load_version
        require 'json'
        version_manifest = JSON.parse(::File.read(SUPERMARKET_VERSION_FILE))
        @current_resource.supermarket_version = version_manifest['software']['supermarket']['described_version']
        @current_resource.exists = ::File.exist?(SUPERMARKET_CONFIG) && ::File.exist?(SUPERMARKET_VERSION_FILE)
      rescue
        @current_resource.exists = false
        @current_resource.supermarket_version = nil
      end

      def action_reconfigure
        execute 'reconfigure_supermarket_instance' do
          command 'sudo supermarket-ctl reconfigure'
          only_if { new_resource.reconfig_after_upgrades }
        end

        execute 'restart_supermarket_instance' do
          command 'sudo supermarket-ctl restart'
          only_if { new_resource.restart_after_upgrades }
        end
      end

      def can_upgrade?(vnow, vnext)
        return true if vnow.nil? && vnext == :latest
        Gem::Version.new(vnext) > Gem::Version.new(vnow)
      rescue
        Chef::Log.warn("Cannot upgrade. Please set `node['supermarket_omnibus']['package_version']` to a semantic version.")
        false
      end

      def supermarket_config
        {
          'chef_oauth2_secret' => new_resource.chef_oauth2_secret,
          'chef_oauth2_verify_ssl' => new_resource.chef_oauth2_verify_ssl
        }
      end

      def merged_supermarket_config
        new_resource.config.merge(supermarket_config)
      end

      def action_upgrade
        return unless can_upgrade?(@current_resource.supermarket_version, new_resource.supermarket_version)
        action_create
        action_reconfigure if @current_resource.exists
      end

      def action_create
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
            version new_resource.supermarket_version
          end
        end
      end
    end
  end
end
