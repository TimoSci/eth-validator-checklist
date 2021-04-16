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


  def installation_directory
    dir = checklist.config[:directories][name]
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
