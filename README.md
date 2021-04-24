A Ruby script that runs through a checklist to test whether a ETH2 Linux staking node is set up correctly.

## Requirements

1. **Ruby** language. In case it is Ruby is not installed, try one of the 2 options:

* Via **rvm**, in case you want more flexible control over the Ruby version. Follow the instructios at https://rvm.io/. Then type `rvm install 3.0.1`

* Directly through the package manager: `sudo snap install ruby`

## Installation

1. Clone this repository.

2. In this repository type `bundle install` to install Ruby dependencies.

3. Type `rake create_config` to initialize configuration file.

4. The configuration file `config.yml` contains your local settings, such as names of data directories, user names, ports etc.
Edit this file if needed. By default it follows the conventions in [Somer Esat's staking guide](https://someresat.medium.com/guide-to-staking-on-ethereum-2-0-ubuntu-prysm-56f681646f74)


## Usage

**Rake** tasks are used to perform checks.

* `rake -T` will show all available tasks.

* `rake checklist:all` will go through the entire checklist and report the failed checks. Note: Some of the checks require sudo priviledges so you may need
to enter a password if you are not a superuser.
