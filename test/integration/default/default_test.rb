# InSpec test for recipe hab_opbldr_update::default

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

control 'cookbook validations' do
  impact 0.1
  title 'Validate cookbook base components implemented successfully'
  describe directory('/var/chef/habitat') do
    it { should exist }
  end
  describe file('/var/chef/habitat/hab-bldr-update-pkgs.sh') do
    it { should exist }
  end
end

control 'systemd unit checks' do
  impact 0.1
  title 'Check for creation of systemd units.'
  # http://inspec.io/docs/reference/resources/systemd_service/
  describe systemd_service('hab-opbldr-update.service') do
    it { should be_installed }
  end
  describe systemd_service('hab-opbldr-update.timer') do
    it { should be_installed }
    it { should be_enabled }
  end
end
