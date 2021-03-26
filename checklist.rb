require_relative './cmd_to_hash.rb'


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

  include UFW
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

  include Systemctl

  def query
    @query = systemctl_status
    def query
      @query
    end
    @query
  end

end


class Users

  def id(user)
    matches = (%x|id -u #{user.to_s}|)
    matches.empty? ? nil : matches.chomp.to_i
  end

end




class Eth2Checklist

  @@api_config = {
    firewall: Firewall,
    clients: Clients,
    users: Users
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
