require_relative 'spec_helper'

if os[:family] == 'ubuntu'
  describe command('apt-get check') do
    its(:exit_status) { should eq 0 }
  end

  describe command('dpkg -C') do
    its(:exit_status) { should eq 0 }
  end
end
