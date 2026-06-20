# frozen_string_literal: true

require_relative "smf"
require_relative "../sysex/reader"

module VirusTi
  module MIDI
    module Reader
      module_function

      def sysex_events(data)
        data = data.b
        return Sysex::Reader.split(data) unless smf_file?(data)

        SMF.parse(data)
      end

      def messages(data)
        sysex_events(data).map { |event| Sysex::Message.new(event) }
      end

      def read_file(path)
        messages(File.binread(path))
      end

      def smf_file?(data)
        data.byteslice(0, 4) == "MThd"
      end
    end
  end
end
