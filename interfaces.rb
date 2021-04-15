require 'jsonrpc-client'
require 'faraday'

#
class Interface

  attr_accessor :connection, :endpoint

  def initialize(endpoint="http://localhost:8545")
    @endpoint = endpoint
    @connection = JSONRPC::Client.new(endpoint)
  end

  def req_status
    Faraday.get(endpoint)&.status rescue false
  end

end


class GethInterface < Interface

  def latest_block
    connection.eth_getBlockByNumber('latest', true)
  end

  def latest_block_number
    latest_block["number"].to_i(16)
  end

  def latest_block_timestamp
    latest_block["timestamp"].to_i(16)
  end

  def block_synchronized?
    return nil unless req_status
    tolerance = 180 # Maximum tolarated time between latest block timestamp and system time
    (Time.now.to_i - latest_block_timestamp).abs < tolerance
  end

end
