require_relative "./checklist.rb"
require 'pry'


class Report

  attr_accessor :log, :passes, :fails

  def initialize
    @log = []
    @passes = 0
    @fails = 0
  end

  def check(condition,err_message)
    if condition
      puts "."
      self.passes += 1
    else
      self.fails += 1
      puts "(#{fails}) Failed: #{err_message}"
      log << err_message
    end
  end

end



namespace :checklist do

  @report = Report.new
  #TODO hide below in Report class
  def check(*args)
    @report.check(*args)
  end

  checklist = Eth2Checklist.new

  task all: ["clients:all","users:all","system:packages","firewall:all","timekeeping:all"]


  desc "Checking Users"
  namespace :users do

    desc "Checking existence of users"
    task :exist do |t|
      # puts t.comment
      checklist.config[:users].values.each do |user|
        check  checklist.users.id(user), "User \"#{user}\" does not exist "
      end
    end

    task all: [:exist]

  end


  desc "Checking System"
  namespace :system do

    desc "Checking if packages are up to date"
    task :packages do
      check checklist.system.packages_uptodate?, "System packages need to be updated"
    end

  end


  desc "Checking Timekeeping"
  namespace :timekeeping do

    timedate = checklist.timedate

    desc "Check whether system time is synchronized"
    task :synchronized do
      check timedate.clock_synchronized?, "System clock is not synchronized"
    end

    desc "Check whether NTP service is active"
    task :ntp do
      check timedate.ntp_active?, "NTP Service is not active"
    end

    task all: [:synchronized,:ntp]

  end


  desc "Checking Firewall"
  namespace :firewall do

    firewall = checklist.firewall

    desc "Checking whether UFW is active"
    task :active do
      check firewall.active?, "UFW is not active"
    end

    desc "Checking whether UFW incoming is set to default deny"
    task incoming: [:active] do
      check firewall.default_incoming_deny?, "UFW is not denying incoming connections"
    end

    desc "Checking whether ports listed in configuration file are open to incoming connections"
    task open_ports: [:active] do
      closed_ports = firewall.config_ports_closed
      check closed_ports.empty?, "Ports #{closed_ports} are closed to incoming connections"
    end

    task all: [:active,:incoming,:open_ports]

  end

  desc "Checking Clients"
  namespace :clients do

    clients = checklist.clients

    desc "Check whether installation directories exist and have correct owners"
    task :directories do
      clients.installed.values.each do |client|
        client = client.to_sym
        dir = clients.installation_directory(client)
        check dir, "No installation directory found for #{client.to_s}"
        check clients.owner_correct?(client), "Installation directory #{dir} for client #{client} has wrong owner" if dir
      end
    end

    desc "Check whether geth endpoint is reachable"
    task :reachable do
      check clients.geth.req_status == 200 , "Request to geth http client not successful"
    end

    desc "Check if geth block is up to date"
    task geth_synchronized: [:reachable] do
      check clients.geth.block_synchronized? , "Latest block in geth client appears to be out of date"
    end

    desc "Check if geth service is loaded"
    task :geth_loaded do
      check clients.service_loaded?(:geth), "Service for geth is not loaded"
    end

    desc "Check if geth service is active"
    task :geth_active do
      check clients.service_active?(:geth), "Service for geth is not active"
    end

    task all: [:directories]

  end


end
#
#
