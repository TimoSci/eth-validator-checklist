require_relative "./checklist.rb"
require 'pry'

desc "Check whether users exist"


class PassFail

  attr_accessor :log, :passes, :fails

  def initialize
    @log = []
    @passes = 0
    @fails = 0
  end

  def check(condition,err_message)
    if condition
      puts "."
      self.passes += 1
    else
      self.fails += 1
      puts "(#{fails}) Failed: #{err_message}"
      log << err_message
    end
  end

end



namespace :checklist do

  @passfail = PassFail.new
  #TODO hide below in PassFail class
  def check(*args)
    @passfail.check(*args)
  end

  checklist = Eth2Checklist.new

  task all: ["users:all","firewall:all"]

  desc "Checking Users"
  namespace :users do

    desc "Checking existence of users"
    task :exist do |t|
      # puts t.comment
      checklist.config[:users].values.each do |user|
        check  checklist.users.id(user), "User \"#{user}\" does not exist "
      end
    end

    task all: [:exist]

  end


  desc "Checking System"
  namespace :system do

    desc "Checking if packages are up to date"
    task :packages do
      check checklist.system.packages_uptodate?, "System packages need to be updated"
    end

  end


  desc "Checking Firewall"
  namespace :firewall do

    desc "Checking if  UFW is active"
    task :active do
      check checklist.firewall.active?, "UFW is not active"
    end

    desc "Checking if UFW incoming is set to default deny"
    task incoming: [:active] do
      check checklist.firewall.default_incoming_deny?, "UFW is not denying incoming connections"
    end

    task all: [:active,:incoming]

  end


end
#
#
