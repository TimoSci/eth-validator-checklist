require 'ethereum.rb'

client=Ethereum::HttpClient.new(Rails.configuration.geth_endpoint))
