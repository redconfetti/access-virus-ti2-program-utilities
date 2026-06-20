# frozen_string_literal: true

require "spec_helper"
require "virus_ti/sysex/reader"

RSpec.describe VirusTi::Sysex::Reader do
  describe ".read_file" do
    it "finds a single dump in the organ-stab .syx fixture" do
      messages = described_class.read_file(fixture_path("ostirus/programs/organ-stab.syx"))

      expect(messages.size).to eq(1)
      expect(messages.first).to be_virus_ti
      expect(messages.first).to be_single_dump
    end
  end

  describe ".split" do
    it "handles concatenated messages" do
      payload = fixture_bytes("ostirus/programs/organ-stab.syx")
      messages = described_class.split(payload + payload)

      expect(messages.size).to eq(2)
    end
  end
end
