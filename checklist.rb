module Firewall

  def status
    (%x|sudo ufw status|).scan(/^Status:\s*(active)/)[0][0]
  end

  def defaults
  end

end

module Clients

  def check_service_status(job)
    jobs = [:geth,:prysmbeacon,:prysmvalidator]
    raise "service must be one of #{jobs.join(' ')}" unless jobs.include? job
    query = %x|sudo sytemctl status #{job.to_s}|
    puts query
  end

end

module Users

  def id(user)
    (%x|id -u #{user.to_s}|).scan(/^(\d)+/)
  end

end



class Eth2Checklist

  def initialize(config)
    @config = config
  end
  attr_reader :config

  include Firewall
  include Clients
  include Users

end
