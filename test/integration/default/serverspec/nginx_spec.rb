require 'net/http'
require_relative 'spec_helper'

describe 'nginx' do
  it 'running' do
    expect(process('nginx')).to be_running
  end

  it 'listen on port 80' do
    expect(port(80)).to be_listening
    expect(port(443)).to be_listening
  end

  # it 'serves sitemaps' do
  #   ok_response = Net::HTTP.get_response(URI('http://localhost/sitemap.xml.gz'))

  #   expect(ok_response.code.to_i).to eql(200)

  #   bad_response = Net::HTTP.get_response(URI('http://localhost/sitemap1.xml.gz'))

  #   expect(bad_response.code.to_i).to eql(404)
  #   expect(bad_response.body).to include('nginx')
  # end

  # it 'default site is supermarket' do
  #   config = '/etc/nginx/sites-available/default'
  #   expect(file '/etc/nginx/sites-enabled/default').to be_linked_to config
  #   expect(file(config).content).to match 'upstream unicorn'
  # end
end
