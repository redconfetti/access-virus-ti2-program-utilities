# frozen_string_literal: true

module VirusTi
  module Banks
    EDIT_BUFFER = :edit_buffer

    RAM_BANKS = ("A".."D").each_with_index.to_h { |letter, index| [index + 1, "RAM #{letter}"] }.freeze
    ROM_BANKS = ("A".."Z").each_with_index.to_h { |letter, index| [index + 5, "ROM #{letter}"] }.freeze

    STORED_BANKS = RAM_BANKS.merge(ROM_BANKS).freeze

    module_function

    def label(bank_byte)
      return "Edit buffer" if bank_byte.zero?

      STORED_BANKS[bank_byte] || format("Unknown bank (0x%02X)", bank_byte)
    end

    def slot_number(slot_byte)
      slot_byte + 1
    end

    def slot_label(bank_byte, slot_byte)
      if bank_byte.zero? && slot_byte == 0x40
        "Single edit buffer"
      elsif bank_byte.zero? && slot_byte <= 0x0F
        "Multi part #{slot_byte + 1}"
      elsif bank_byte.zero? && slot_byte == 0x7F
        "Edit buffer"
      else
        "Program #{slot_number(slot_byte)}"
      end
    end
  end
end
