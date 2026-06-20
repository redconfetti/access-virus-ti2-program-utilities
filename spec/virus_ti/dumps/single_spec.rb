# frozen_string_literal: true

require "spec_helper"
require "virus_ti/dumps/single"

RSpec.describe VirusTi::Dumps::Single do
  subject(:single) do
    described_class.all_in(fixture_bytes("ostirus/programs/organ-stab.syx")).first
  end

  it "parses the organ-stab fixture" do
    expect(single).to be_a(described_class)
  end

  it "reads bank and slot" do
    expect(single.bank_byte).to eq(1)
    expect(single.bank_label).to eq("RAM A")
    expect(single.slot_byte).to eq(0)
    expect(single.slot_label).to eq("Program 1")
  end

  it "reads the patch name" do
    expect(single.name).to eq("Organ Stab")
  end

  it "validates the checksum" do
    expect(single).to be_checksum_valid
  end

  describe ".all_in_file" do
    it "finds one single in the fixture file" do
      singles = described_class.all_in_file(fixture_path("ostirus/programs/organ-stab.syx"))

      expect(singles.size).to eq(1)
    end
  end
end
