# frozen_string_literal: true

require "pathname"

root = Pathname.new(__FILE__).realpath.parent.parent
$LOAD_PATH.unshift(root.to_s) unless $LOAD_PATH.include?(root.to_s)

require "virus_ti"

module VirusTi
  module CLI
    module_function

    def usage!(message, bin_name)
      warn message if message
      warn <<~USAGE

        Usage: #{bin_name} <file>

        Interpret Access Virus TI2 SysEx or MIDI files (.syx, .mid).
      USAGE
      exit 1
    end

    def read_path!(argv, bin_name)
      usage!(nil, bin_name) if argv.empty?

      path = argv.first
      usage!("Error: file not found: #{path}", bin_name) unless File.file?(path)

      path
    end
  end
end
