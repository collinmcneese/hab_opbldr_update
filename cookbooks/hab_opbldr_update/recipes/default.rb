#
# Cookbook:: hab_opbldr_update
# Recipe:: default
#
# Copyright:: 2019, Collin McNeese, All Rights Reserved.

# Only meant for systems that are running systemd
return unless ::File.exist?('/etc/systemd/system.conf')

# Read opbldr configuration settings from user.toml
tomlfile = '/hab/user/collinmcneese/hab_opbldr_update/user.toml'
usertoml = Tomlrb.load_file(tomlfile)

# Clone the public On-Prem Habitat Builder Git repository
directory '/var/chef/habitat' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Uses git from Habitat to not rely on system packages
execute 'clone on-prem-builder' do
  command 'hab pkg exec core/git git clone https://github.com/habitat-sh/on-prem-builder.git /var/chef/habitat/on-prem-builder'
  not_if { ::Dir.exist?('/var/chef/habitat/on-prem-builder') }
  action :run
end

# Create base seed.toml file used for sync process
template '/var/chef/habitat/seed.toml' do
  source 'seed.toml.erb'
  owner 'root'
  group 'root'
  mode '0744'
  action :create_if_missing
end

# Build update shell script for systemd execution
template '/var/chef/habitat/hab-bldr-update-pkgs.sh' do
  source 'hab-bldr-update-pkgs.sh.erb'
  owner 'root'
  group 'root'
  mode '0700'
  variables(
    'usertoml': usertoml
  )
  action :create
end

# Build systemd unit for running Habitat builder update
systemd_unit 'hab-opbldr-update.service' do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=Run sync for Habitat On-Prem Builder packages from Public Builder

  [Service]
  Type=simple
  ExecStart=/var/chef/habitat/hab-bldr-update-pkgs.sh

  [Install]
  WantedBy=multi-user.target
  EOU
  action :create
end

# Build systemd timer to execute update on schedule
systemd_unit 'hab-opbldr-update.timer' do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=Timer for hab-opbldr-update.service process.
  Requires=hab-opbldr-update.service

  [Timer]
  OnCalendar=#{usertoml['opbldr']['schedule']}

  [Install]
  WantedBy=timers.target
  EOU
  action [ :create, :enable, :start ]
end
