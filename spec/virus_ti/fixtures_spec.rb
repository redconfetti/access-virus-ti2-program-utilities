# frozen_string_literal: true

require "spec_helper"
require "virus_ti"

RSpec.describe "fixtures" do
  it "each registered fixture is readable" do
    Fixtures.each_entry do |relative, _metadata, full_path|
      expect(File.file?(full_path)).to be(true), "missing fixture file: #{relative}"
      expect(File.size(full_path)).to be > 0
    end
  end

  it "all fixtures yield Virus TI single or multi dumps" do
    Fixtures.each_entry do |relative, metadata, full_path|
      messages = VirusTi::FileReader.read_messages(full_path)

      expect(messages.size).to be >= 1
      expect(messages).to all(be_virus_ti)

      singles = messages.count(&:single_dump?)
      multis = messages.count(&:multi_dump?)

      expect(singles).to eq(metadata[:singles]), "#{relative} single count"
      expect(multis).to eq(metadata[:multis]), "#{relative} multi count"
    end
  end

  it "all fixtures list expected program metadata" do
    Fixtures.each_entry do |relative, metadata, full_path|
      case metadata[:kind]
      when :arrangement
        arrangement = VirusTi::List.arrangement(full_path)

        expect(arrangement.name).to eq(metadata[:multi_name]), "#{relative} multi name"
        expect(arrangement.parts.map(&:name)).to eq(metadata[:part_names]), "#{relative} part names"
      else
        singles = VirusTi::List.singles(full_path)
        first = singles.first
        expected = metadata[:first]

        expect(first.bank_byte).to eq(expected[:bank]), "#{relative} bank"
        expect(first.slot_byte).to eq(expected[:slot]), "#{relative} slot"
        expect(first.name).to eq(expected[:name]), "#{relative} name"
      end
    end
  end

  it "OsTIrus arcadia arrangement .syx and .mid exports match" do
    syx = VirusTi::List.arrangement(fixture_path("ostirus/arrangements/arcadia-arrangement.syx"))
    mid = VirusTi::List.arrangement(fixture_path("ostirus/arrangements/arcadia-arrangement.mid"))

    expect(mid.name).to eq(syx.name)
    expect(mid.parts.map(&:name)).to eq(syx.parts.map(&:name))
  end

  it "arrangement fixtures are detected as arrangements" do
    Fixtures.arrangement_entries.each do |relative, _metadata|
      expect(VirusTi::Scan.summarize(fixture_path(relative))[:arrangements]).to eq(1), relative
    end
  end

  it "OsTIrus arkadia .syx and .mid exports match" do
    syx = VirusTi::List.singles(fixture_path("ostirus/programs/arkadia.syx")).first
    mid = VirusTi::List.singles(fixture_path("ostirus/programs/arkadia.mid")).first

    expect(mid.bank_byte).to eq(syx.bank_byte)
    expect(mid.slot_byte).to eq(syx.slot_byte)
    expect(mid.name).to eq(syx.name)
  end

  it "OsTIrus redconfetti bank .syx and .mid exports match" do
    syx = VirusTi::List.singles(fixture_path("ostirus/banks/redconfetti.syx"))
    mid = VirusTi::List.singles(fixture_path("ostirus/banks/redconfetti.mid"))

    expect(mid.size).to eq(syx.size)
    mid.zip(syx).each do |mid_single, syx_single|
      expect(mid_single.bank_byte).to eq(syx_single.bank_byte)
      expect(mid_single.slot_byte).to eq(syx_single.slot_byte)
      expect(mid_single.name).to eq(syx_single.name)
    end
  end

  it "bank fixtures contain the expected number of programs" do
    Fixtures.bank_entries.each do |relative, metadata|
      singles = VirusTi::List.singles(fixture_path(relative))

      expect(singles.size).to eq(metadata[:singles]), relative
      expect(singles.map(&:slot_byte).uniq.size).to eq(metadata[:singles]), "#{relative} unique slots"
    end
  end

  it "checksum expectations when specified" do
    Fixtures.each_entry do |relative, metadata, full_path|
      singles = VirusTi::List.singles(full_path)

      if metadata.key?(:checksum_valid)
        expect(singles.first.checksum_valid?).to eq(metadata[:checksum_valid]), relative
      end

      next unless metadata.key?(:checksum_valid_count)

      valid = singles.count(&:checksum_valid?)
      expect(valid).to eq(metadata[:checksum_valid_count]), "#{relative} checksum count"
    end
  end
end
