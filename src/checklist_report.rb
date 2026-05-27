class ChecklistReport

  attr_accessor :log, :passes, :fails

  def initialize
    @log = []
    @passes = 0
    @fails = 0
  end

  def check(condition, err_message)
    if condition
      puts "."
      self.passes += 1
    else
      self.fails += 1
      puts "(#{fails}) Failed: #{err_message}"
      log << err_message
    end
  end

  def print
    total = passes + fails
    puts
    puts "======================================="
    puts "Checklist Report:"
    puts "#{fails} checks out of #{total} failed"
    puts "#{passes} checks out of #{total} passed"
    puts "All Checks Passed!" if passes > 0 && fails == 0
    puts "======================================="
  end

end
