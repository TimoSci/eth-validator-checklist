class Firewall

  def query
    @query = (%x|sudo ufw status verbose|)
    def query
      @query
    end
    @query
  end

  def status
    q = query.scan(/^Status:\s*(\w+)/)[0]
    q && q[0]
  end

  def defaults
    q = query.scan(/^Default:.*$/)[0]
    q && q.scan(/(\w+)\s+\((\w+)\)/).map{|x| x.reverse}.to_h
  end


  def active?
    status == "active"
  end

  def default_incoming_deny?
    defaults["incoming"] == "deny"
  end

end


class Clients

  def check_service_status(job)
    jobs = [:geth,:prysmbeacon,:prysmvalidator]
    raise "service must be one of #{jobs.join(' ')}" unless jobs.include? job
    query = %x|sudo sytemctl status #{job.to_s}|
    puts query
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
