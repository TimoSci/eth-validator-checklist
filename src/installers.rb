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

    def executable_name
        config[:executables][:prsymbeacon]
    end

    def create_user
        %x| sudo useradd --no-create-home --shell /bin/false #{user} |
    end

    def remove_user
        %x| sudo deluser #{user} |
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

    def copy_executable_static(source, executable_name)
        config_source = config[:sources][source]
        %x| curl -LO #{config_source[:url]}#{config_source[:file]} | 
        %x| mv ./#{config_source[:file]} #{executable_name} |
        %x| chmod +x #{executable_name} |
        %x| sudo trash /usr/local/bin/#{executable_name} |
        %x| sudo mv #{executable_name} /usr/local/bin |
    end

    def copy_executable(source)
        data = config[:sources][source]
        filename  = data[:prefix]+latest_version+data[:suffix]
        executable = config[:executables][source]
        install_path = config[:system][:binaries]
        %x| curl -LO #{data[:parent_url]}/#{latest_version}/#{filename} | 
        puts "Downloaded #{filename}"
        %x| mv ./#{filename} #{executable} |
        %x| chmod +x #{executable} |
        %x| sudo mv #{executable} #{install_path} |
        puts "Created #{install_path}/#{executable} "
    end  

    def update_prysmbeacon
        copy_executable(:prysmbeacon)
    end

    def remove_executable(source)
        %x| sudo trash #{config[:system][:binaries]}/#{config[:executables][source]} |
    end


    def install_prysmbeacon
        create_user
        create_data_directory(config[:directories][:prysmbeacon])
        copy_executable(:prysmbeacon)
    end

    def uninstall_prysmbeacon
        remove_user
        remove_data_directory(config[:directories][:prysmbeacon])
        remove_executable(:prysmbeacon)
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