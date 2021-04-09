require_relative './cmd_to_hash.rb'
require_relative './file_parsing.rb'


module Helpers

  def self.included(base)

    def base.make_query(meth)
      define_method(:query) do
          @query = send(meth)
          def query
            @query
          end
          @query
      end
    end

  end

end




class Firewall

  include Commands::UFW
  include Helpers

  make_query :ufw_status


  def defaults
    query["Default"]
  end

  def status
    query["Status"]
  end

  def active?
    status == "active"
  end

  def default_incoming_deny?
    defaults["incoming"] == "deny"
  end

end


class Clients

  @@installed = [:geth,:prysmvalidator,:prysmbeacon]
  include Commands::Systemctl
  include FileParsing::Systemctl

  # def query(job)
  #   @query = systemctl_status(job)
  #   def query(job)
  #     @query
  #   end
  #   @query
  # end

  # @@installed.include? service.to_sym

end


class TimeDate
  include Commands::Timedatectl
  include Helpers

  make_query :timedatectl

  def clock_synchronized?
    key = query.keys.find{|s| /system\s+clock\s+synchronized/i =~ s}
    return false unless key
    !!( /\s*yes\s*/ =~  query[key] )
  end

  def ntp_active?
  end

  def ntp_status
     key = query.keys.find{|s| /NTP\s+service/i =~ s}
     key && query[key]
  end


  #GETH time eth.getBlock(eth.blockNumber)["timestamp"]
  # Time.now.to_i

end

class Users

  def id(user)
    matches = (%x|id -u #{user.to_s}|)
    matches.empty? ? nil : matches.chomp.to_i
  end

end


class System
  include Commands::APT

  def system_packages_uptodate?
    apt_list_upgradable.size == 0
  end


end



class Eth2Checklist

  @@api_config = {
    firewall: Firewall,
    clients: Clients,
    users: Users,
    timedate: TimeDate,
    system: System
  }

  def initialize(config=nil)

    @config = config
    @@api_config.each do |methode,klass|
      instance_variable_set("@"+methode.to_s,klass.new)
    end
  end

  @@api_config.keys.each do |methode|
    attr_reader methode
  end
  attr_reader :config

end
