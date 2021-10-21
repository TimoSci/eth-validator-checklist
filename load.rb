require 'pry'
require 'rubygems'
require 'bundler/setup'

require_relative 'src/checklist'
require_relative 'src/interfaces'
require_relative 'src/installers'
require_relative 'src/generators'
#
checklist = Eth2Checklist.new
installer = PrysmInstaller.new
generator = ServiceGenerator.new
#
binding.pry
