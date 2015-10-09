#
# Cookbook Name:: supermarket-omnibus-cookbook
# Spec:: default
#
# Copyright (c) 2015 Irving Popovetsky, All Rights Reserved.

require 'spec_helper'

describe 'supermarket-omnibus-cookbook::default' do
  context 'When all attributes are default, it should fail because of nil checks' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5', step_into: 'supermarket_server')
      runner.converge(described_recipe)
    end

    before do
      stub_command('grep Fauxhai /etc/hosts').and_return('33.33.33.11 Fauxhai')
    end

    it 'raises an error' do
      expect { chef_run }.to raise_exception
    end
  end

  context 'When chef_server (oc-id) attributes are correctly specified' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5', step_into: 'supermarket_server') do |node|
        node.set['supermarket_omnibus']['chef_server_url'] = 'https://chefserver.mycorp.com'
        node.set['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.set['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_lawblaw'
      end
      runner.converge(described_recipe)
    end

    before do
      stub_command('grep Fauxhai /etc/hosts').and_return('33.33.33.11 Fauxhai')
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

    it 'creates the template with the correct values' do
      expect(chef_run).to create_file('/etc/supermarket/supermarket.json').with(
        content: JSON.pretty_generate(chef_server_url: 'https://chefserver.mycorp.com',
                                      chef_oauth2_app_id: 'blahblah',
                                      chef_oauth2_secret: 'bob_lawblaw',
                                      chef_oauth2_verify_ssl: false),
        owner: 'root',
        group: 'root',
        mode: '0644',
        sensitive: true
      )
    end
  end

  context 'When additional config is provided' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5', step_into: %w(chef_ingredient supermarket_server)) do |node|
        node.set['supermarket_omnibus']['package_repo'] = 'chef-current'
        node.set['supermarket_omnibus']['chef_server_url']    = 'https://chefserver.mycorp.com'
        node.set['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.set['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_lawblaw'
        node.set['supermarket_omnibus']['config'] = { 'chef_oauth2_mode' => 'blah' }
      end
      runner.converge(described_recipe)
    end

    before do
      stub_command('grep Fauxhai /etc/hosts').and_return('33.33.33.11 Fauxhai')
    end

    it 'creates the template with the correct values' do
      expect(chef_run).to create_file('/etc/supermarket/supermarket.json').with(
        content: JSON.pretty_generate(chef_oauth2_mode: 'blah',
                                      chef_server_url: 'https://chefserver.mycorp.com',
                                      chef_oauth2_app_id: 'blahblah',
                                      chef_oauth2_secret: 'bob_lawblaw',
                                      chef_oauth2_verify_ssl: false),
        owner: 'root',
        group: 'root',
        mode: '0644',
        sensitive: true
      )
    end
  end

  context 'When a repository chef-current is specified' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5', step_into: %w(chef_ingredient supermarket_server)) do |node|
        node.set['supermarket_omnibus']['package_repo'] = 'chef-current'
        node.set['supermarket_omnibus']['chef_server_url']    = 'https://chefserver.mycorp.com'
        node.set['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.set['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_loblaw'
      end
      runner.converge(described_recipe)
    end

    before do
      stub_command('grep Fauxhai /etc/hosts').and_return('33.33.33.11 Fauxhai')
    end

    it 'includes the yum-chef::default recipe with the chef-current repositoryid' do
      expect(chef_run).to include_recipe('yum-chef::default')
      expect(chef_run.node['yum-chef']['repositoryid']) == 'chef-current'
    end

    it 'creates a package_repository named "chef-current"' do
      expect(chef_run).to create_yum_repository('chef-current')
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end

  context 'When a package_url is specified, packagecloud should not be used' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5', step_into: 'supermarket_server') do |node|
        node.set['supermarket_omnibus']['package_url'] = 'https://web-dl.packagecloud.io/chef/stable/packages/el/6/supermarket-1.10.1~alpha.0-1.el5.x86_64.rpm'
        node.set['supermarket_omnibus']['chef_server_url']    = 'https://chefserver.mycorp.com'
        node.set['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.set['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_loblaw'
      end
      runner.converge(described_recipe)
    end

    before do
      stub_command('grep Fauxhai /etc/hosts').and_return('33.33.33.11 Fauxhai')
    end

    it 'fetches the supermarket package and places it on the filesystem' do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/supermarket-1.10.1-alpha.0-1.el5.x86_64.rpm")
    end

    it 'uses the specified chef_ingredient[supermarket] with a package_url set' do
      expect(chef_run).to install_chef_ingredient('supermarket')
        .with(package_source: ::File.join(Chef::Config[:file_cache_path], 'supermarket-1.10.1-alpha.0-1.el5.x86_64.rpm'))
    end

    it 'does not create a package_repository named "chef-stable"' do
      expect(chef_run).to_not create_yum_repository('chef-stable')
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end

  context 'When a package_url is specified, the Rpm provider should be used on RHEL systems' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5', step_into: %w(chef_ingredient supermarket_server)) do |node|
        node.set['supermarket_omnibus']['package_url'] = 'https://web-dl.packagecloud.io/chef/stable/packages/el/6/supermarket-1.10.1~alpha.0-1.el5.x86_64.rpm'
        node.set['supermarket_omnibus']['chef_server_url']    = 'https://chefserver.mycorp.com'
        node.set['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.set['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_loblaw'
      end
      runner.converge(described_recipe)
    end

    before do
      stub_command('grep Fauxhai /etc/hosts').and_return('33.33.33.11 Fauxhai')
    end

    it 'fetches the supermarket package and places it on the filesystem' do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/supermarket-1.10.1-alpha.0-1.el5.x86_64.rpm")
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end
end
