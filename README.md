A Ruby script that runs an Ethereum Validator node through a **pre flight checklist**.  

## Requirements

1. Linux - Ubuntu or Debian OS Family

2. **Ruby** language. In case Ruby is not installed, try one of the 2 options:

  * Via **rvm**, in case you want more flexible control over the Ruby version. Follow the instructios at https://rvm.io/. Then type `rvm install 3.0.1`

  * Directly through the package manager: `sudo snap install ruby`

3. An ETH1 client, and ETH2 Beacon and Validator clients. Currently this checklist only works with **Geth** and **Prysm**. Support for other clients is planned.

## Installation

1. Clone this repository.

2. In this repository type `bundle install` to install Ruby dependencies.

3. Type `bin/ethcheck create_config` to initialize configuration file for main net or `bin/ethcheck create_config_testnet` for testnet.

4. The configuration file `config.yml` contains your local settings, such as names of data directories, user names, ports etc.
Edit this file if needed. By default it follows the conventions in [Somer Esat's staking guide](https://someresat.medium.com/guide-to-staking-on-ethereum-2-0-ubuntu-prysm-56f681646f74).


## Usage

### CLI Commands

Run `bin/ethcheck help` to see all available commands.

#### Checklist

* `bin/ethcheck checklist` — run all checks and print a report
* `bin/ethcheck checklist users` — check existence of configured users
* `bin/ethcheck checklist system_checks` — check system packages and reboot status
* `bin/ethcheck checklist timekeeping` — check NTP and time synchronization
* `bin/ethcheck checklist firewall` — check UFW firewall status and rules
* `bin/ethcheck checklist clients` — check all client services, versions, and sync status

Note: Some checks require sudo privileges so you may need to enter a password if you are not a superuser.

#### Generate Service Files

* `bin/ethcheck generate services` — generate all `.service` files and copy to system directory
* `bin/ethcheck generate service NAME` — generate a single service file (e.g. `geth`, `prysmbeacon`)

#### Install / Uninstall Clients

* `bin/ethcheck install prysm beacon` — install prysmbeacon client
* `bin/ethcheck install prysm validator` — install prysmvalidator client
* `bin/ethcheck install geth` — install and set up geth
* `bin/ethcheck uninstall prysm beacon` — uninstall prysmbeacon client
* `bin/ethcheck uninstall prysm validator` — uninstall prysmvalidator client
* `bin/ethcheck uninstall geth` — uninstall geth

#### Update Clients

* `bin/ethcheck update prysm beacon` — update beacon client to latest version
* `bin/ethcheck update prysm validator` — update validator client to latest version
* `bin/ethcheck update prysm beacon --static` — update using static version from `config.yml`
* `bin/ethcheck update prysm validator --static` — update using static version from `config.yml`

### Perform checks manually via Ruby console

* `./console` to start the console.

* A `checklist` object will be loaded. 

* This object has various sub-objects that contain diagnostic methods. Examples: `checklist.clients.geth.version_check`, or `checklist.firewall.active?`

## Credits

[Somer Esat's Staking Guides](https://github.com/SomerEsat/ethereum-staking-guide)


***Warning: Alpha software that has not been fully tested. Recommended for use on a QA or Test server only. Make sure you fully understand this software before running on production server where real ETH is at stake***.
