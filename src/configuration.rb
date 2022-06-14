module Configuration
# Wrapper for configuration file


    def type
        @type
    end

    def user
        config[:users][type] || (raise "user must be defined in config.yml")
    end

    def user_id
        checklist.users.id(user)
    end

    def executable_name
        config[:executables][type] || (raise "executalbe must be defined in config.yml")
    end

    def datadir
        config[:directories][type] || (raise "data directory must be defined in config.yml")
    end

    def install_path
        config[:system][:binaries] || (raise "directory for binaries must be defined in config.yml")
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


end