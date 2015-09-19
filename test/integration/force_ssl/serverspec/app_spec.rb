require_relative 'spec_helper'

describe 'supermarket' do
  it 'redirect to https' do
    cmd = command 'curl http://localhost 2> /dev/null'
    expect(cmd.stdout).to match '301 Moved Permanently'
  end

  it 'serve Chef Supermarket index web page on port 443' do
    cmd = command 'curl http://localhost:443 2> /dev/null'
    expect(cmd.stdout).to match '<!DOCTYPE html>'
  end

  it 'serve Chef Supermarket index web page over http to http-only.example.com' do
    cmd = command 'curl --header "Host: http-only.example.com" http://localhost 2> /dev/null'
    expect(cmd.stdout).to match '<!DOCTYPE html>'
  end
end
