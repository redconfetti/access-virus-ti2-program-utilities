# frozen_string_literal: true

require_relative "sysex/reader"
require_relative "midi/reader"

module VirusTi
  module FileReader
    SYX_EXTENSIONS = %w[.syx .sysex].freeze
    MIDI_EXTENSIONS = %w[.mid .midi].freeze

    module_function

    def read_messages(path)
      case File.extname(path).downcase
      when *SYX_EXTENSIONS
        Sysex::Reader.read_file(path)
      when *MIDI_EXTENSIONS
        MIDI::Reader.read_file(path)
      else
        raise ArgumentError, "unsupported file type: #{File.extname(path)} (expected .syx or .mid)"
      end
    end
  end
end
