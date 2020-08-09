# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html
resource_name :builder_sync
provides :builder_sync

property :source_builder, String
property :source_PAT, String
property :target_builder, String
property :target_PAT, String
property :tmp_dir, String, required: true
property :origin, String, required: true
property :packages, Array
property :channels, Array, default: ['stable']
property :cleanup, String, default: 'disable'

action :sync do
  ruby_block 'get_package_list' do
    block do
      # Habitat must be installed and in PATH for cmd exec
      return unless hab_installed()
      node.run_state['package_list'] = []
      if new_resource.packages
        # Use the list of packages, if provided
        package_list = []
        new_resource.packages.each do |package|
          package_object = { 'origin' => "#{new_resource.origin}", 'name' => "#{package}" }
          package_list.push(package_object)
        end
      else
        # Get listing of all packages in origin
        get_packages = api_get_range("#{new_resource.source_builder}/v1/depot/pkgs/#{new_resource.origin}?distinct=true")
        package_list = (get_packages || [])
      end
      # Get listing of package versions which match based on chosen channels
      new_resource.channels.each do |channel|
        package_list.each do |package|
          channel_package = api_get("#{new_resource.source_builder}/v1/depot/channels/#{package['origin']}/#{channel}/pkgs/#{package['name']}")
          node.run_state['package_list'] += channel_package['data'] unless channel_package.nil?
        end
      end
    end
  end

  ruby_block 'get_package_details' do
    block do
      node.run_state['package_list_details'] = []
      node.run_state['package_list'].each do |package|
        # Get details for each package
        get_package_details = api_get("#{new_resource.source_builder}/v1/depot/pkgs/#{new_resource.origin}/#{package['name']}/#{package['version']}/#{package['release']}")
        details_object = {
          'origin' => get_package_details['ident']['origin'],
          'name' => get_package_details['ident']['name'],
          'version' => get_package_details['ident']['version'],
          'release' => get_package_details['ident']['release'],
          'target' => get_package_details['target'],
          'channels' => get_package_details['channels'].select { |ch| new_resource.channels.include?(ch) },
        }
        # Filter list for selected channels
        node.run_state['package_list_details'].push(details_object) unless details_object.nil?
      end
    end
    not_if { node.run_state['package_list'].empty? }
  end

  ruby_block 'get_sync_details' do
    block do
      tmp_dir = "#{new_resource.tmp_dir}/hab_opbldr_update"
      node.run_state['promote_array'] = []
      node.run_state['download_array'] = []
      node.run_state['package_list_details'].each do |package|
        package['channels'].each do |channel|
          # Check to see if package exists in the correct channel
          target_package_channel_check = api_get("#{new_resource.target_builder}/v1/depot/channels/#{package['origin']}/#{channel}/pkgs/#{package['name']}/#{package['version']}/#{package['release']}")
          if target_package_channel_check
            # p "exists and in correct channel - nothing to do #{package['origin']}/#{package['name']}/#{package['version']}/#{package['release']} -- #{channel}"
          else
            # Queue command to promote to correct channel
            node.run_state['promote_array'].push("hab pkg promote -u #{new_resource.target_builder} -z #{new_resource.target_PAT} #{package['origin']}/#{package['name']}/#{package['version']}/#{package['release']} #{channel} #{package['target']}")
            # Check to see if package exists on target builder
            target_package_version_check = api_get("#{new_resource.target_builder}/v1/depot/pkgs/#{package['origin']}/#{package['name']}/#{package['version']}/#{package['release']}")
            if target_package_version_check
              # pkg exists on target builder
            else
              FileUtils.mkdir_p(tmp_dir.to_s) unless Dir.exist?(tmp_dir.to_s)
              source_auth = if new_resource.source_PAT
                              "-z #{new_resource.source_PAT}"
                            else
                              ''
                            end
              node.run_state['download_array'].push("hab pkg download -u #{new_resource.source_builder} #{source_auth} -c #{channel} --target #{package['target']} --download-directory #{tmp_dir} #{package['origin']}/#{package['name']}/#{package['version']}/#{package['release']}")
            end
          end
        end
      end
    end
    not_if { node.run_state['package_list_details'].empty? }
  end

  ruby_block 'run_downloads' do
    block do
      node.run_state['download_array'].each do |download|
        `#{download}`
      end
    end
    not_if { node.run_state['download_array'].empty? }
  end

  ruby_block 'bulk_upload' do
    block do
      `hab pkg bulkupload --auto-create-origins -u #{new_resource.target_builder} -z #{new_resource.target_PAT} #{new_resource.tmp_dir}/hab_opbldr_update`
    end
    not_if { node.run_state['download_array'].empty? }
  end

  ruby_block 'run_promotions' do
    block do
      node.run_state['promote_array'].each do |promotion|
        `#{promotion}`
      end
    end
    not_if { node.run_state['promote_array'].empty? }
  end

  ruby_block 'cleanup' do
    block do
      `rm -fr #{new_resource.tmp_dir}/hab_opbldr_update/*`
    end
    only_if { new_resource.cleanup == 'enable' }
  end
end

# Custom Methods used by this resource
action_class do
  include HabOpbldrUpdate::BuilderSyncHelpers
end
