require 'erb'
require 'pathname'
require 'pry'

require_relative 'abstract_classes'
require_relative 'file_parsing'

#
# Classes used for generation of system files
#

class Template < Eth2Object

  include FileParsing::Systemctl

  @@templates_path = 'templates'

  def initialize(name,config=nil)
    super(config)
    @name = name
  end
  attr_reader :name

  def path
    "#{root_path.to_s}/#{templates_path}/#{name}.service.erb"
  end
  
  def get_erb
    raise "template file doesn't exist" unless File.exist? path
    ERB.new File.read(path)
  end

  def parse
    name = self.name.to_sym
    executable = config[:executables][name]
    datadir = config[:directories][name]
    network = config[name]&.[] :network
    port = config[:ports][name]
    tcp_port = config[:ports][:prysm][:tcp]
    udp_port = config[:ports][:prysm][:udp]
    flag = "--#{network}" if network
    get_erb.result(binding)
  end

  def file
    "assets/#{name}.service"
  end

  def create_file
    File.write file, parse
  end

  def copy_file
    dir = config[:system][:services]
    destination_path = dir+"/#{name}.service"
    if File.exist? destination_path
      pp "file #{destination_path} already exists"
      return
    end
    %x| sudo cp #{file} #{destination_path} |
  end

  def create_and_copy_file
    create_file
    copy_file
  end

  private

  def root_path
    @root_path_ || (@root_path = root_path_)
  end

  #TODO add method for finding root path
  def root_path_
    Pathname.new `pwd`.chomp
  end

  def templates_path
    @@templates_path
  end

end



class ServiceGenerator < Eth2Object

    def each_template
      config[:clients].values.each{|name| yield Template.new(name)}
    end

    def create_files
      each_template(&:create_file)
    end

    def create_and_copy_files
      each_template(&:create_and_copy_file)
    end

end


class FileGeneratorBeacon < Eth2Object
  # Generates files and services for client
  
  def add_user(user)
    `sudo useradd --no-create-home --shell /bin/false #{user}` 
  end

end