require_relative 'spec_helper'

describe command('apt-get check') do
  its(:exit_status) { should eq 0 }
end

describe command('dpkg -C') do
  its(:exit_status) { should eq 0 }
end
