require 'erb'
require 'pathname'
require 'pry'

require_relative 'abstract_classes'
require_relative 'file_parsing'

#
# Classes used for generation of system files
#


class ServiceGenerator < Eth2Object

  @@templates_path = 'templates'

  include FileParsing::Systemctl

  attr_accessor :templates

  def template_path(name)
    "#{root_path.to_s}/#{templates_path}/#{name}.service.erb"
  end

  def get_template(name)
    path = template_path(name)
    binding.pry
    raise "template file doesn't exist" unless File.exists? path
    ERB.new File.read(path)
  end

  def get_templates
    config[:clients].values.map{|name| get_template(name)}
  end

  def set_templates
    self.templates = get_templates
  end

  private

  def root_path
    @root_path_ || (@root_path = root_path_)
  end

  def root_path_
    Pathname.new `pwd`.chomp
  end

  def templates_path
    @@templates_path
  end

end
