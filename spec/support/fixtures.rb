# frozen_string_literal: true

module Fixtures
  ROOT = File.expand_path("../fixtures", __dir__)

  ARRANGEMENT_PART_NAMES = [
    "Arkadia1-J",
    "Arcadia2-J",
    "treefrogJM",
    "acidfrogJM",
    "acidwaspJM",
    "Steel Drum",
    "Banjo",
    "Cello",
    "Dulcimer",
    "Acoustic",
    "Init -",
    "Init -",
    "Init -",
    "Init -",
    "Init -",
    "Init -"
  ].freeze

  VIRUS_TI2_ARRANGEMENT_PART_NAMES = [
    "Cello",
    "Acoustic",
    "Banjo",
    "Steel Drum",
    "Arkadia4",
    "INIT-",
    "INIT-",
    "INIT-",
    "INIT-",
    "INIT-",
    "INIT-",
    "INIT-",
    "INIT-",
    "INIT-",
    "INIT-",
    "INIT-"
  ].freeze

  ENTRIES = {
    "ostirus/banks/redconfetti.syx" => {
      source: :ostirus,
      format: :syx,
      kind: :bank,
      singles: 10,
      multis: 0,
      first: { bank: 1, slot: 0, name: "treefrogJM" },
      last: { bank: 1, slot: 9, name: "Dulcimer" }
    },
    "ostirus/banks/redconfetti.mid" => {
      source: :ostirus,
      format: :mid,
      kind: :bank,
      singles: 10,
      multis: 0,
      first: { bank: 1, slot: 0, name: "treefrogJM" },
      last: { bank: 1, slot: 9, name: "Dulcimer" }
    },
    "ostirus/arrangements/arcadia-arrangement.syx" => {
      source: :ostirus,
      format: :syx,
      kind: :arrangement,
      singles: 16,
      multis: 1,
      multi_name: "Init Multi",
      part_names: ARRANGEMENT_PART_NAMES
    },
    "ostirus/arrangements/arcadia-arrangement.mid" => {
      source: :ostirus,
      format: :mid,
      kind: :arrangement,
      singles: 16,
      multis: 1,
      multi_name: "Init Multi",
      part_names: ARRANGEMENT_PART_NAMES
    },
    "ostirus/programs/organ-stab.syx" => {
      source: :ostirus,
      format: :syx,
      kind: :single,
      singles: 1,
      multis: 0,
      first: { bank: 1, slot: 0, name: "Organ Stab" },
      checksum_valid: true
    },
    "ostirus/programs/arkadia.syx" => {
      source: :ostirus,
      format: :syx,
      kind: :single,
      singles: 1,
      multis: 0,
      first: { bank: 1, slot: 0, name: "arkadia1" }
    },
    "ostirus/programs/arkadia.mid" => {
      source: :ostirus,
      format: :mid,
      kind: :single,
      singles: 1,
      multis: 0,
      first: { bank: 1, slot: 0, name: "arkadia1" }
    },
    "virus-ti2/programs/DulcimerJM.syx" => {
      source: :virus_ti2,
      format: :syx,
      kind: :single,
      singles: 1,
      multis: 0,
      first: { bank: 0, slot: 0x7F, name: "Dulcimer" },
      checksum_valid: true
    },
    "virus-ti2/programs/SteelDrumJM.syx" => {
      source: :virus_ti2,
      format: :syx,
      kind: :single,
      singles: 1,
      multis: 0,
      first: { bank: 0, slot: 0x7F, name: "Steel Drum" },
      checksum_valid: true
    },
    "virus-ti2/banks/full-bank.syx" => {
      source: :virus_ti2,
      format: :syx,
      kind: :bank,
      singles: 128,
      multis: 0,
      first: { bank: 1, slot: 0, name: "arkadia1" },
      last: { bank: 1, slot: 0x7F, name: "" }
    },
    "virus-ti2/multis-bank/multis-dump.syx" => {
      source: :virus_ti2,
      format: :syx,
      kind: :multis_bank,
      singles: 256,
      multis: 128,
      first_single: { bank: 0x20, slot: 0, name: "DarkliteSV" },
      first_multi: { bank: 0x32, slot: 0, name: "Redcon1" }
    },
    "virus-ti2/arrangements/multi-arrangement.syx" => {
      source: :virus_ti2,
      format: :syx,
      kind: :arrangement,
      singles: 16,
      multis: 1,
      multi_name: "Init Multi",
      part_names: VIRUS_TI2_ARRANGEMENT_PART_NAMES
    }
  }.freeze

  module_function

  def path(relative)
    full = File.join(ROOT, relative)
    raise ArgumentError, "unknown fixture: #{relative}" unless ENTRIES.key?(relative)
    raise ArgumentError, "fixture file missing: #{relative}" unless File.file?(full)

    full
  end

  def each_entry
    ENTRIES.each do |relative, metadata|
      yield relative, metadata, path(relative)
    end
  end

  def by_source(source)
    ENTRIES.select { |_relative, metadata| metadata[:source] == source }
  end

  def by_format(format)
    ENTRIES.select { |_relative, metadata| metadata[:format] == format }
  end

  def bank_entries
    ENTRIES.select { |_relative, metadata| metadata[:kind] == :bank }
  end

  def multis_bank_entries
    ENTRIES.select { |_relative, metadata| metadata[:kind] == :multis_bank }
  end

  def arrangement_entries
    ENTRIES.select { |_relative, metadata| metadata[:kind] == :arrangement }
  end
end
