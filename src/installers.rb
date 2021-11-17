#
# Class that contains actions for installing and updating clients
#


class Installer < Eth2Object

    def initialize(checklist)
     @checklist = checklist
     @config = checklist.config
    end

    attr_reader :checklist, :config
    
    def add_user
      %x|sudo useradd --no-create-home --shell /bin/false #{user}| 
    end
end

class GethInstaller < Installer

    def user
        config[:users][:geth]
    end

end


class PrysmInstaller < Installer

    # Generates files and services for client

    def user
        config[:users][:prysmbeacon]
    end

    def create_user
       %| sudo useradd --no-create-home --shell /bin/false #{user} |
    end

    def remove_user
        %| sudo deluser #{user} |
    end

    def create_data_directory(datadir)
        %x|sudo mkdir -p #{datadir}|
        %x|sudo chown -R #{user}:#{user} #{datadir}|
        %x|sudo chmod 700 #{datadir}|
    end

    def remove_data_directory(datadir)
        %x|sudo trash #{datadir}|
    end


    def latest_version
       checklist.clients.prysmbeacon.latest_version
    end

    def create_executable(source, executable_name)
        config_source = config[:sources][source]
        %x| curl -LO #{config_source[:url]}#{config_source[:file]} | 
        %x| mv ./#{config_source[:file]} #{executable_name} |
        %x| chmod +x #{executable_name} |
        %x| sudo trash /usr/local/bin/#{executable_name} |
        %x| sudo mv #{executable_name} /usr/local/bin |
    end

    def update_executable(executable_name)
        filename = "beacon-chain-#{latest_version}-linux-amd64"
        %x| curl -LO https://github.com/prysmaticlabs/prysm/releases/download/#{latest_version}/#{filename} |
        puts "Downloaded #{filename}"
        %x| mv ./#{filename} #{executable_name} |
        %x| chmod +x #{executable_name} |
        %x| sudo trash /usr/local/bin/#{executable_name} |
        %x| sudo mv #{executable_name} /usr/local/bin |
    end    

    def update_prysmbeacon
        update_executable("beacon-chain")
    end

    def remove_executable(executable_name)
        %x| sudo trash /usr/local/bin/#{executable_name}  |
    end


    def install_prysmbeacon
        create_user
        create_data_directory(config[:directories][:prysmbeacon])
        update_executable("beacon-chain")
    end

    def uninstall_prysmbeacon
        remove_user
        remove_data_directory(config[:directories][:prysmbeacon])
        remove_executable("beacon-chain")
    end

    def install_prysmvalidator
        create_data_directory(config[:directories][:prysmvalidator])
        create_executable(:prysmvalidator, "validator")
    end

    def stop_prysm_services
        %x|sudo systemctl stop prysmvalidator|
        %x|sudo systemctl stop prysmbeacon|
    end

    def start_prysm_services
        %x|sudo systemctl start prysmbeacon|
        %x|sudo systemctl start prysmvalidator|
    end    
  
end