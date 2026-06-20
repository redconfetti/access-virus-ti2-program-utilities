# frozen_string_literal: true

require "json"

module VirusTi
  module Parameters
    CATEGORY_ORDER = [
      "Osc/Mixer",
      "Filters",
      "Modulators",
      "Matrix",
      "Arpeggiator",
      "Effects",
      "Single"
    ].freeze

    module Registry
      MAP_PATH = File.expand_path("single_dump_map.json", __dir__)

      module_function

      def all
        @all ||= JSON.parse(File.read(MAP_PATH, encoding: "UTF-8"))
      end

      def grouped_by_category
        all.group_by { |entry| entry["category"] }
      end

      def values_for_single(single)
        bytes = single.message.bytes
        grouped = Hash.new { |hash, key| hash[key] = [] }

        all.each do |entry|
          offset = entry["offset"]
          raw = bytes.getbyte(offset)
          grouped[entry["category"]] << {
            name: entry["name"],
            panel: entry["panel"],
            offset: offset,
            raw: raw,
            hex: format("0x%02X", raw)
          }
        end

        CATEGORY_ORDER.filter_map do |category|
          next if grouped[category].empty?

          [category, grouped[category]]
        end
      end
    end
  end
end
