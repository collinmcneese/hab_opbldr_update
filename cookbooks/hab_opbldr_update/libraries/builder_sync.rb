#
# Chef Documentation
# https://docs.chef.io/libraries.html
#

module HabOpbldrUpdate
  module BuilderSyncHelpers
    def hab_installed
      `hab -V`
    rescue
      raise 'Habitat is not installed or is not in PATH'
    end

    def pwsh_exec(arg)
      `hab pkg exec core/powershell pwsh -c '& {#{arg}}'`
    rescue
      nil
    end

    def api_get(url)
      uri = URI(url)
      reply = JSON.parse(Net::HTTP.get(uri))
      reply
    rescue
      nil
    end

    def api_get_range(url)
      data_array = []
      uri = URI(url)
      reply = api_get(uri)
      # Builder API returns ranges of 50
      if reply['total_count'].to_i > 49
        range = reply['range_start'].to_i
        until range == reply['total_count'].to_i
          uri_range = URI(url)
          # append range to existing uri parameters (if any)
          uri_range.query += "&range=#{range}"
          rangereply = api_get(uri_range)
          data_array += rangereply['data']
          range += 50
          if range > reply['total_count'].to_i
            range = reply['total_count'].to_i
          end
        end
      else
        # If total_count is <= 49, just push the original reply data
        data_array += reply['data']
      end
      data_array
    rescue
      nil
    end
  end
end
