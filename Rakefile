desc "create configuration file"
task :create_config do
  system("cp config_default.yml config.yml") unless File.exists? "config.yml"
end

require_relative "./checklist.rb"




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




desc "perform all checklist tasks"
task "checklist:all" => [:create_config] do
  Rake.application.in_namespace( :checklist ){ |namespace| namespace.tasks.each( &:invoke ) }
end

namespace :checklist do

  @report = Report.new
  #TODO hide below in Report class
  def check(*args)
    @report.check(*args)
  end

  checklist = Eth2Checklist.new


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

    desc "Checking system reboot-required"
    task :reboot do
      check !checklist.system.reboot_required?, "System needs to be rebooted"
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
      clients.installed.each do |client|
        name = client.name.to_s
        dir = client.installation_directory
        check dir, "No installation directory found for #{name}"
        check client.owner_correct?, "Installation directory #{dir} for client #{name} has wrong owner" if dir
      end
    end


    clients.installed.each do |client|
      name = client.name.to_s

      namespace name.to_sym do

        desc "Check if #{name} service is loaded"
        task :loaded do
          check client.service.loaded?, "Service for #{name} is not loaded"
        end

        desc "Check if #{name} service is active"
        task :active do
          check client.service.active?, "Service for #{name} is not active"
        end
        #
        desc "Check if #{name} service is enabled on startup"
        task enabled: [:loaded]  do
          check client.service.enabled?, "Service for #{name} is not enabled on startup"
        end

        desc "Check if #{name} service is configured to correct data directory"
        task :dir  do
          check client.service.datadir_correct?, "Service for #{name} does not have correct data directory"
        end

        desc "Check if #{name} client is latest version"
        task :latest_version  do
          check client.current_version_is_latest?, "Client #{name} version does not appear to be latest version #{client.latest_version} "
        end

        task service_all: [:loaded, :active, :enabled, :dir]

      end

    end


    namespace :geth do

      interface = clients.geth.interface

      desc "Check geth version"
      task :version do
        check clients.geth.version_check , "Geth version appears to have vulnerabilities. Please upgrade."
      end


      desc "Check whether geth endpoint is reachable"
      task :reachable do
        check interface.req_status == 200 , "Request to geth http client not successful"
      end

      desc "Check if geth block is up to date"
      task block_synchronized: [:reachable] do
        check interface.block_synchronized? , "Latest block in geth client appears to be out of date"
      end

      desc "Check if geth node is synchronzied"
      task synchronized: [:reachable] do
        check interface.synchronized? , "Geth node appears to not to be synchronized"
      end

      desc "Check if peers are connected to geth"
      task peercount: [:reachable] do
        check interface.min_peercount? , "Not enough peers are connected to geth"
      end

    end

    task geth: ["geth:service_all", "geth:block_synchronized", "geth:synchronized", "geth:peercount"]
    # task all: [:directories, :geth]
    #


  end





end
#
#
