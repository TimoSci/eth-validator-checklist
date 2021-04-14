require 'pry'
require 'rubygems'
require 'bundler/setup'
require_relative 'checklist.rb'
require 'ethereum.rb'

checklist = Eth2Checklist.new

binding.pry
