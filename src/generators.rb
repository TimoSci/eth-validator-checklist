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
    raise "template file doesn't exist" unless File.exists? path
    ERB.new File.read(path)
  end

  def parse
    datadir = config[:directories][name.to_sym]
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
    if File.exists? destination_path
      pp "file #{destination_path} already exists"
      return
    end
    %x| sudo cp #{file} #{destination_path} |
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


  attr_accessor :templates


  def get_templates
    config[:clients].values.map{|name| Template.new(name)}
  end

  def set_templates
    self.templates = get_templates
  end


end

g = ServiceGenerator.new

t = Template.new "geth"
binding.pry
