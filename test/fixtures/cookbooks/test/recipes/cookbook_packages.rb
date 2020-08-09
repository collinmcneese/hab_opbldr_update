builder_sync 'chef_repo' do
  source_builder 'https://bldr.habitat.sh'
  target_builder 'http://localhost'
  target_PAT '_AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=='
  tmp_dir '/tmp/hab_update_tmp'
  origin 'collinmcneese-test'
  packages %w(jq-static sqlite sshpass)
end