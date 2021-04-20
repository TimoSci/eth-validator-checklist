#
# Class for wrapping the all the actions associated with a node (eg. geth, prysm)
#

class Node

  def initialize(name,checklist,interface=nil,service=nil)
    @name = name
    @checklist = checklist
    @interface = interface
    @service = service
  end

  attr_reader :name
  attr_accessor :checklist, :interface, :service

  # def self.owner(dir)
  #   checklist.users.find_by_id(File.stat(dir).uid)
  # end

  def set_interface(interface)
    @interface = interface
    interface.node = self
  end


  def config_dir
    checklist.config[:directories][name]
  end

  def installation_directory
    dir = config_dir
    return nil unless dir
    Dir.exists?(dir) ? Dir.entries(dir) : nil
  end

  def install_dir_owner
    dir = checklist.config[:directories][name]
    dir && checklist.users.owner(dir)
  end

  def owner_correct?
    return false unless (user = checklist.config[:users][name])
    install_dir_owner == user
  end

end


class GethNode < Node

  def version_check
    response = %x|geth version-check|
    !!(response =~ /no\s+vulnerabilities\s+found/i)
  end

end
