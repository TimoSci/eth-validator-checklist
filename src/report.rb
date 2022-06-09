require_relative 'checklist'
require 'json'
require 'csv'

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

    def read_json(file)
        file = "#{file}.json"
        JSON.parse(File.read(file))
    end

    def write_csv(data,file="validator-balances.csv")
        CSV.open("#{file}.csv","wb") do |f|
          data.each do |name,properties|
            f << [name,properties]
          end
        end
    end

    def write_current_validator_balances(epoch)
        write_json(current_validator_balances(epoch))
    end

end