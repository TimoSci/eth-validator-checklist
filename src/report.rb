require_relative 'checklist'
require 'json'

class Report
# Class used for generating reports of validator metrics

    def initialize(clients=Eth2Checklist.new.clients, metrics=ValidatorMetricsInterface.new)
        @clients = clients
        @metrics = metrics
    end

    attr_accessor :clients, :metrics

    def current_validator_balances(epoch)
        pubkeys = metrics.validator_balances_base64.map{|h| h[:pubkey64]}
        clients.prysmbeacon.interface.balances_for_epoch(epoch,pubkeys)
    end

    def write_json(data,file="validator-balances.json")
        File.open(file,"w") do |f|
            f.write(data.to_json)
        end
    end

    def write_current_validator_balances(epoch)
        write_json(current_validator_balances(epoch))
    end

end