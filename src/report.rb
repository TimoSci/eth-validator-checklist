require_relative 'checklist'
require 'json'
require 'csv'

class Report
# Class used for generating reports of validator metrics

    def initialize(clients=Eth2Checklist.new.clients, metrics=ValidatorMetricsInterface.new)
        @clients = clients
        @metrics = metrics
        @default_filename = "validator-balances"
        @validator_data = ValidatorData.new
        @validator_data.default_filename = @default_filename
    end

    attr_accessor :clients, :metrics, :validator_data

    # def current_validator_balances(epoch)
    #     pubkeys = metrics.validator_balances_base64.map{|h| h[:pubkey64]}
    #     clients.prysmbeacon.interface.balances_for_epoch(epoch,pubkeys)
    # end

    def current_validator_balances(epoch)
        validator_data.balances(epoch)
    end

    # def write_json(data,file="#{default_filename}.json")
    #     File.open(file,"w") do |f|
    #         f.write(data.to_json)
    #     end
    # end

    # def read_json(file="#{default_filename}")
    #     file = "#{file}.json"
    #     JSON.parse(File.read(file))
    # end

    # def write_csv(data,file="#{default_filename}.csv")
    #     CSV.open(file,"wb") do |f|
    #       data.each do |name,properties|
    #         f << [name,properties]
    #       end
    #     end
    # end

    def write_current_validator_balances(epoch)
        validator_data.write_json(current_validator_balances(epoch))
    end

end


class ValidatorData

    attr_accessor :data, :default_filename

    def balances(epoch)
        pubkeys = metrics.validator_balances_base64.map{|h| h[:pubkey64]}
        clients.prysmbeacon.interface.balances_for_epoch(epoch,pubkeys)
    end

    def get_balances(epoch)
        self.data = balances(epoch)
    end

    def to_table(data)
        titles = ["epoch","public_key","index","balance","status"]
        out = data.map do |h|
            balances = h["balances"][0]
            [h["epoch"]]+balances.values
        end
        titles+out
    end

    def write_json(file="#{default_filename}.json")
        File.open(file,"w") do |f|
            f.write(data.to_json)
        end
    end

    def read_json(file="#{default_filename}")
        file = "#{file}.json"
        JSON.parse(File.read(file))
    end

    def write_csv(data,file="#{default_filename}.csv")
        CSV.open(file,"wb") do |f|
          to_table(data).each do |line|
            f << line
          end
        end
    end

end