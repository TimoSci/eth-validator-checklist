#
# Class that contains actions for installing and updating clients
#


class Installer < Eth2Object
end

class BeaconInstaller < Installer
    # Generates files and services for client

    def user
        config[:users][:prysmbeacon]
    end
    
    def add_user
      %x|sudo useradd --no-create-home --shell /bin/false #{user}| 
    end

    def create_data_directory
        datadir = config[:directories][:prysmbeacon]
        %x|sudo mkdir -p #{datadir}|
        %x|sudo chown -R #{user}:#{user} #{datadir}|
        %x|sudo chmod 700 #{datadir}|
    end
  
end