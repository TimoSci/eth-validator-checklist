require_relative '../src/interfaces'
require_relative '../src/cmd_to_hash'

require 'pry'

RSpec.describe Interface do

  interface = Interface.new("http://localhost:8545")

  context "Endpoint is reachable" do
    it "receives an http response from client" do
      interface.endpoint = "http://localhost:8545"
      expect(interface.req_status).to eq 200
    end
  end

  context "Endpoint is not reachable" do
    it "correctly returns syncing status" do
      interface.endpoint = "http://localhost:35167"
      expect(interface.req_status).not_to eq 200
    end
  end

end
