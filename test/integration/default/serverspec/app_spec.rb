require_relative 'spec_helper'

# rubocop:disable Performance/RedundantMatch

describe 'supermarket' do
  it 'create a unicorn socket' do
    expect(port(13_000)).to be_listening
  end

  it 'serve Chef Supermarket index web page' do
    cmd = command 'wget --no-check-certificate -O - https://localhost 2> /dev/null'
    expect(cmd.stdout).to match '<!DOCTYPE html>'
  end

  it 'still serves Chef Supermarket when Unicorn is restarted' do
    restart = command 'supermarket-ctl restart rails; sleep 5' # rubocop: disable Lint/UselessAssignment
    cmd = command 'wget --no-check-certificate -O - https://localhost 2> /dev/null'
    expect(cmd.stdout).to match '<!DOCTYPE html>'
  end

  it 'has > 0 ICLAs' do
    cmd = command %{echo 'SELECT count("iclas".*) FROM "iclas";' | sudo -u supermarket /opt/supermarket/embedded/bin/psql -h 127.0.0.1 -p 15432 supermarket | grep '^(. row.*)'}
    cmd.stdout.match(/\((\d).*/)
    res = Regexp.last_match(1).to_i
    expect(res).to be > 0
  end

  it 'has > 0 CCLAs' do
    cmd = command %{echo 'SELECT count("cclas".*) FROM "cclas";' | sudo -u supermarket /opt/supermarket/embedded/bin/psql -h 127.0.0.1 -p 15432 supermarket | grep '^(. row.*)'}
    cmd.stdout.match(/\((\d).*/)
    res = Regexp.last_match(1).to_i
    expect(res).to be > 0
  end

  describe file('/var/opt/supermarket/etc/env') do
    it { should be_file }
    it { should contain 'CHEF_SERVER_URL=' }
    it { should contain 'INSTALL_DIRECTORY="/opt/supermarket"' }
    it { should contain 'APP_DIRECTORY="/opt/supermarket/embedded/service/supermarket"' }
    it { should contain 'LOG_DIRECTORY="/var/log/supermarket"' }
    it { should contain 'VAR_DIRECTORY="/var/opt/supermarket"' }
    it { should contain 'USER="supermarket"' }
    it { should contain 'FEATURES="tools, gravatar"' }
  end

  describe file('/var/opt/supermarket/etc/unicorn.rb') do
    it { should be_file }
    it { should contain 'listen "127.0.0.1:13000"' }
    it { should contain "pid '/var/opt/supermarket/rails/run/unicorn.pid'" }
  end
end
