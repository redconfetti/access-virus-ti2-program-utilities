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
require_relative "virus_ti/parameters/encoding_refs"
require_relative "virus_ti/parameters/value_decoder"
require_relative "virus_ti/parameters/registry"
require_relative "virus_ti/output/formatter"
require_relative "virus_ti/show"

module VirusTi
  module Scan
    module_function

    def summarize(path)
      messages = FileReader.read_messages(path)
      arrangement = arrangement?(messages)
      singles = messages.count(&:single_dump?)
      multis = messages.count(&:multi_dump?)

      {
        path: path,
        message_count: messages.size,
        singles: singles,
        multis: multis,
        arrangements: arrangement ? 1 : 0,
        virus_ti: messages.count(&:virus_ti?),
        commands: messages.group_by(&:command).transform_values(&:size),
        arrangement: arrangement,
        file_type: classify_file_type(arrangement: arrangement, singles: singles, multis: multis)
      }
    end

    def classify_file_type(arrangement:, singles:, multis:)
      return :arrangement if arrangement
      return :multis_bank if multis.positive? && singles > 1
      return :bank if singles > 1
      return :single if singles == 1

      :other
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
