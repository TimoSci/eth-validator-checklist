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
    @name = :geth
  end
  attr_accessor :client, :name
  # make_query :systemctl_status(:geth) # TODO get client name from client class

  def load_status
    systemctl_status(name)["Loaded"]
  end

  def loaded?
     status = load_status(name)
     status && status[:value] == "loaded"
  end

  def active?(client)
    status = systemctl_status(name)["Active"]
    status && status[:value] == "active"
  end

end
