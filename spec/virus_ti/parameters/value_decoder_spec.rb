# frozen_string_literal: true

require "spec_helper"
require "virus_ti/parameters/value_decoder"

RSpec.describe VirusTi::Parameters::ValueDecoder do
  describe ".decode" do
    it "decodes bipolar values" do
      expect(described_class.decode(0x40, { "type" => "bipolar" })).to eq("+0")
      expect(described_class.decode(0x00, { "type" => "bipolar" })).to eq("-64")
      expect(described_class.decode(0x7F, { "type" => "bipolar" })).to eq("+63")
    end

    it "decodes key follow with Norm label" do
      expect(described_class.decode(0x60, { "type" => "key_follow" })).to eq("Norm")
      expect(described_class.decode(0x40, { "type" => "key_follow" })).to eq("+0")
    end

    it "decodes percent bipolar values" do
      expect(described_class.decode(0x40, { "type" => "percent_bipolar" })).to eq("+0.0%")
      expect(described_class.decode(0x55, { "type" => "percent_bipolar" })).to eq("+32.8%")
    end

    it "decodes classic pulse width" do
      expect(described_class.decode(0x00, { "type" => "classic_pulse_width" })).to eq("+50.0%")
      expect(described_class.decode(0x7F, { "type" => "classic_pulse_width" })).to eq("+100.0%")
    end

    it "decodes inline enums" do
      encoding = { "type" => "enum", "values" => { "00" => "Square", "01" => "Triangle" } }

      expect(described_class.decode(0x00, encoding)).to eq("Square")
      expect(described_class.decode(0x01, encoding)).to eq("Triangle")
    end

    it "decodes option references" do
      encoding = { "type" => "enum", "ref" => "arpeggiator-mode" }

      expect(described_class.decode(0x00, encoding)).to eq("Off")
      expect(described_class.decode(0x01, encoding)).to eq("Up")
    end

    it "decodes direct off values" do
      expect(described_class.decode(0x00, { "type" => "direct_off" })).to eq("Off")
      expect(described_class.decode(0x40, { "type" => "direct_off" })).to eq("64")
    end

    it "decodes mod matrix destinations from the assign-target wire map" do
      encoding = {
        "type" => "enum",
        "ref" => "lfo-1-destination",
        "subsection" => "assign-target"
      }

      expect(described_class.decode(0x00, encoding)).to eq("Off")
      expect(described_class.decode(0x03, encoding)).to eq("Panorama")
      expect(described_class.decode(0x18, encoding)).to eq("Filter 1 Cutoff")
      expect(described_class.decode(0x40, encoding)).to eq("Chorus Mod Depth")
    end

    it "decodes mod matrix amounts as bipolar values" do
      expect(described_class.decode(0x00, { "type" => "bipolar" })).to eq("-64")
      expect(described_class.decode(0x40, { "type" => "bipolar" })).to eq("+0")
      expect(described_class.decode(0x7F, { "type" => "bipolar" })).to eq("+63")
    end
  end
end
