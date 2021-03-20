class Eth2Checklist

  def initialize(config)
    @config = config
  end
  attr_reader :config

  def check_service_status(job)
    jobs = [:geth,:prysmbeacon,:prysmvalidator]
    raise "service must be one of #{jobs.join(' ')}" unless jobs.include? job
    query = %x|sudo sytemctl status #{job.to_s}|
    puts query
  end

end
