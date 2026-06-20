# frozen_string_literal: true

require_relative "parameters/registry"

module VirusTi
  module Show
    Selection = Data.define(:label, :single, :context)

    module_function

    def build(path, slot:)
      if (arrangement = List.arrangement(path))
        select_from_arrangement(path, arrangement, slot)
      else
        select_from_singles(path, slot)
      end
    end

    def parameter_groups(selection)
      Parameters::Registry.values_for_single(selection.single)
    end

    def select_from_arrangement(path, arrangement, slot)
      validate_slot!(slot, arrangement.parts.size, "part", path)

      part = arrangement.parts[slot - 1]
      Selection.new(
        label: "Part #{part.number}: #{part.name || "(unnamed)"}",
        single: part.single,
        context: :arrangement
      )
    end

    def select_from_singles(path, slot)
      singles = List.singles(path)
      raise ArgumentError, "no single programs found in #{path}" if singles.empty?

      validate_slot!(slot, singles.size, "program", path)

      single = singles[slot - 1]
      Selection.new(
        label: "#{single.bank_label} #{single.slot_label}: #{single.name || "(unnamed)"}",
        single: single,
        context: singles.size == 1 ? :single : :bank
      )
    end

    def validate_slot!(slot, count, noun, path)
      raise ArgumentError, "--slot is required" if slot.nil?
      raise ArgumentError, "--slot must be between 1 and #{count} for #{path}" unless slot.between?(1, count)
    end
  end
end
