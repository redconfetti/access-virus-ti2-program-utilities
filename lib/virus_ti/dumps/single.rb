# frozen_string_literal: true

require_relative "../banks"
require_relative "../sysex/constants"
require_relative "../sysex/message"

module VirusTi
  module Dumps
    class Single
      attr_reader :message

      def self.parse(data)
        new(Sysex::Message.new(data))
      end

      def self.all_in(data)
        Sysex::Reader.split(data).filter_map do |message|
          next unless message.single_dump?

          new(message)
        end
      end

      def self.all_in_file(path)
        all_in(File.binread(path))
      end

      def initialize(message)
        @message = message
        validate!
      end

      def bank_byte = message.bank
      def slot_byte = message.slot

      def bank_label = Banks.label(bank_byte)
      def slot_label = Banks.slot_label(bank_byte, slot_byte)

      def name
        region = message.bytes.byteslice(
          Sysex::SINGLE_NAME_REGION_OFFSET,
          Sysex::SINGLE_NAME_REGION_LENGTH
        )
        best_name_from_region(region)
      end

      def checksum_valid?
        expected_checksum == actual_checksum
      end

      def actual_checksum
        message.bytes.getbyte(Sysex::SINGLE_DUMP_SIZE - 2)
      end

      def expected_checksum
        payload = message.bytes.byteslice(0x09..(Sysex::SINGLE_DUMP_SIZE - 3))
        sum = message.device_id +
              Sysex::CMD_SINGLE_DUMP +
              message.bank +
              message.slot +
              payload.bytes.sum
        sum & 0x7F
      end

      def to_h
        {
          bank: bank_byte,
          bank_label: bank_label,
          slot: slot_byte,
          slot_label: slot_label,
          name: name,
          checksum_valid: checksum_valid?
        }
      end

      private

      def validate!
        raise ArgumentError, "not a Virus TI Single Dump" unless message.virus_ti? && message.single_dump?
      end

      def best_name_from_region(raw)
        return nil unless raw

        runs = printable_runs(raw)
        return nil if runs.empty?

        text = runs.max_by { |run| name_score(run) }&.strip
        text&.sub(/\A[^A-Za-z0-9]+/, "")
      end

      def printable_runs(raw)
        runs = []
        current = +""

        raw.each_byte do |byte|
          if byte >= 0x20 && byte <= 0x7E
            current << byte.chr
          else
            runs << current.dup unless current.empty?
            current = +""
          end
        end

        runs << current unless current.empty?
        runs
      end

      def name_score(text)
        score = text.length
        score += 10 if text.match?(/\A[A-Za-z]/)
        score -= 5 if text.length <= 2
        score
      end
    end
  end
end
