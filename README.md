# Habitat On-Prem Builder Update (hab_opbldr_update)

Chef Effortless package which provides scheduling mechanism to run regular updates of an On-Prem Habitat Builder.

## Pre-Requisites

* Local Habitat On-Prem Builder server instance already running and configured - <https://github.com/habitat-sh/on-prem-builder>
* Habitat v0.90.10+
* Linux OS utilizing systemd for creation of systemd units to execute update scripts.
* Requires Internet connectivity to pull updates from public Habitat Builder, <https://bldr.habitat.sh>
* Personal Access Token for public Habitat Builder, <https://bldr.habitat.sh/>, to download packages.
* Personal Access Token for On-Prem Habitat Builder, allowing to upload new versions of packages which are downloaded from public Habitat Builder.

## Usage
