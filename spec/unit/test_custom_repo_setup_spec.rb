#
# Cookbook:: supermarket-omnibus-cookbook
# Spec:: custom_repo_setup
#
# Copyright:: 2016-2017, Yvonne Lam, All Rights Reserved.

describe 'test::custom_repo_setup' do
  context 'When a custom recipe is specified, the custom recipe should be used' do
    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.9', step_into: %w(chef_ingredient supermarket_server)) do |node|
        node.normal['supermarket_omnibus']['chef_server_url'] = 'https://chefserver.mycorp.com'
        node.normal['supermarket_omnibus']['chef_oauth2_app_id'] = 'blahblah'
        node.normal['supermarket_omnibus']['chef_oauth2_secret'] = 'bob_lawblaw'
      end
      runner.converge(described_recipe)
    end

    before do
      stub_command('grep Fauxhai /etc/hosts').and_return('33.33.33.11 Fauxhai')
    end

    it 'includes the custom_repo_setup_recipe' do
      expect(chef_run).to include_recipe 'custom_repo::custom_repo_recipe'
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end
end
