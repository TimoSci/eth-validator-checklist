require 'yaml'

class Eth2Object

  @@config_file = "config.yml"

  def initialize(config=nil)
    @config = config
    config_from_file if File.exists? @@config_file
  end
  attr_reader :config

  private

  def config_from_file(file=@@config_file)
    @config = YAML::load(File.read(file))
  end

end
