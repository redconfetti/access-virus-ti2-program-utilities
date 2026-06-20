# frozen_string_literal: true

require_relative "constants"

module VirusTi
  module Sysex
    class Message
      attr_reader :bytes

      def initialize(bytes)
        @bytes = bytes.b
      end

      def size = bytes.bytesize

      def start_byte = bytes.getbyte(0)
      def end_byte = bytes.getbyte(-1)

      def manufacturer_id = bytes.byteslice(1, 3)&.bytes || []
      def family = bytes.getbyte(4)
      def device_id = bytes.getbyte(5)
      def command = bytes.getbyte(6)
      def bank = bytes.getbyte(7)
      def slot = bytes.getbyte(8)

      def virus_ti?
        start_byte == START_BYTE &&
          end_byte == END_BYTE &&
          manufacturer_id == MANUFACTURER_ID &&
          family == FAMILY_TI
      end

      def single_dump? = command == CMD_SINGLE_DUMP && size == SINGLE_DUMP_SIZE
      def multi_dump? = command == CMD_MULTI_DUMP && size == MULTI_DUMP_SIZE

      def command_name
        case command
        when CMD_SINGLE_DUMP then "Single Dump"
        when CMD_MULTI_DUMP then "Multi Dump"
        else format("Unknown (0x%02X)", command)
        end
      end
    end
  end
end
