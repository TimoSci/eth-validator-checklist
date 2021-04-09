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

  # desc "Checking System"
  # namespace :system do
  #
  #   "Checkin if packages are up to date"
  #   task :packages do
  #   end
  #
  # end


end
#
#
