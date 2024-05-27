require 'pry'
require 'rubygems'
require 'bundler/setup'
require 'json'

require_relative 'src/checklist'
require_relative 'src/interfaces'
require_relative 'src/installers'
require_relative 'src/generators'
require_relative 'src/report'
require_relative 'src/abstract_classes'
#
o = Eth2Object.new
endpoint = o.config[:prysmbeacon][:http_endpoint]
puts endpoint
#

checklist = Eth2Checklist.new
installer = EasyPrysmInstaller.new(checklist)
generator = ServiceGenerator.new
metrics = ValidatorMetricsInterface.new
prysminterface = PrysmBeaconInterface.new(endpoint)
beaconstats = BeaconStatsInterface.new(endpoint)
gethinterface = GethInterface.new(o.config[:geth][:http_endpoint])
report = Report.new
#


binding.pry
