#
# Library for converting outputs of Linux commands to Ruby Hashes

#
# Module for command'ufw'
#
module UFW

  def parse(s)
    out = {}
    a = s.split("\n")
    i = a.index("")

    a[0..i].each do |line|
      match = line.scan(/^(\w+):\s*(.*)\s*/)[0]
      if match
        key = match[0]
        value = match[1]
        key.strip!
        if key == "Default"
          value = parse_defaults(value)
        end
        out[key] = value
      end
    end

    a[(i+1)..-1].each do |line|
      match = line.scan(/(^\d+\s?\S+)\s{2,}(\w+\s?\S+)\s{2,}(\S+\s?\S+)/)[0]
      if match
        out[:ports] ||= []
        out[:ports] << {to: match[0], action: match[1], from: match[2] }
      end
    end

    out
  end

  def parse_defaults(s)
    s.scan(/(\w+)\s+\((\w+)\)/).map{|x| x.reverse}.to_h
  end

end
