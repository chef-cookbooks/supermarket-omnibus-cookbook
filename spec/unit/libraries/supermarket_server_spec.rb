#
# Cookbook:: supermarket-omnibus-cookbook
# Spec:: default
#
# Copyright:: 2015-2017, Irving Popovetsky, All Rights Reserved.

require 'spec_helper'
require 'mixlib/install'

describe 'supermarket-omnibus-cookbook::default' do
  context 'When all attributes are default, it should fail because of nil checks' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.9', step_into: 'supermarket_server')
      runner.converge(described_recipe)
    end

    before do
      stub_command('grep Fauxhai /etc/hosts').and_return('33.33.33.11 Fauxhai')
    end

    it 'raises an error' do
      expect { chef_run }.to raise_exception(Chef::Exceptions::ValidationFailed)
    end
  end

  context 'When chef_server (oc-id) attributes are correctly specified' do
    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.9', step_into: 'supermarket_server') do |node|
        node.normal['supermarket_omnibus']['chef_server_url'] = 'https://chefserver.mycorp.com'
        node.normal['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.normal['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_lawblaw'
        node.normal['supermarket_omnibus']['config']['features'] = 'tools, gravatar, collaborator_groups'
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
      expect(chef_run).to upgrade_chef_ingredient('supermarket').with(
        config: JSON.pretty_generate(features: 'tools, gravatar, collaborator_groups',
                                     chef_server_url: 'https://chefserver.mycorp.com',
                                     chef_oauth2_app_id: 'blahblah',
                                     chef_oauth2_secret: 'bob_lawblaw',
                                     chef_oauth2_verify_ssl: false),
        sensitive: true
      )
    end
  end

  context 'When additional config is provided' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.9', step_into: %w(chef_ingredient supermarket_server)) do |node|
        node.normal['supermarket_omnibus']['package_repo'] = 'current'
        node.normal['supermarket_omnibus']['chef_server_url']    = 'https://chefserver.mycorp.com'
        node.normal['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.normal['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_lawblaw'
        node.normal['supermarket_omnibus']['config'] = { 'chef_oauth2_mode' => 'blah' }
      end
      runner.converge(described_recipe)
    end

    before do
      artifact_info = instance_double('artifact info',
                                      url: 'https://packages.chef.io/current/el/6/supermarket-300.30.3-1.el6.x86_64.rpm',
                                      sha256: 'f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b')
      installer = instance_double('installer',
                                  artifact_info: artifact_info)
      allow_any_instance_of(Chef::Provider::ChefIngredient).to receive(:installer).and_return(installer)
      stub_command('grep Fauxhai /etc/hosts').and_return('33.33.33.11 Fauxhai')
    end

    it 'creates the template with the correct values' do
      expect(chef_run).to upgrade_chef_ingredient('supermarket').with(
        config: JSON.pretty_generate(features: 'tools, gravatar, collaborator_groups',
                                     chef_oauth2_mode: 'blah',
                                     chef_server_url: 'https://chefserver.mycorp.com',
                                     chef_oauth2_app_id: 'blahblah',
                                     chef_oauth2_secret: 'bob_lawblaw',
                                     chef_oauth2_verify_ssl: false),
        sensitive: true
      )
    end
  end

  context 'When a repository current is specified' do
    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.9', step_into: %w(chef_ingredient supermarket_server)) do |node|
        node.normal['supermarket_omnibus']['package_repo'] = 'current'
        node.normal['supermarket_omnibus']['chef_server_url']    = 'https://chefserver.mycorp.com'
        node.normal['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.normal['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_loblaw'
      end
      runner.converge(described_recipe)
    end

    before do
      artifact_info = instance_double('artifact info',
                                      url: 'https://packages.chef.io/current/el/6/supermarket-300.30.3-1.el6.x86_64.rpm',
                                      sha256: 'f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b')
      installer = instance_double('installer',
                                  artifact_info: artifact_info)
      allow_any_instance_of(Chef::Provider::ChefIngredient).to receive(:installer).and_return(installer)
      stub_command('grep Fauxhai /etc/hosts').and_return('33.33.33.11 Fauxhai')
    end

    it 'tells chef-ingredient to install the supermarket package from the current channel' do
      expect(chef_run).to upgrade_chef_ingredient('supermarket').with(channel: :current)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end

  context 'When a package_url is specified, packages.chef.io should not be used' do
    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.9', step_into: 'supermarket_server') do |node|
        node.normal['supermarket_omnibus']['package_url'] = 'https://somethingelse.chef.io/stable/el/6/supermarket-1.10.1~alpha.0-1.el5.x86_64.rpm'
        node.normal['supermarket_omnibus']['chef_server_url']    = 'https://chefserver.mycorp.com'
        node.normal['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.normal['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_loblaw'
      end
      runner.converge(described_recipe)
    end

    before do
      stub_command('grep Fauxhai /etc/hosts').and_return('33.33.33.11 Fauxhai')
    end

    it 'fetches the supermarket package and places it on the filesystem' do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/supermarket-1.10.1-alpha.0-1.el5.x86_64.rpm")
    end

    it 'uses the specified chef_ingredient[supermarket] with a package_source set' do
      expect(chef_run).to upgrade_chef_ingredient('supermarket')
        .with(package_source: ::File.join(Chef::Config[:file_cache_path], 'supermarket-1.10.1-alpha.0-1.el5.x86_64.rpm'))
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end

  context 'When a package_url is specified, the Rpm provider should be used on RHEL systems' do
    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.9', step_into: %w(chef_ingredient supermarket_server)) do |node|
        node.normal['supermarket_omnibus']['package_url'] = 'https://somethingelse.chef.io/chef/stable/packages/el/6/supermarket-1.10.1~alpha.0-1.el5.x86_64.rpm'
        node.normal['supermarket_omnibus']['chef_server_url']    = 'https://chefserver.mycorp.com'
        node.normal['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.normal['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_loblaw'
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
