A Ruby script that runs an Ethereum Validator node through a **pre flight checklist**.  

## Requirements

1. **Ruby** language. In case it is Ruby is not installed, try one of the 2 options:

* Via **rvm**, in case you want more flexible control over the Ruby version. Follow the instructios at https://rvm.io/. Then type `rvm install 3.0.1`

* Directly through the package manager: `sudo snap install ruby`

2. Linux

3. An ETH1 node, and ETH2 Beacon and Validator nodes. Currently this checklist only works with **Geth** and **Prysm**. Support for other clients is planned.

## Installation

1. Clone this repository.

2. In this repository type `bundle install` to install Ruby dependencies.

3. Type `rake create_config` to initialize configuration file.

4. The configuration file `config.yml` contains your local settings, such as names of data directories, user names, ports etc.
Edit this file if needed. By default it follows the conventions in [Somer Esat's staking guide](https://someresat.medium.com/guide-to-staking-on-ethereum-2-0-ubuntu-prysm-56f681646f74)


## Usage

### Perform checks via **Rake** tasks

* `rake -T` will show all available tasks.

* `rake checklist:all` will go through the entire checklist and report the failed checks. Note: Some of the checks require sudo priviledges so you may need
to enter a password if you are not a superuser.

### Perform checks manually via Ruby console

* `./console` to start the console

* A `checklist` object will be loaded. 

* This object has various sub-obects that contain diagnostic methods. Examples: `checklist.clients.geth.version_check`, or `checklist.firewall.active?`

*Warning: Untested software. Recommended for use on a test server. Make sure it doesn't cause any problems before running on production server*
