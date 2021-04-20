require_relative 'cmd_to_hash'
require_relative 'file_parsing'
require_relative 'helpers'
require_relative 'monads'

#
# class for wrapping the actions of a client's system service
#

class Service

  include Commands::Systemctl
  include FileParsing::Systemctl
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

  def datadir_correct?
    data = Optional.new( config_file(client.name) )
    service_dir = data["Service"]["ExecStart"]["datadir"].value
    client.config_dir == service_dir
  end

end
