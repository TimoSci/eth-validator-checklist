require 'jsonrpc-client'
require 'faraday'
#
# Class for wrapping actions associated with an http interface of a client
#
#
class Interface

  attr_accessor :connection, :endpoint

  def initialize(endpoint)
    @endpoint = endpoint
    @connection = JSONRPC::Client.new(endpoint)
  end

  attr_accessor :node

  def req_status
    Faraday.get(endpoint)&.status rescue false
  end

end


class GethInterface < Interface

  def initialize(endpoint="http://localhost:8545")
    super(endpoint)
  end

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

  def synchronized?
    return nil unless req_status
    !connection.eth_syncing
  end

  def peercount
    connection.net_peerCount.to_i(16)
  end

  def min_peercount?
    return nil unless req_status
    peercount > node.checklist.config[:geth][:minpeercount]
  end

end
