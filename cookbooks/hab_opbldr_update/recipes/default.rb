#
# Cookbook:: hab_opbldr_update
# Recipe:: default
#
# Copyright:: 2020, Collin McNeese, All Rights Reserved.

# Option 1: Load jobs from TOML configuration
# tomlfile = '/hab/user/hab_opbldr_update/config/user.toml'
# usertoml = Tomlrb.load_file(tomlfile)

# Create one or more sync jobs.  Default job will be built from pre-packaged user.toml.
# Additional jobs may be created within file.
# usertoml['opbldr'].each do |jobname, jobdetails|
#   builder_sync jobname.to_s do
#     source_builder jobdetails['source_builder']
#     source_PAT jobdetails['source_PAT']
#     target_builder jobdetails['target_builder']
#     target_PAT jobdetails['target_PAT']
#     tmp_dir jobdetails['tmp_dir']
#     origin jobdetails['origin']
#     channels jobdetails['channels']
#     packages jobdetails['packages']
#     cleanup jobdetails['cleanup']
#   end
# end

# Option 2: Create resources directly within this cookbook or in wrapper.
# Sample configuration to sync an entire origin with specified channels
# builder_sync 'origin_sync' do
#   source_builder ENV['SOURCE_BLDR']
#   source_PAT ENV['SOURCE_PAT']
#   target_builder ENV['TARGET_BLDR']
#   target_PAT ENV['TARGET_PAT']
#   tmp_dir '/tmp/hab_update_tmp'
#   origin 'originname'
#   channels %w(stable unstable test)
# end

# Sample configuration to sync specific packages from an origin with all stable channel
# builder_sync 'chef_repo' do
#   source_builder ENV['SOURCE_BLDR']
#   source_PAT ENV['SOURCE_PAT']
#   target_builder ENV['TARGET_BLDR']
#   target_PAT ENV['TARGET_PAT']
#   tmp_dir '/tmp/hab_update_tmp'
#   origin 'chef'
#   packages %w(inspec chef-infra-client scaffolding-chef-infra scaffolding-chef-inspec)
# end
