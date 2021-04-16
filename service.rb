require_relative 'cmd_to_hash'
require_relative 'helpers'

#
# class for wrapping the actions of a client's system service
#

class Service

  include Commands::Systemctl
  include Helpers

  def initialize(client)
    @client = client
  end
  attr_accessor :client

  def status
     systemctl_status(client.name)
  end

  make_query :status

  def loaded?
    s = query["Loaded"]
    s && s[:value] == "loaded"
  end

  def active?
    s = query["Active"]
    s && s[:value] == "active"
  end

  def enabled?
    s = query["Loaded"]
    return nil unless s
    info = s[:info]
    return nil unless info
    !!(info[1] =~ /enabled/) 
  end

end
