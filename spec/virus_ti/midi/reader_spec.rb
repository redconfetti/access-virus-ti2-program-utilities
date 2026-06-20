# frozen_string_literal: true

require "spec_helper"
require "virus_ti"
require "virus_ti/midi/reader"

RSpec.describe VirusTi::MIDI::Reader do
  describe ".read_file" do
    context "with the OsTIrus redconfetti bank .mid fixture" do
      subject(:messages) { described_class.read_file(fixture_path("ostirus/banks/redconfetti.mid")) }

      it "parses 10 single dumps" do
        expect(messages.size).to eq(10)
        expect(messages).to all(be_virus_ti)
        expect(messages).to all(be_single_dump)
      end

      it "reconstructs 524-byte single dumps" do
        expect(messages).to all(have_attributes(size: VirusTi::Sysex::SINGLE_DUMP_SIZE))
      end

      it "reads bank and slot bytes for each program" do
        expect(messages.map(&:slot).uniq.size).to eq(10)
        expect(messages).to all(have_attributes(bank: 1))
        expect(messages.first.slot).to eq(0)
        expect(messages.last.slot).to eq(9)
      end
    end

    context "with the OsTIrus arkadia .mid fixture" do
      it "parses a single program dump" do
        messages = described_class.read_file(fixture_path("ostirus/programs/arkadia.mid"))

        expect(messages.size).to eq(1)
        expect(messages.first).to be_single_dump

        single = VirusTi::List.singles(fixture_path("ostirus/programs/arkadia.mid")).first
        expect(single.name).to eq("arkadia1")
      end
    end
  end
end

RSpec.describe VirusTi::List do
  describe ".singles" do
    it "lists programs from the OsTIrus redconfetti bank fixture" do
      singles = described_class.singles(fixture_path("ostirus/banks/redconfetti.mid"))

      expect(singles.size).to eq(10)
      expect(singles.first.bank_label).to eq("RAM A")
      expect(singles.first.slot_label).to eq("Program 1")
      expect(singles.first.name).to eq("treefrogJM")
      expect(singles.last.name).to eq("Dulcimer")
    end
  end
end
