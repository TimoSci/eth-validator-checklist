class Firewall

  def query
    @query = (%x|sudo ufw status verbose|)
    def query
      @query
    end
    @query
  end

  def parse(s)
    out = {}
    a = s.split("\n")
    i = a.index("")

    a[0..i].each do |line|
      match = line.scan(/^(\w+):\s*(.*)\s*/)[0]
      if match
        key = match[0]
        value = match[1]
        key.strip!
        if key == "Default"
          value = parse_defaults(value)
        end
        out[key] = value
      end
    end

    a[(i+1)..-1].each do |line|
      match = line.scan(/(^\d+\s?\S+)\s{2,}(\w+\s?\S+)\s{2,}(\S+\s?\S+)/)[0]
      if match
        out[:ports] ||= []
        out[:ports] << {to: match[0], action: match[1], from: match[2] }
      end
    end

    out
  end

  def parse_defaults(s)
    s.scan(/(\w+)\s+\((\w+)\)/).map{|x| x.reverse}.to_h
  end

  def defaults
    q = query.scan(/^Default:.*$/)[0]
    q && q.scan(/(\w+)\s+\((\w+)\)/).map{|x| x.reverse}.to_h
  end


  def status
    q = query.scan(/^Status:\s*(\w+)/)[0]
    q && q[0]
  end


  def active?
    status == "active"
  end

  def default_incoming_deny?
    defaults["incoming"] == "deny"
  end

end


class Clients

  def service_status(job)
    jobs = [:geth,:prysmbeacon,:prysmvalidator]
    raise "service must be one of #{jobs.join(' ')}" unless jobs.include? job
    query = %x|sudo systemctl status #{job.to_s}|
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
