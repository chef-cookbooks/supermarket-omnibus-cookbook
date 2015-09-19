require_relative 'spec_helper'

describe 'postgres' do
  it 'running' do
    expect(process 'postgres').to be_running
  end

  it 'listen tcp socket' do
    expect(port 15_432).to be_listening
  end

  it 'has supermarket user' do
    cmd = command 'echo "\dg" | sudo -u supermarket /opt/supermarket/embedded/bin/psql -h 127.0.0.1 -p 15432'
    expect(cmd.stdout).to match 'supermarket'
  end

  it 'has supermarket db' do
    cmd = command 'echo "\l" | sudo -u supermarket /opt/supermarket/embedded/bin/psql -h 127.0.0.1 -p 15432'
    expect(cmd.stdout).to match 'supermarket'
  end
end
