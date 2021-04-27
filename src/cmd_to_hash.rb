#
# Library for converting outputs of Linux commands to Ruby Hashes

module Commands
#
# Module for command 'ufw'
#
module UFW

  def ufw_status
     parse(%x|sudo ufw status verbose|)
  end

  def parse(s)
    return nil if s.empty?
    out = {}
    a = s.split("\n")
    i = a.index("") || (s.size-1)

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

    return out unless a[i+1]
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


#
# Module for command 'systemctl'
#
module Systemctl

  def systemctl_status(job)
    out = {}
    s = %x|sudo systemctl status #{job.to_s}|
    s.each_line do |line|
      match = line.scan( /^\s*(\w.*\w):\s+(.+)\s+(\(.*)$/ )[0]
      if match
        out[match[0]] = {value: match[1], info: parse_info(match[2])}
      end
    end
    out
  end

  def parse_info(info)
    return nil unless (match = info.scan( /\((.*)\)/ )[0] )
    match[0].split(";").map{|s| s.strip}
  end

end


#
# Module for command 'timedatectl'
#
module Timedatectl

  def timedatectl

    {}.tap do |out|
      (%x|sudo timedatectl|).each_line do |line|
        match = line.scan( /^\s*(\w[^:]*):\s*(.*)\s*/ )[0]
        out [match[0]] = match[1] if match
      end
    end

  end

end


#
# Module for command 'apt list (--upgradable)'
#
module APT

  def apt_list_upgradable
    apt_list("upgradable")
  end

  def apt_list(option)
    {}.tap do |out|
      (%x|apt list --#{option}|).each_line do |line|
        match = line.scan( /^([^\s\/]+)\/(.*)$/ )[0]
        out [match[0]] = match[1] if match
      end
    end
  end

end

#
# Module for command geth
#
module Geth
end

end
