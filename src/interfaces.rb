require 'jsonrpc-client'
require 'faraday'
require 'json'
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

  @@default_endpoint =   "http://localhost:8545"
  def self.default_endpoint
      @@default_endpoint
  end

  def initialize(endpoint=@@default_endpoint)
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


class PrysmBeaconInterface < Interface

  # See https://github.com/prysmaticlabs/prysm/blob/develop/proto/prysm/v1alpha1/node.proto for API schema

  @@default_endpoint =   "http://localhost:3500"
  @@api_path = "/eth/v1alpha1"

  def self.default_endpoint
      @@default_endpoint
  end

  def initialize(endpoint=@@default_endpoint)
    super(endpoint)
  end


  def req_status
    Faraday.get(endpoint+api_path+"/node/syncing")&.status rescue false
  end

  def syncing
    get "/node/syncing"
  end

  def peers
    get "/node/peers"
  end

  def version
    get "/node/version"
  end

  def syncing?
    syncing["syncing"]
  end

  def chainhead
    get "/beacon/chainhead"
  end

  def peercount
    peers["peers"]&.size
  end

  def min_peercount?
    return nil unless req_status
    peercount > node.checklist.config[:prysmbeacon][:minpeercount]
  end

  def get(path)
    response = Faraday.get endpoint+api_path+path
    JSON.parse(response.body)
  end

  def balances(epoch)
    get "/validators/balances?epoch=#{epoch}" 
  end

  private



  def api_path
    @@api_path
  end

end



class ValidatorMetricsInterface < Interface

  @@default_endpoint =   "http://localhost:8081/metrics"

  def self.default_endpoint
    @@default_endpoint
  end

  def initialize(endpoint=@@default_endpoint)
    super(endpoint)
  end

  def get
    response = Faraday.get endpoint
    response.body
  end

  def validator_balances_raw
    get.scan /^validator_balance.*$/
  end

  def parse(balance)
    descriptor, amount = balance.split
    amount = amount.to_f
    pubkey = descriptor.scan(/{pubkey=(.*)}/)&.first&.first.scan(/\w+/)&.first
    {pubkey: pubkey, balance: amount}
  end

  def validator_balances
    validator_balances_raw.map{|balance| parse(balance)}
  end

end
