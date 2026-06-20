# frozen_string_literal: true

require "spec_helper"
require "virus_ti/banks"

RSpec.describe VirusTi::Banks do
  describe ".label" do
    it "maps RAM bank bytes" do
      expect(described_class.label(1)).to eq("RAM A")
      expect(described_class.label(4)).to eq("RAM D")
    end

    it "maps ROM bank bytes" do
      expect(described_class.label(5)).to eq("ROM A")
      expect(described_class.label(0x1E)).to eq("ROM Z")
    end

    it "labels the edit buffer" do
      expect(described_class.label(0)).to eq("Edit buffer")
    end

    it "maps singles export bank bytes from hardware dumps" do
      expect(described_class.label(0x20)).to eq("Singles bank 1")
      expect(described_class.label(0x2F)).to eq("Singles bank 16")
    end

    it "maps multi RAM bank bytes from hardware dumps" do
      expect(described_class.label(0x32)).to eq("Multi RAM A")
    end
  end

  describe ".slot_label" do
    it "labels the single edit buffer slot" do
      expect(described_class.slot_label(0, 0x7F)).to eq("Single edit buffer")
    end
  end

  describe ".slot_number" do
    it "converts zero-based slot bytes to program numbers" do
      expect(described_class.slot_number(0)).to eq(1)
      expect(described_class.slot_number(0x40)).to eq(65)
    end
  end
end
