require 'thor'
require_relative 'checklist'
require_relative 'generators'
require_relative 'installers'
require_relative 'checklist_report'

class ChecklistCLI < Thor

  no_commands do
    def checklist
      @checklist ||= Eth2Checklist.new
    end

    def report
      @report ||= ChecklistReport.new
    end

    def check(condition, err_message)
      report.check(condition, err_message)
    end
  end

  desc "users", "Check existence of users"
  def users
    checklist.config[:users].values.each do |user|
      check checklist.users.id(user), "User \"#{user}\" does not exist"
    end
  end

  desc "system_checks", "Check system packages and reboot status"
  def system_checks
    check checklist.system.packages_uptodate?, "System packages need to be updated"
    check !checklist.system.reboot_required?, "System needs to be rebooted"
  end

  desc "timekeeping", "Check time synchronization and NTP"
  def timekeeping
    timedate = checklist.timedate
    check timedate.clock_synchronized?, "System clock is not synchronized"
    check timedate.ntp_active?, "NTP Service is not active"
  end

  desc "firewall", "Check firewall status and rules"
  def firewall
    fw = checklist.firewall
    check fw.active?, "UFW is not active"
    if fw.active?
      check fw.default_incoming_deny?, "UFW is not denying incoming connections"
      closed_ports = fw.config_ports_closed
      check closed_ports.empty?, "Ports #{closed_ports} are closed to incoming connections"
    end
  end

  desc "clients", "Check all client services"
  def clients
    clients_obj = checklist.clients

    # Check directories
    clients_obj.installed.each do |client|
      name = client.name.to_s
      dir = client.installation_directory
      check dir, "No installation directory found for #{name}"
      check client.owner_correct?, "Installation directory #{dir} for client #{name} has wrong owner" if dir
    end

    # Check each client's service
    clients_obj.installed.each do |client|
      name = client.name.to_s
      puts "\n--- #{name} ---"
      check client.service.loaded?, "Service for #{name} is not loaded"
      check client.service.active?, "Service for #{name} is not active"
      check client.service.enabled?, "Service for #{name} is not enabled on startup" if client.service.loaded?
      check client.service.datadir_correct?, "Service for #{name} does not have correct data directory"
      check client.current_version_is_latest?, "Client #{name} version does not appear to be latest version #{client.latest_version}"

      if (interface = client.interface)
        check interface.req_status == 200, "Request to #{name} http client not successful"
      end
    end

    # Geth-specific checks
    if clients_obj.respond_to?(:geth) && (interface = clients_obj.geth.interface)
      puts "\n--- geth (extended) ---"
      check clients_obj.geth.version_check, "Geth version appears to have vulnerabilities. Please upgrade."
      if interface.req_status == 200
        check interface.block_synchronized?, "Latest block in geth client appears to be out of date"
        check interface.synchronized?, "Geth node appears to not be synchronized"
        check interface.min_peercount?, "Not enough peers are connected to geth"
      end
    end

    # Prysmbeacon-specific checks
    if clients_obj.installed.map(&:name).include?(:prysmbeacon) &&
       clients_obj.respond_to?(:prysmbeacon) &&
       (interface = clients_obj.prysmbeacon.interface)
      puts "\n--- prysmbeacon (extended) ---"
      check !interface.syncing?, "Prysmbeacon node has not finished syncing"
      check interface.min_peercount?, "Prysmbeacon has low peer count. #{interface.peercount} peers connected"
    end
  end

  desc "all", "Run all checklist checks"
  def all
    invoke :users
    invoke :system_checks
    invoke :timekeeping
    invoke :firewall
    invoke :clients
    report.print
  end

  default_task :all
end


class GenerateCLI < Thor

  desc "services", "Generate all .service files and copy to system directory"
  def services
    generator = ServiceGenerator.new
    generator.create_and_copy_files
  end

  desc "service NAME", "Generate a single .service file and copy to system directory"
  def service(name)
    generator = ServiceGenerator.new
    generator.each_template do |template|
      if template.name == name
        template.create_and_copy_file
        return
      end
    end
    puts "Unknown service: #{name}"
  end
end


class InstallCLI < Thor

  desc "prysm TYPE", "Install a prysm client (beacon or validator)"
  def prysm(type)
    installer = EasyPrysmInstaller.new(Eth2Checklist.new)
    case type
    when "beacon"
      installer.install_type :prysmbeacon
    when "validator"
      installer.install_type :prysmvalidator
    else
      puts "Unknown type: #{type}. Use 'beacon' or 'validator'."
    end
  end

  desc "geth", "Install and setup geth"
  def geth
    installer = GethInstaller.new(Eth2Checklist.new)
    installer.install
  end
end


class UninstallCLI < Thor

  desc "prysm TYPE", "Uninstall a prysm client (beacon or validator)"
  def prysm(type)
    installer = EasyPrysmInstaller.new(Eth2Checklist.new)
    case type
    when "beacon"
      installer.uninstall_type :prysmbeacon
    when "validator"
      installer.uninstall_type :prysmvalidator
    else
      puts "Unknown type: #{type}. Use 'beacon' or 'validator'."
    end
  end

  desc "geth", "Uninstall geth"
  def geth
    installer = GethInstaller.new(Eth2Checklist.new)
    installer.uninstall
  end
end


class UpdateCLI < Thor

  desc "prysm TYPE", "Update a prysm client (beacon or validator)"
  method_option :static, type: :boolean, default: false, desc: "Use static version from config.yml"
  def prysm(type)
    installer = EasyPrysmInstaller.new(Eth2Checklist.new)
    sym = case type
          when "beacon" then :prysmbeacon
          when "validator" then :prysmvalidator
          else
            puts "Unknown type: #{type}. Use 'beacon' or 'validator'."
            return
          end

    if options[:static]
      installer.update_static(sym)
    else
      installer.update(sym)
    end
  end
end


class EthcheckCLI < Thor

  desc "create_config", "Create configuration file"
  def create_config
    system("cp config_default.yml config.yml") unless File.exist?("config.yml")
  end

  desc "create_config_testnet", "Create configuration file for testnet"
  def create_config_testnet
    system("cp config_default_testnet.yml config.yml") unless File.exist?("config.yml")
  end

  desc "checklist SUBCOMMAND", "Run checklist checks"
  subcommand "checklist", ChecklistCLI

  desc "generate SUBCOMMAND", "Generate service files"
  subcommand "generate", GenerateCLI

  desc "install SUBCOMMAND", "Install clients"
  subcommand "install", InstallCLI

  desc "uninstall SUBCOMMAND", "Uninstall clients"
  subcommand "uninstall", UninstallCLI

  desc "update SUBCOMMAND", "Update clients"
  subcommand "update", UpdateCLI

end
