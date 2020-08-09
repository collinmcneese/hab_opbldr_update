# Test resource for performing a full origin sync, including all packages which have been promoted to the channel 'test'

builder_sync 'origin_sync' do
  source_builder 'https://bldr.habitat.sh'
  target_builder 'http://localhost'
  target_PAT '_AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=='
  tmp_dir '/tmp/hab_update_tmp'
  origin 'collinmcneese-test'
  channels %w(test)
end
