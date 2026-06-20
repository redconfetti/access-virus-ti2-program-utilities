# frozen_string_literal: true

require_relative "virus_ti/version"
require_relative "virus_ti/banks"
require_relative "virus_ti/sysex/constants"
require_relative "virus_ti/sysex/message"
require_relative "virus_ti/sysex/reader"
require_relative "virus_ti/dumps/single"
require_relative "virus_ti/dumps/multi"
require_relative "virus_ti/dumps/arrangement"
require_relative "virus_ti/midi/reader"
require_relative "virus_ti/file_reader"

module VirusTi
  module Scan
    module_function

    def summarize(path)
      messages = FileReader.read_messages(path)
      arrangement = arrangement?(messages)

      {
        path: path,
        message_count: messages.size,
        singles: messages.count(&:single_dump?),
        multis: messages.count(&:multi_dump?),
        arrangements: arrangement ? 1 : 0,
        virus_ti: messages.count(&:virus_ti?),
        commands: messages.group_by(&:command).transform_values(&:size),
        arrangement: arrangement
      }
    end

    def arrangement?(messages)
      Dumps::Arrangement.detect?(messages)
    end
  end

  module List
    module_function

    def messages(path)
      FileReader.read_messages(path)
    end

    def singles(path)
      messages(path).filter_map do |message|
        next unless message.single_dump?

        Dumps::Single.new(message)
      end
    end

    def multis(path)
      messages(path).filter_map do |message|
        next unless message.multi_dump?

        Dumps::Multi.new(message)
      end
    end

    def arrangement(path)
      msgs = messages(path)
      return nil unless Dumps::Arrangement.detect?(msgs)

      Dumps::Arrangement.parse(msgs)
    end
  end
end
