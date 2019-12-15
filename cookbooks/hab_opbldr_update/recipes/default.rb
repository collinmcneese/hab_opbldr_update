#
# Cookbook:: hab_opbldr_update
# Recipe:: default
#
# Copyright:: 2019, Collin McNeese, All Rights Reserved.

# Only meant for systems that are running systemd
return unless ::File.exist?('/etc/systemd/system.conf')

# Read opbldr configuration settings from user.toml
tomlfile = '/hab/user/collinmcneese/hab_opbldr_update/config/user.toml'
usertoml = Tomlrb.load_file(tomlfile)

# Clone the public On-Prem Habitat Builder Git repository
#  Uses git from Habitat to not rely on system packages
directory '/var/chef/habitat' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Create one or more sync jobs.  Default job will be built from pre-packaged user.toml and additional may be created within file
usertoml['opbldr'].each do |jobname, jobdetails|
  # Create base seed.toml file used for job sync process
  template jobdetails['seedfile'] do
    source 'seed.toml.erb'
    owner 'root'
    group 'root'
    mode '0744'
    action :create_if_missing
  end

  # Build update shell script for systemd execution
  template "/var/chef/habitat/hab-bldr-update-pkgs-#{jobname}.sh" do
    source 'hab-bldr-update-pkgs.sh.erb'
    owner 'root'
    group 'root'
    mode '0700'
    variables(
      'jobdetails': jobdetails
    )
    action :create
  end

  # Build systemd unit for running Habitat builder update
  systemd_unit "hab-opbldr-update-#{jobname}.service" do
    content <<-EOU.gsub(/^\s+/, '')
    [Unit]
    Description=Run sync for Habitat On-Prem Builder packages from upstream Builder

    [Service]
    Type=simple
    ExecStart=/var/chef/habitat/hab-bldr-update-pkgs-#{jobname}.sh

    [Install]
    WantedBy=multi-user.target
    EOU
    action :create
  end

  # Build systemd timer to execute update on schedule
  systemd_unit "hab-opbldr-update-#{jobname}.timer" do
    content <<-EOU.gsub(/^\s+/, '')
    [Unit]
    Description=Timer for hab-opbldr-update-#{jobname}.service process.
    Requires=hab-opbldr-update-#{jobname}.service

    [Timer]
    OnCalendar=#{jobdetails['schedule']}

    [Install]
    WantedBy=timers.target
    EOU
    action [ :create, :enable, :start ]
  end
end # end jobbuild
