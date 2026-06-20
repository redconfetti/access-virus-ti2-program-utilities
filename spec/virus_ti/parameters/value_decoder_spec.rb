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

    it "decodes mod matrix sources from the wire map" do
      encoding = { "type" => "mod_matrix_source", "ref" => "mod-matrix-sources" }

      expect(described_class.decode(0x00, encoding)).to eq("Off")
      expect(described_class.decode(0x15, encoding)).to eq("LFO 1 bipolar")
      expect(described_class.decode(0x03, encoding)).to eq("Mod Wheel")
    end

    it "decodes shared dump bytes for matrix slot 2 and 3 sources" do
      slot2 = {
        "type" => "mod_matrix_source",
        "ref" => "mod-matrix-sources",
        "overlap" => { "label" => "LFO 1 Rate", "encoding" => { "type" => "direct" } }
      }
      slot3 = {
        "type" => "mod_matrix_source",
        "ref" => "mod-matrix-sources",
        "overlap" => { "label" => "LFO 1 Keyfollow", "encoding" => { "type" => "key_follow" } }
      }

      expect(described_class.decode(0x64, slot2)).to eq("LFO 1 Rate: 100")
      expect(described_class.decode(0x40, slot3)).to eq("LFO 1 Keyfollow: +0")
    end

    it "decodes level off values" do
      expect(described_class.decode(0x00, { "type" => "level_off" })).to eq("Off")
      expect(described_class.decode(0x03, { "type" => "level_off" })).to eq("3")
    end

    it "decodes comb filter frequency notes" do
      expect(described_class.decode(0x00, { "type" => "comb_frequency" })).to eq("C0")
      expect(described_class.decode(0x7F, { "type" => "comb_frequency" })).to eq("127 (above panel C8)")
    end

    it "interpolates lcd anchor values" do
      encoding = { "type" => "lcd_anchors", "ref" => "chorus-rotary-mic-angle-lcd" }

      expect(described_class.decode(0x40, encoding)).to eq("+0°")
      expect(described_class.decode(0x10, encoding)).to match(/°/)
    end

    it "decodes spectral lfo shapes by wave number" do
      expect(described_class.decode(0x30, { "type" => "lfo_shape" })).to eq("Wave 45")
      expect(described_class.decode(0x00, { "type" => "lfo_shape" })).to eq("Sine")
    end

    it "decodes shared dump bytes for lfo mode" do
      encoding = {
        "type" => "shared_dump",
        "primary" => {
          "type" => "enum",
          "ref" => "lfo-settings",
          "subsection" => "mode-0x46-lfo-3-0x09"
        },
        "fallback" => {
          "type" => "enum",
          "ref" => "lfo-1-destination",
          "subsection" => "assign-target"
        },
        "fallback_label" => "Mod Matrix destination"
      }

      expect(described_class.decode(0x00, encoding)).to eq("Poly")
      expect(described_class.decode(0x40, encoding)).to eq("Mod Matrix destination: Chorus Mod Depth")
    end

    it "falls back to direct values for sparse arpeggiator resolution bytes" do
      encoding = {
        "type" => "sparse_enum",
        "ref" => "arpeggiator-resolution",
        "fallback" => { "type" => "direct" }
      }

      expect(described_class.decode(0x06, encoding)).to eq("1/4")
      expect(described_class.decode(0x39, encoding)).to eq("57")
    end

    it "labels invalid bender scale wire bytes" do
      encoding = { "type" => "strict_enum", "ref" => "bender-scale" }

      expect(described_class.decode(0x00, encoding)).to eq("Linear")
      expect(described_class.decode(0x3E, encoding)).to eq("Invalid (3E)")
    end

    it "decodes chorus feedback as bipolar percent" do
      encoding = { "type" => "percent_bipolar_64" }

      expect(described_class.decode(0x00, encoding)).to eq("-100.0%")
      expect(described_class.decode(0x40, encoding)).to eq("+0.0%")
      expect(described_class.decode(0x7F, encoding)).to eq("+100.0%")
    end

    it "labels invalid mod matrix source wire bytes" do
      encoding = { "type" => "mod_matrix_source", "ref" => "mod-matrix-sources" }

      expect(described_class.decode(0x40, encoding)).to eq("Invalid source wire (40)")
    end
  end
end
