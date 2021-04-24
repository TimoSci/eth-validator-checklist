require 'pry'
require 'rubygems'
require 'bundler/setup'

require_relative 'checklist'
require_relative 'interfaces'
#
checklist = Eth2Checklist.new
#
binding.pry
