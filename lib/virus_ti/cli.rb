# frozen_string_literal: true

require "optparse"
require "pathname"

root = Pathname.new(__FILE__).realpath.parent.parent
$LOAD_PATH.unshift(root.to_s) unless $LOAD_PATH.include?(root.to_s)

require "virus_ti"

module VirusTi
  module CLI
    CommandOptions = Data.define(:path, :slot, :output_format, :output_path, :help)

    HELP = {
      "virus-scan" => <<~HELP,
        Usage: virus-scan [--help] <file>

        Brief summary of an Access Virus TI2 SysEx or MIDI file: message counts,
        file type (arrangement, bank, single), and SysEx command breakdown.

        Examples:
          virus-scan program.syx
          virus-scan bank.mid
      HELP
      "virus-list" => <<~HELP,
        Usage: virus-list [--help] <file>

        List programs or arrangement parts in a file with names, bank/slot, and
        checksum status.

        Examples:
          virus-list bank.syx
          virus-list arrangement.mid
      HELP
      "virus-show" => <<~HELP
        Usage: virus-show [--help] [--slot N] [--output FORMAT FILE] <file>

        Show all mapped Single Dump parameters for one program or arrangement part.

        Options:
          --slot N                 1-based program index (bank) or part number (arrangement)
          --output csv FILE        Write parameter listing as CSV
          --output pdf FILE        Write parameter listing as PDF

        Examples:
          virus-show --slot 1 bank.syx
          virus-show --slot 3 arrangement.syx
          virus-show --slot 1 --output csv params.csv program.syx
          virus-show --slot 2 --output pdf params.pdf arrangement.mid
      HELP
    }.freeze

    module_function

    def parse!(argv, command)
      options = {
        path: nil,
        slot: nil,
        output_format: nil,
        output_path: nil,
        help: false
      }

      parser = OptionParser.new do |opts|
        opts.banner = HELP.fetch(command).lines.first.strip

        opts.on("-h", "--help", "Show help") do
          options[:help] = true
        end

        if command == "virus-show"
          opts.on("--slot N", Integer, "Program or part number (1-based, required)") do |value|
            options[:slot] = value
          end

          opts.on("--output FORMAT") do |format|
            options[:output_format] = format.downcase.to_sym
            options[:output_path] = ARGV.shift
            unless options[:output_path]
              abort_with_help(command, "--output requires a filename (e.g. --output csv params.csv)")
            end
          end
        end
      end

      parser.order!(argv)

      if options[:help]
        puts HELP.fetch(command)
        exit 0
      end

      path = argv.shift
      abort_with_help(command, "missing file argument") unless path
      abort_with_help(command, "file not found: #{path}") unless File.file?(path)

      if command == "virus-show"
        validate_show_output!(options)
      end

      CommandOptions.new(
        path: path,
        slot: options[:slot],
        output_format: options[:output_format],
        output_path: options[:output_path],
        help: false
      )
    end

    def validate_show_output!(options)
      return unless options[:output_format]

      unless %i[csv pdf].include?(options[:output_format])
        abort_with_help("virus-show", "unsupported output format: #{options[:output_format]} (use csv or pdf)")
      end

      abort_with_help("virus-show", "missing output filename") unless options[:output_path]
    end

    def abort_with_help(command, message)
      warn "Error: #{message}"
      warn
      warn HELP.fetch(command)
      exit 1
    end

    def emit(content, options, binary: false)
      if options.output_path
        Output::Formatter.write_file(options.output_path, content, binary: binary)
      else
        binary ? $stdout.binwrite(content) : puts(content)
      end
    end
  end
end
