require_relative 'cmd_to_hash'
require_relative 'file_parsing'
require_relative 'monads'
require_relative 'helpers'
require_relative 'node'
require_relative 'service'
require_relative 'interfaces'
require_relative 'abstract_classes'


require 'yaml'


class ChecklistSection
  def initialize(checklist=nil)
    @checklist = checklist
  end
  attr_accessor :checklist
end


class Firewall < ChecklistSection

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
    # active? && defaults["incoming"] == "deny"
    active? && defaults["incoming"] == "deny"
  end

  def open_ports_raw
    query[:ports] && query[:ports].select{|p| p[:action] =~ /allow\s+in/i}
  end

  def open_ports
    return nil unless active? && open_ports_raw
    open_ports_raw.map{|h| h[:to].to_i}
  end

  def port_incomig_open?(port,type=nil)
    ports = open_ports.select{|p| p[:to].to_i == port}
    !ports.empty?
  end

  def config_ports
    return [] unless (ports=checklist.config[:ports])
    ports.trample
  end

  def config_ports_closed
    return [] unless active? && open_ports
    config_ports - open_ports
  end

end



class Clients < ChecklistSection

  include Commands::Systemctl
  include FileParsing::Systemctl

  @@custom_nodes = {
    geth: GethNode,
    prysmbeacon: PrysmNode,
    prysmvalidator: PrysmNode
  }

  @@interfaces = {
    geth: GethInterface,
    prysmbeacon: PrysmBeaconInterface
  }

  def initialize(checklist=nil)

    super(checklist)
    @installed = []
    return unless checklist.config
    installed = checklist.config[:clients]
    installed.values.each do |client|
      node_class = Node
      name = client.to_sym

      node_class = @@custom_nodes[name] if @@custom_nodes[name]
      node = node_class.new(name,checklist)
      node.service = Service.new(node)

      instance_variable_set "@"+client, node
      define_singleton_method(name) do
        node
      end
      @installed << node

      if (klass = @@interfaces[name])
        config = Optional.new(checklist.config)
        endpoint = config[name][:http_endpoint].value
        endpoint = klass.default_endpoint unless endpoint
        node.set_interface klass.new(endpoint)
      end

    end

  end

  attr_accessor :installed

  def owner(dir)
    checklist.users.owner(dir)
  end

end



class TimeDate < ChecklistSection
  include Commands::Timedatectl
  include Helpers

  make_query :timedatectl

  def clock_synchronized?
    key = query.keys.find{|s| /system\s+clock\s+synchronized/i =~ s}
    return false unless key
    !!( /\s*yes\s*/ =~  query[key] )
  end

  def ntp_status
     key = query.keys.find{|s| /NTP\s+service/i =~ s}
     key && query[key]
  end

  def ntp_active?
    ntp_status =~ /active/i
  end


  #GETH time eth.getBlock(eth.blockNumber)["timestamp"]
  # Time.now.to_i

end


class Users < ChecklistSection


  attr_accessor :current_user

  def id(user)
    matches = (%x|id -u #{user.to_s}|)
    matches.empty? ? nil : matches.chomp.to_i
  end

  def find_by_id(id)
    q = %x|getent passwd #{id}|
    match = q.scan(/^([^:^\s]+):/ )[0]
    match && match[0]
  end

  def get_current_user
    (%x|who|).scan(/^\w+/).first
  end

  def set_current_user
    self.current_user = get_current_user
  end

  def owner(dir)
    find_by_id(File.stat(dir).uid)
  end

end


class System < ChecklistSection
  include Commands::APT

  def packages_uptodate?
    apt_list_upgradable.size == 0
  end

  def reboot_required?
    File.exist? "/var/run/reboot-required"
  end


end



class Eth2Checklist < Eth2Object

  @@api_config = {
    clients: Clients,
    firewall: Firewall,
    users: Users,
    timedate: TimeDate,
    system: System
  }

  @@default_config_file = "./config_default.yml"
  @@config_file = "config.yml"

  raise "no default configuration file!" unless File.exist? @@default_config_file
  @@config_file= @@default_config_file unless File.exist?(@@config_file)

  def initialize(config=nil)
    super(config)
    @@api_config.each do |methode,klass|
      k = klass.new(self)
      instance_variable_set("@"+methode.to_s,k)
      # k.checklist = self
    end
  end

  @@api_config.keys.each do |methode|
    attr_reader methode
  end

end
