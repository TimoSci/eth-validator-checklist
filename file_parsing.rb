#
# Library for converting Linux Configuration Files to Ruby Hashes

module FileParsing

  module Systemctl

      def config_file(service)
        raise 'not a valid service name' if (service=service.to_s).empty?
        f = File.read("/etc/systemd/system/#{service}.service")
        parse_config_file(f)
        # f.scan( /(^\[\S+\]$)\n(.+)/ )
        # binding.pry
      end

      def parse_config_file(file)
        {}.tap do |out|
          current = nil
          file.each_line do |line|
            next if line.chomp.empty?
            match = line.scan( /^\[(\S+)\]$/ )[0]
            if match
              current = match[0]
              out[current] = []
            else
              out[current] << parse_line(line) if out[current]
            end
          end
        end
      end

      def parse_line(line)
        match = line.scan(/^(\w+)=\s*(.*)$/)[0]
        { match[0] => match[1] }
      end

  end

end
