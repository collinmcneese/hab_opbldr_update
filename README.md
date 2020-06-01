# Habitat On-Prem Builder Update (hab_opbldr_update)

Chef Effortless package which provides scheduling mechanism to run regular updates of an On-Prem Habitat Builder.  This is a reference repo and should be modified for actual usage with either [direct cookbook update](#direct-cookbook-update) or [toml method](#toml-method)

## Pre-Requisites

* Local Habitat On-Prem Builder server instance(s) already running and configured - <https://github.com/habitat-sh/on-prem-builder>
* Requires Internet connectivity to pull updates from public Habitat Builder, <https://bldr.habitat.sh>
* Personal Access Token for source Habitat Builder instance to download packages.
* Personal Access Token for target Habitat Builder, allowing to upload new versions of packages which are downloaded from source Habitat Builder.

## Process

Overview of the steps in the `builder_sync` process:

* Define Packages or entire origin to sync (specifying channels)
* Run api calls to gather info about the packages as they exist in the source Builder
* Check the target Builder to see if packages exist, mark for download from source if not
* Check the target Builder to see if packages exist in the correct channel, mark for promote if not
* Run download for all packages that need to be sent to target
* Run bulk upload
* Run promotions to get target state in sync with source for channel status (for channels we identified that we care about in the first step)

## Usage

This reference repository contains both the Chef Habitat package and cookbook, following the Effortless pattern (<https://www.chef.io/products/effortless-infrastructure/>). 

* Sync packages on an On-Prem Habitat Builder installation with public Habitat Builder:
  
    ```text
    +-------------------+             +-------------------+
    |                   |             |                   |
    |  Chef Habitat     |------------>|  Chef Habitat     |
    |  Builder Public   |             |  Builder On-Prem  |
    |                   |             |                   |
    +-------------------+             +-------------------+
    ```

* Maintain package sync between multiple On-Prem Habitat Builder instances, with a leader -> follower deployment.

    ```text
                                                                    +-------------------+
                                                                    |                   |
                                                                  / |  Chef Habitat     |
                                                                /-  |  Builder On-Prem  |
    +-------------------+             +-------------------+    /-   |  Follower         |
    |                   |             |                   |  /-     +-------------------+
    |  Chef Habitat     |------------>| Chef Habitat      | -
    |  Builder Public   |             | Builder On-Prem   |  \-
    |                   |             | Leader            |    \-   +-------------------+
    +-------------------+             +-------------------+      \- |                   |
                                                                  \ |  Chef Habitat     |
                                                                    |  Builder On-Prem  |
                                                                    |  Follower         |
                                                                    +-------------------+
    ```

### Direct Cookbook Update
Update the included cookbook, `cookbooks/hab_opbldr_update`, to directly configure resources which will perform sync actions:

```ruby
# Sample configuration to sync an entire origin with specified channels
builder_sync 'origin_sync' do
  source_builder ENV['SOURCE_BLDR']
  source_PAT ENV['SOURCE_PAT']
  target_builder ENV['TARGET_BLDR']
  target_PAT ENV['TARGET_PAT']
  tmp_dir '/tmp/hab_update_tmp'
  origin 'originname'
  channels %w(stable unstable test)
end

# Sample configuration to sync specific packages from an origin with all channels
builder_sync 'sync_specific_packages' do
  source_builder ENV['SOURCE_BLDR']
  source_PAT ENV['SOURCE_PAT']
  target_builder ENV['TARGET_BLDR']
  target_PAT ENV['TARGET_PAT']
  tmp_dir '/tmp/hab_update_tmp'
  origin 'chef'
  packages %w(inspec chef-infra-client scaffolding-chef-infra scaffolding-chef-inspec)
end
```

### TOML method

Instead of directly configuring cookbook resources, configuration may be added via TOML which will be parsed and loaded by the cookbook at runtime.  Install hook will create `user.toml` if not present.

```toml
[opbldr.default]
source_builder = "https://bldr.habitat.sh"
source_PAT = "sourcebuilderPAT"
target_builder = "https://on-prem-builder.localdomain"
target_PAT = "targetbuilderPAT"
tmp_dir = "/tmp/builder_sync"
origin = "originname"
channels = ['stable']
packages = ['optional_package_name']
cleanup = "disable"
```

### user.toml - Chef License

Contains configuration tuning options for Chef Infra client.  License acceptance must be updated or set via environment variable `HAB_LICENSE`.

```bash
# You must accept the Chef License to use this software: https://www.chef.io/end-user-license-agreement/
# Change [chef_license] from acceptance = "undefined" to acceptance = "accept-no-persist" if you agree to the license.

[chef_license]
acceptance = "undefined"

```
