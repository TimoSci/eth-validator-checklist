#
# Library for converting Linux Configuration Files to Ruby Hashes

module FileParsing

  module Systemctl

      def config_file(service)
        raise 'not a valid service name' if (service=service.to_s).empty?
        filename = "/etc/systemd/system/#{service}.service"
        return nil unless File.exist?(filename)
        f = File.read(filename)
        parse_config_file(f)
      end

      def parse_config_file(file)
        {}.tap do |out|
          current = nil
          file.each_line do |line|
            next if line.chomp.empty?
            match = line.scan( /^\[(\S+)\]$/ )[0]
            if match
              current = match[0]
              out[current] = {}
            else
              if out[current]
                key, value = parse_line(line)
                out[current][key] = value
              end
            end
          end
        end
      end

      def parse_line(line)
        key, value = parse_line_raw(line)
        value = parse_exec(value) if key == "ExecStart"
        [ key , value ]
      end

      def parse_line_raw(line)
        match = line.scan(/^(\w+)=\s*(.*)$/)[0]
        [match[0], match[1]]
      end

      def parse_exec(string)
        options = {}
        a = string.split('--')
        executable = a[0]
        a[1..-1].each do |pair|
          pair.strip!
          option,value = pair.split(/=|\s/)
          option =  option
          options[option] = value
        end
        {executable: executable, options:options}
      end

  end

end
