ENV['SOURCE_BLDR'] = 'https://bldr.habitat.sh'
ENV['TARGET_BLDR'] = 'http://localhost'
ENV['TARGET_PAT'] = 'test123'

builder_sync 'chef_repo' do
  source_builder ENV['SOURCE_BLDR']
  target_builder ENV['TARGET_BLDR']
  target_PAT ENV['TARGET_PAT']
  tmp_dir '/tmp/hab_update_tmp'
  origin 'collinmcneese-test'
  packages %w(jq-static sqlite sshpass)
end