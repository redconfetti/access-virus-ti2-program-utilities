# frozen_string_literal: true

require_relative "../sysex/constants"
require_relative "../sysex/message"

module VirusTi
  module Dumps
    class Multi
      NAME_OFFSET = 0x0D
      NAME_LENGTH = 10

      attr_reader :message

      def self.parse(data)
        new(Sysex::Message.new(data))
      end

      def self.all_in(data)
        Sysex::Reader.split(data).filter_map do |message|
          next unless message.multi_dump?

          new(message)
        end
      end

      def initialize(message)
        @message = message
        validate!
      end

      def bank_byte = message.bank
      def slot_byte = message.slot

      def name
        raw = message.bytes.byteslice(NAME_OFFSET, NAME_LENGTH)
        raw&.bytes
          &.take_while { |byte| byte >= 0x20 && byte <= 0x7E }
          &.map(&:chr)
          &.join
          &.strip
      end

      def to_h
        {
          bank: bank_byte,
          slot: slot_byte,
          name: name
        }
      end

      private

      def validate!
        raise ArgumentError, "not a Virus TI Multi Dump" unless message.virus_ti? && message.multi_dump?
      end
    end
  end
end
