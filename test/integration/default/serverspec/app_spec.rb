require_relative 'spec_helper'

describe 'supermarket' do
  it 'create a unicorn socket' do
    expect(file '/tmp/.supermarket.sock.0').to be_socket
  end

  it 'serve Chef Supermarket index web page' do
    cmd = command 'wget -O - http://localhost 2> /dev/null'
    expect(cmd.stdout).to match '<!DOCTYPE html>'
  end

  it 'still serves Chef Supermarket when Unicorn is restarted' do
    restart = command 'sv 2 unicorn'
    cmd = command 'wget -O - http://localhost 2> /dev/null'
    expect(cmd.stdout).to match '<!DOCTYPE html>'
  end

  it 'has > 0 ICLAs' do
    cmd = command %Q{echo 'SELECT count("iclas".*) FROM "iclas";' | sudo -u postgres psql supermarket_production | grep '^(. row.*)'}
    cmd.stdout.match(/\((\d).*/)
    res = $1.to_i
    expect(res).to be > 0
  end

  it 'has > 0 CCLAs' do
    cmd = command %Q{echo 'SELECT count("cclas".*) FROM "cclas";' | sudo -u postgres psql supermarket_production | grep '^(. row.*)'}
    cmd.stdout.match(/\((\d).*/)
    res = $1.to_i
    expect(res).to be > 0
  end

  describe file('/srv/supermarket/current/.env') do
    it { should be_linked_to '/srv/supermarket/shared/.env.production' }
  end

  describe file('/srv/supermarket/current/config/unicorn/production.rb') do
    it { should be_linked_to '/srv/supermarket/shared/unicorn.rb' }
  end

  it 'writes feature flags to .env.production from the apps databag' do
    cmd = command 'cat /srv/supermarket/shared/.env.production'
    expect(cmd.stdout).to match 'FEATURES=tools,join_ccla'
  end
end
