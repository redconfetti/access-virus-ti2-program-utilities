# frozen_string_literal: true

require_relative "../file_reader"
require_relative "../sysex/constants"
require_relative "multi"
require_relative "single"

module VirusTi
  module Dumps
    class Arrangement
      MULTI_COUNT = 1
      PART_COUNT = 16
      MESSAGE_COUNT = MULTI_COUNT + PART_COUNT
      WIRE_SIZE = Sysex::MULTI_DUMP_SIZE + (PART_COUNT * Sysex::SINGLE_DUMP_SIZE)

      attr_reader :messages, :multi, :parts

      def self.detect?(messages)
        return false unless messages.size == MESSAGE_COUNT
        return false unless messages.first.multi_dump?
        return false unless messages[1..].all?(&:single_dump?)

        messages[1..].each_with_index.all? do |message, index|
          message.bank.zero? && message.slot == index
        end
      end

      def self.parse(messages)
        new(messages)
      end

      def self.from_file(path)
        messages = FileReader.read_messages(path)
        parse(messages)
      end

      def initialize(messages)
        @messages = messages
        validate!
        @multi = Multi.new(messages.first)
        @parts = messages[1..].map.with_index do |message, index|
          Part.new(index + 1, Single.new(message))
        end
      end

      def name
        multi.name
      end

      def to_h
        {
          name: name,
          multi: multi.to_h,
          parts: parts.map(&:to_h)
        }
      end

      private

      def validate!
        raise ArgumentError, "not a Virus TI arrangement export" unless self.class.detect?(messages)
      end

      class Part
        attr_reader :number, :single

        def initialize(number, single)
          @number = number
          @single = single
        end

        def name = single.name
        def slot_byte = single.slot_byte

        def label
          "Part #{number}"
        end

        def to_h
          {
            part: number,
            slot: slot_byte,
            name: name
          }
        end
      end
    end
  end
end
