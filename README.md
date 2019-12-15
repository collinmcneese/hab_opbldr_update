# Habitat On-Prem Builder Update (hab_opbldr_update)

Chef Effortless package which provides scheduling mechanism to run regular updates of an On-Prem Habitat Builder.

## Pre-Requisites

* Local Habitat On-Prem Builder server instance already running and configured - <https://github.com/habitat-sh/on-prem-builder>
* Habitat v0.90.10+ (To leverage seed-file toml structure introduced in `0.90.10`)
* Linux OS utilizing systemd for creation of systemd units to execute update scripts.
* Requires Internet connectivity to pull updates from public Habitat Builder, <https://bldr.habitat.sh>
* Personal Access Token for source Habitat Builder instance, to download packages.
* Personal Access Token for target Habitat Builder, allowing to upload new versions of packages which are downloaded from source Habitat Builder.

## Usage

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

This repository contains both the Chef Habitat package and cookbook, following the Effortless (<https://www.chef.io/products/effortless-infrastructure/>) deployment pattern.  Installing and running the package generated by this repository will setup and configure a process by which an On-Prem Habitat Builder instance may be updated.

### user.toml

After package installation, the file `/hab/user/<origin>/hab_opbldr_update/user.toml` must be updated to indicate licence acceptance and for configuration of items under `[opbldr]` section:

```bash
# You must accept the Chef License to use this software: https://www.chef.io/end-user-license-agreement/
# Change [chef_license] from acceptance = "undefined" to acceptance = "accept-no-persist" if you agree to the license.

[chef_license]
acceptance = "undefined"

#######################################
# Habitat On-Prem Builder Update settings
#######################################

[opbldr]
# Path to local filesystem location where git repo is stored - https://github.com/habitat-sh/on-prem-builder
#  ex: gitrepopath = "/var/habitat/on-prem-builder"
gitrepopath = '/var/chef/habitat/on-prem-builder'

# Source Builder PAT
srcbldrpat = 'changeme'

# Target Builder PAT
tgtbldrpat = 'changeme'

# URL of Upstream builder which is the source for packages being synced.
#  Default is 'https://bldr.habitat.sh' to pull from public Chef Habitat Builder, change to an internal URL to sync an internal replica.
srcbldrurl = 'https://bldr.habitat.sh'

# URL of on-prem Habitat Builder
tgtbldrurl = 'http://localhost'

# Seed file to use for sync process
#  Available seed files are located at #{gitrepopath}/package_seed_lists
seedfile = '/var/chef/habitat/seed.toml'

# Filesystem location to use for temporary download of packages when updating
#  defaults to /tmp/hab_opbldr_update_tmp
tmppath = '/tmp/hab_opbldr_update_tmp'

# Sync schedule for updates, defaults to run weekly on Sunday at 04:00 local system time
#  See for time syntax details - https://www.freedesktop.org/software/systemd/man/systemd.time.html#
#  Additional Examples:
#     minutely → *-*-* *:*:00
#       hourly → *-*-* *:00:00
#        daily → *-*-* 00:00:00
#      monthly → *-*-01 00:00:00
#       weekly → Mon *-*-* 00:00:00
#       yearly → *-01-01 00:00:00
#    quarterly → *-01,04,07,10-01 00:00:00
# semiannually → *-01,07-01 00:00:00
schedule = 'Sun *-*-* 04:00:00'

#######################################
# End Habitat On-Prem Builder Update settings
#######################################

```

### seed.toml

The file `seed.toml` is created by the `hab_opbldr_update` cookbook included in this package and is used as the source for what packages need to be synchronized from the source (public or internal) Habitat Builder instance to the local Habitat Builder instance.  File is initially created at location `/var/chef/habitat/seed.toml` and should be updated in place to reflect which packages should be included in the automatic sync process.

```toml
# seed.toml
format_version = 1

# This file is a template for what should be used by the `hab_opbldr_update` process for determining which repositories to sync.
# Changes to this file will not be overwritten by Chef processes so this file can be edited directly in place.

# Structure:
# [[platform]]
# channel = "channelname"
# package = ["packages", "to", "sync"]
# ## OR ##
# [[platform]]
# channel = "channelname"
# package = [
#   "packages",
#   "to",
#   "sync"
# ]

# Example Sync Configuration:

# [[x86_64-linux]]
# channel = "stable"
# packages = ["core/gzip", "core/grep/3.1", "core/redis/4.0.14/20190319155852"]

# [[x86_64-linux]]
# channel = "unstable"
# packages = ["chef/chef-client", "chef/inspec/4.18.30/20191107165916"]

# [[x86_64-windows]]
# channel = "stable"
# packages = ["effortless/audit-baseline"]
```
