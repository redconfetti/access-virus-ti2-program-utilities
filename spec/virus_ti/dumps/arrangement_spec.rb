# frozen_string_literal: true

require "spec_helper"
require "virus_ti"
require "virus_ti/dumps/arrangement"

RSpec.describe VirusTi::Dumps::Arrangement do
  describe ".from_file" do
    context "with the arcadia-arrangement .syx fixture" do
      subject(:arrangement) { described_class.from_file(fixture_path("ostirus/arrangements/arcadia-arrangement.syx")) }

      it "parses one multi and sixteen parts" do
        expect(arrangement.multi).to be_a(VirusTi::Dumps::Multi)
        expect(arrangement.parts.size).to eq(16)
      end

      it "reads the multi name" do
        expect(arrangement.name).to eq("Init Multi")
      end

      it "orders parts with edit-buffer slot bytes 0x00..0x0F" do
        expect(arrangement.parts.map(&:slot_byte)).to eq((0x0..0x0F).to_a)
      end

      it "reads embedded single names per part" do
        expect(arrangement.parts.map(&:name)).to eq(Fixtures::ARRANGEMENT_PART_NAMES)
      end

      it "labels parts 1 through 16" do
        expect(arrangement.parts.map(&:number)).to eq((1..16).to_a)
        expect(arrangement.parts.first.label).to eq("Part 1")
        expect(arrangement.parts.last.label).to eq("Part 16")
      end
    end

    context "with the multi-arrangement .syx fixture" do
      subject(:arrangement) { described_class.from_file(fixture_path("virus-ti2/arrangements/multi-arrangement.syx")) }

      it "parses one multi and sixteen parts" do
        expect(arrangement.multi).to be_a(VirusTi::Dumps::Multi)
        expect(arrangement.parts.size).to eq(16)
      end

      it "reads the multi name" do
        expect(arrangement.name).to eq("Init Multi")
      end

      it "reads embedded single names per part" do
        expect(arrangement.parts.map(&:name)).to eq(Fixtures::VIRUS_TI2_ARRANGEMENT_PART_NAMES)
      end
    end

    context "with the arcadia-arrangement .mid fixture" do
      it "matches the .syx export" do
        syx = described_class.from_file(fixture_path("ostirus/arrangements/arcadia-arrangement.syx"))
        mid = described_class.from_file(fixture_path("ostirus/arrangements/arcadia-arrangement.mid"))

        expect(mid.name).to eq(syx.name)
        expect(mid.parts.map(&:name)).to eq(syx.parts.map(&:name))
        expect(mid.parts.map(&:slot_byte)).to eq(syx.parts.map(&:slot_byte))
      end
    end
  end

  describe ".detect?" do
    it "returns true for the arrangement fixture message sequence" do
      messages = VirusTi::List.messages(fixture_path("ostirus/arrangements/arcadia-arrangement.syx"))

      expect(described_class.detect?(messages)).to be(true)
    end

    it "returns false for a single-program bank fixture" do
      messages = VirusTi::List.messages(fixture_path("ostirus/banks/redconfetti.syx"))

      expect(described_class.detect?(messages)).to be(false)
    end
  end

  describe "WIRE_SIZE" do
    it "matches the arcadia-arrangement .syx fixture size" do
      size = File.size(fixture_path("ostirus/arrangements/arcadia-arrangement.syx"))

      expect(size).to eq(described_class::WIRE_SIZE)
    end

    it "matches the multi-arrangement .syx fixture size" do
      size = File.size(fixture_path("virus-ti2/arrangements/multi-arrangement.syx"))

      expect(size).to eq(described_class::WIRE_SIZE)
    end
  end
end

RSpec.describe VirusTi::List do
  describe ".arrangement" do
    it "returns an arrangement for arrangement fixtures" do
      arrangement = described_class.arrangement(fixture_path("ostirus/arrangements/arcadia-arrangement.syx"))

      expect(arrangement).to be_a(VirusTi::Dumps::Arrangement)
    end

    it "returns nil for bank fixtures" do
      expect(described_class.arrangement(fixture_path("ostirus/banks/redconfetti.syx"))).to be_nil
    end
  end
end

RSpec.describe VirusTi::Scan do
  describe ".summarize" do
    it "counts arrangements in arrangement fixtures" do
      summary = described_class.summarize(fixture_path("ostirus/arrangements/arcadia-arrangement.syx"))

      expect(summary[:arrangements]).to eq(1)
      expect(summary[:multis]).to eq(1)
      expect(summary[:singles]).to eq(16)
      expect(summary[:arrangement]).to be(true)
    end
  end
end
