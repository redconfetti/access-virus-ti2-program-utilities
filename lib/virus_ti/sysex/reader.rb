# frozen_string_literal: true

require_relative "constants"
require_relative "message"

module VirusTi
  module Sysex
    module Reader
      module_function

      def split(data)
        data = data.b
        messages = []
        index = 0

        while index < data.bytesize
          start = data.index(START_BYTE.chr, index)
          break unless start

          finish = data.index(END_BYTE.chr, start + 1)
          break unless finish

          messages << Message.new(data.byteslice(start..finish))
          index = finish + 1
        end

        messages
      end

      def read_file(path)
        split(File.binread(path))
      end
    end
  end
end
