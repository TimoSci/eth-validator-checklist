require 'pry'
require 'rubygems'
require 'bundler/setup'

require_relative 'src/checklist'
require_relative 'src/interfaces'
#
checklist = Eth2Checklist.new
#
binding.pry
