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

  @passfail = Report.new
  #TODO hide below in Report class
  def check(*args)
    @passfail.check(*args)
  end

  checklist = Eth2Checklist.new

  task all: ["users:all","firewall:all"]

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


end
#
#
