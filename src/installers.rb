#
# Class that contains actions for installing and updating clients
#


class Installer < Eth2Object

    def initialize(checklist)
     @checklist = checklist
     @config = checklist.config
    end

    attr_reader :checklist, :config

    def type
        @type
    end

    def user
        config[:users][type]
    end

    def user_id
        checklist.users.id(user)
    end

    def executable_name
        config[:executables][type]
    end

    def datadir
        config[:directories][type]
    end

    def install_path
        config[:system][:binaries]
    end

    def data
        config[:sources][type]
    end

    def create_user
        %x| sudo useradd --no-create-home --shell /bin/false #{user} |
        puts "Created user #{user}"
    end

    def remove_user
        %x| sudo deluser #{user} |
        puts "Removed user #{user}"
    end

    def create_data_directory
        raise "user #{user} must exist" unless user_id
        %x|sudo mkdir -p #{datadir}|
        %x|sudo chown -R #{user}:#{user} #{datadir}|
        %x|sudo chmod 700 #{datadir}|
        puts "Created data directory #{datadir}"
    end

    def remove_data_directory
        %x|sudo trash #{datadir}|
        puts "Removed data directory #{datadir}"
    end

    def latest_version
       checklist.clients.prysmbeacon.latest_version
    end

end



class GethInstaller < Installer

    def initialize(args)
        super(args)
        @type = :geth
    end

    def install_program
        %x| sudo add-apt-repository -y ppa:ethereum/ethereum |
        %x| sudo apt update |
        %x| sudo apt install geth |
    end

    def uninstall_program
        %x| sudo apt remove geth |
    end

    def setup
        create_user
        create_data_directory
    end

    def reverse_setup 
        remove_user
        remove_data_directory
    end

    def install
        setup
        install_program
    end

    def uninstall
        reverse_setup
        uninstall_program
    end

end


class PrysmInstaller < Installer

    # Generates files and services for Prysm clients

    def initialize(args)
        super(args)
        @type = :prysmbeacon # default type is beacon installer
    end

    def type= (type)
       raise "type must be :prysmvalidator or :prysmbeacon" unless [:prysmbeacon,:prysmvalidator].include? type
       @type = type
    end 

    #---

    def copy_executable_(filename,url)
        %x| curl -LO #{url} | 
        puts "Downloaded #{filename}"
        %x| mv ./#{filename} #{executable_name} |
        %x| chmod +x #{executable_name} |
        %x| sudo mv #{executable_name} #{install_path} |
        puts "Created #{install_path}/#{executable_name}"
    end

    def copy_executable_static
        filename  = data[:file]
        url = "#{data[:url]}#{data[:file]}"
        copy_executable_(filename,url)
    end

    def copy_executable
        filename  = data[:prefix] + latest_version + data[:suffix]
        url = "#{data[:parent_url]}/#{latest_version}/#{filename}"
        copy_executable_(filename,url)
    end  

    def remove_executable
        %x| sudo trash #{install_path}/#{executable_name} |
    end

    def update_executable
        remove_executable
        copy_executable
    end

    def update_executable_static
        remove_executable
        copy_executable_static
    end

    def install
        create_user
        create_data_directory
        copy_executable
    end

    def uninstall
        remove_user
        remove_data_directory
        remove_executable
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





class EasyPrysmInstaller < PrysmInstaller

    def install_type(type)
        self.type = type
        install
    end

    def uninstall_type(type)
        self.type = type
        uninstall
    end

    def update(type)
        self.type = type
        raise "user #{user} must exist" unless user_id
        update_executable
    end


    def update_static(type)
        self.type = type
        raise "user #{user} must exist" unless user_id
        update_executable_static
    end


    def install_prysmbeacon
       install_type(:prysmbeacon)
    end

    def install_prysmvalidator
        install_type(:prysmvalidator)
    end

    def uninstall_prysmbeacon
        uninstall_type(:prysmbeacon)
    end

    def uninstall_prysmvalidator
        uninstall_type(:prysmvalidator)
    end

end