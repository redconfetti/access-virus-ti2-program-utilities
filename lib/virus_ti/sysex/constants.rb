# frozen_string_literal: true

module VirusTi
  module Sysex
    START_BYTE = 0xF0
    END_BYTE = 0xF7

    MANUFACTURER_ID = [0x00, 0x20, 0x33].freeze
    FAMILY_TI = 0x01

    CMD_SINGLE_DUMP = 0x10
    CMD_MULTI_DUMP = 0x11

    SINGLE_DUMP_SIZE = 524
    MULTI_DUMP_SIZE = 267

    SINGLE_NAME_REGION_OFFSET = 0xF8
    SINGLE_NAME_REGION_LENGTH = 24
  end
end
