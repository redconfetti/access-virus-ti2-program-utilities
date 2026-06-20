# frozen_string_literal: true

require "json"

module VirusTi
  module Parameters
    module ValueDecoder
      OPTIONS_PATH = File.expand_path("parameter_options.json", __dir__)

      NOTE_NAMES = begin
        names = []
        notes = %w[C C# D D# E F F# G G# A A# B]
        (1..9).each do |octave|
          notes.each do |note|
            names << "#{note}#{octave}"
            break if names.size >= 128
          end
          break if names.size >= 128
        end
        names
      end.freeze

      module_function

      def options
        @options ||= JSON.parse(File.read(OPTIONS_PATH, encoding: "UTF-8"))
      end

      def decode(raw, encoding)
        return "" if raw.nil?

        stored = raw & 0x7F
        type = encoding.is_a?(Hash) ? encoding["type"] : encoding

        case type
        when "direct" then direct(stored)
        when "direct_off" then stored.zero? ? "Off" : stored.to_s
        when "bipolar" then format_signed(stored - 64)
        when "bipolar_narrow" then format_signed(stored - 64)
        when "key_follow" then key_follow(stored)
        when "percent_bipolar" then format_percent((stored - 64) * 100.0 / 64.0)
        when "classic_pulse_width" then format_percent(50.0 + (stored * 50.0 / 127.0))
        when "hypersaw_density" then format("%.1f", 1.0 + (stored * 8.0 / 127.0))
        when "enum" then enum_lookup(stored, encoding)
        when "enum_index" then enum_index_lookup(stored, encoding)
        when "note_c1_g9" then NOTE_NAMES[stored] || stored.to_s
        else direct(stored)
        end
      end

      def direct(stored)
        stored.to_s
      end

      def format_signed(value)
        return "Norm" if value == 32 # only used when key_follow misses

        format("%+d", value)
      end

      def key_follow(stored)
        return "Norm" if stored == 0x60

        format_signed(stored - 64)
      end

      def format_percent(value)
        format("%+.1f%%", value)
      end

      def enum_lookup(stored, encoding)
        if encoding["values"].is_a?(Hash) && !encoding["values"].empty?
          return encoding["values"][wire_key(stored)] || unknown_label(stored)
        end

        values = resolve_option_values(encoding["ref"], encoding["subsection"])
        return values[wire_key(stored)] || unknown_label(stored) if values&.any?

        wire_key(stored)
      end

      def resolve_option_values(ref, subsection = nil)
        return nil unless ref

        if subsection
          values = options.dig(ref, "subsections", subsection, "values")
          return values if values&.any?
        end

        section = options[ref]
        if section&.dig("values")&.any?
          return section["values"]
        end

        options.each_value do |candidate|
          candidate.fetch("subsections", {}).each do |slug, sub|
            next unless slug == ref || slug.start_with?("#{ref}-") || ref.start_with?("#{slug.split("-").first(2).join("-")}")

            return sub["values"] if sub["values"]&.any?
          end
        end

        nil
      end

      def unknown_label(stored)
        "Unknown (#{wire_key(stored)})"
      end

      def enum_index_lookup(stored, encoding)
        enum_lookup(stored, encoding.merge("values" => index_values(encoding)))
      end

      def index_values(_encoding)
        @index_values ||= (0..127).each_with_object({}) do |index, hash|
          hash[wire_key(index)] = index.to_s
        end
      end

      def wire_key(stored)
        format("%02X", stored & 0x7F)
      end
    end
  end
end
