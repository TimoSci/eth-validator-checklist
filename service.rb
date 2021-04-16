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
    # @name = client.name
  end
  attr_accessor :client # TODO get client name from client class

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

end
