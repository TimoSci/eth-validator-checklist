#
# Class that contains actions for installing and updating clients
#


class Installer < Eth2Object
    
    def add_user
      %x|sudo useradd --no-create-home --shell /bin/false #{user}| 
    end
end

class GethInstaller < Installer

    def user
        config[:users][:prysmbeacon]
    end

end

    # Generates files and services for client

    def user
        config[:users][:prysmbeacon]
    end

    def create_data_directory
        datadir = config[:directories][:prysmbeacon]
        %x|sudo mkdir -p #{datadir}|
        %x|sudo chown -R #{user}:#{user} #{datadir}|
        %x|sudo chmod 700 #{datadir}|
    end

    def install_prysm
    
        config_beacon = config[:sources][:prysmbeacon]
        config_validator = config[:sources][:prysmvalidator]
        %x| curl -LO #{config_beacon[:url]}#{config_beacon[:file]} | 
        %x| curl -LO #{config_validator[:url]}#{config_validator[:file]} | 

        %x| mv ./#{config_beacon[:file]} beacon-chain |
        %x| mv ./#{config_validator[:file]} validator |

        %x| chmod +x beacon-chain |
        %x| chmod +x validator |

        %x| sudo cp beacon-chain /usr/local/bin |
        %x| sudo cp validator /usr/local/bin |
    end

    def install(source= :prysmbeacon, executable_name)

        config_source = config[:sources][source]
        %x| curl -LO #{config_source[:url]}#{config_source[:file]} | 
        %x| mv ./#{config_source[:file]} #{executable_name} |
        %x| chmod +x #{executable_name} |
        %x| sudo cp #{executable_name} /usr/local/bin |

    end

    def install_prysmbeacon
        install(:prysmbeacon, "beacon-chain")
    end

    def install_prysmvalidator
        install(:prysmvalidator, "validator")
    end


    
  
end