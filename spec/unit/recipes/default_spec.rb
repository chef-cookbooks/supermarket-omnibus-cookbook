#
# Cookbook Name:: supermarket-omnibus-cookbook
# Spec:: default
#
# Copyright (c) 2015 Irving Popovetsky, All Rights Reserved.

require 'spec_helper'

describe 'supermarket-omnibus-cookbook::default' do

  context 'When all attributes are default, it should fail because of nil checks' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it 'raises an error' do
      expect { chef_run }.to raise_error(RuntimeError)
    end

  end

  context 'When chef_server (oc-id) attributes are correctly specified' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new do |node|
        node.set['supermarket_omnibus']['chef_server_url'] = 'https://chefserver.mycorp.com'
        node.set['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.set['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_lawblaw'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end

  context 'When a chef_server_ingredient repository chef/current is specified' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(step_into: 'chef_server_ingredient') do |node|
        node.set['supermarket_package']['packagecloud_repo']  = 'chef/current'
        node.set['supermarket_omnibus']['chef_server_url']    = 'https://chefserver.mycorp.com'
        node.set['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.set['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_loblaw'
      end
      runner.converge(described_recipe)
    end

    it 'uses the specified chef_server_ingredient[supermarket] with a repository of "chef/current"' do
      expect(chef_run).to install_chef_server_ingredient('supermarket')
        .with(repository: 'chef/current')
    end

    it 'creates a packagecloud_repository named "chef/current"' do
      expect(chef_run).to create_packagecloud_repo('chef/current')
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end


  context 'When a package_source is specified, packagecloud should not be used' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new do |node|
        node.set['supermarket_package']['package_source']  = 'http://bit.ly/98K8eH'
        node.set['supermarket_omnibus']['chef_server_url']    = 'https://chefserver.mycorp.com'
        node.set['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.set['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_loblaw'
      end
      runner.converge(described_recipe)
    end

    it 'uses the specified chef_server_ingredient[supermarket] with a package_source set' do
      expect(chef_run).to install_chef_server_ingredient('supermarket')
        .with(package_source: 'http://bit.ly/98K8eH')
    end

    it 'does not create a packagecloud_repository named "chef/stable"' do
      expect(chef_run).to_not create_packagecloud_repo('chef/stable')
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end
end
