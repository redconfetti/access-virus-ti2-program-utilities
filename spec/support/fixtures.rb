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

  def arrangement_entries
    ENTRIES.select { |_relative, metadata| metadata[:kind] == :arrangement }
  end
end
