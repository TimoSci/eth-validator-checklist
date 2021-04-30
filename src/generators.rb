require 'erb'

require_relative 'abstract_classes'
require_relative 'file_parsing'

#
# Classes used for generation of system files
#


class ServiceGenerator < Eth2Object

  @@templates_path = '../templates'

  include FileParsing::Systemctl

  attr_accessor :templates

  def get_template(name)
    ERB.new File.read('#{templates_path}/#{name}.service.erb')
  end

  def get_templates
    config[:clients].values.map{|name| get_template(name)}
  end

  def set_templates
    self.templates = get_templates
  end

end
