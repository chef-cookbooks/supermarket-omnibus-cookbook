require_relative 'spec_helper'

describe 'ruby' do
  it '2.1.3 installed and used by default' do
    cmd = command 'ruby -v'
    expect(cmd.stdout).to match 'ruby 2.1.3'
  end
end
