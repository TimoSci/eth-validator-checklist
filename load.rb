require 'pry'
require 'rubygems'
require 'bundler/setup'
require 'json'

require_relative 'src/checklist'
require_relative 'src/interfaces'
require_relative 'src/installers'
require_relative 'src/generators'
require_relative 'src/report'
#
checklist = Eth2Checklist.new
installer = EasyPrysmInstaller.new(checklist)
generator = ServiceGenerator.new
metrics = ValidatorMetricsInterface.new
report = Report.new
#


binding.pry
