module Helpers

  def self.included(base)

    def base.make_query(meth)
      # memoization
      define_method(:query) do
          @query = send(meth)
          def query
            @query
          end
          @query
      end
    end

  end

end


module Enumerable

  #Extentions for mixed data structures consisting of nested Arrays and Hashes
  #---------------------------------------------------------------------------

  # Generalized recursive sender of iterator methods to Enumerable trees.
  def deep_send(iterator)
    deep =->(x) do
      case x
      when Enumerable
        x.send(iterator){|e| deep.(e)}
      else
        yield x
      end
    end
    deep.(self)
  end

  # Like #each, but it loops through every Array and Hash in a nested Array/Hash data structure.
  # For Hashes it iterates through the keys and for Arrays it iterates through the values.
  def each_deep
    self.deep_send("each_values"){|e| yield e}
  end

  # Like #map, but it maps every element in a nested Hash/Array data structure.
  # For an Array is maps the elements and for a Hash it maps the values
  def map_deep
    self.deep_send("map_values"){|e| yield e}
  end

  # A #map that works both for Arrays and Hashes. For Hashes it keeps the original keys.
  def map_values
    case self
    when Array
      self.map{|e| yield e}
    when Hash
      self.map{|k,v| [k,(yield v)]}.to_h
    end
  end

  # An #each that works both for Arrays and Hashes. For Hashes it iterates over the values.
  def each_values
    case self
    when Array
      array = self
    when Hash
      array = self.values
    end
    array.each{|e| yield e}
  end

  # Like #flatten, but it also flattens Hashes inside a nested Hash/Array data structure.
  # The values of Hashes are pushed into the output array and the keys are discarded
  def trample
    out = []
    self.each_deep{|e| out << e}
    out
  end

  # Like #include, but it searches through all Array elements and Hash values.
  def include_deep?(input)
    self.each_deep{|e| return true if e == input}
    return false
  end

  # Selects a hash of all Hash sub-branches based on the key
  # Returns an array of the values of found branches
  def select_branches_by_key
    branches = []
    deep =->(x){
      case x
      when Array
        x.each{|e| deep.(e)}
      when Hash
        x.each{|k,v| deep.(v) }
        selected =  x.select{|k,v| yield k}
        branches |= selected.values if selected != {}
      end
    }
    deep.(self)
    branches
  end


end
