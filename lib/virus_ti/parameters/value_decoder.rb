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

      COMB_NOTE_NAMES = begin
        names = []
        note_names = %w[C C# D D# E F F# G G# A A# B]
        octave = 0
        while names.size <= 0x60
          note_names.each do |note|
            names << "#{note}#{octave}"
            break if names.size > 0x60
          end
          octave += 1
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
        when "strict_enum" then strict_enum_lookup(stored, encoding)
        when "sparse_enum" then sparse_enum_lookup(stored, encoding)
        when "shared_dump" then decode_shared_dump(stored, encoding)
        when "lfo_shape" then lfo_shape(stored)
        when "enum_index" then enum_index_lookup(stored, encoding)
        when "mod_matrix_source" then decode_mod_matrix_source(stored, encoding)
        when "note_c1_g9" then NOTE_NAMES[stored] || stored.to_s
        when "level_off" then level_off(stored)
        when "trigger_phase" then trigger_phase(stored)
        when "lcd_anchors" then decode_lcd_anchors(stored, encoding)
        when "comb_frequency" then comb_frequency(stored)
        else direct(stored)
        end
      end

      def direct(stored)
        stored.to_s
      end

      def level_off(stored)
        stored.zero? ? "Off" : stored.to_s
      end

      def trigger_phase(stored)
        stored.zero? ? "Off" : stored.to_s
      end

      def comb_frequency(stored)
        if stored <= 0x60
          COMB_NOTE_NAMES[stored] || wire_key(stored)
        else
          "#{stored} (above panel C8)"
        end
      end

      def format_signed(value)
        format("%+d", value)
      end

      def key_follow(stored)
        return "Norm" if stored == 0x60

        format_signed(stored - 64)
      end

      def format_percent(value)
        format("%+.1f%%", value)
      end

      def decode_lcd_anchors(stored, encoding)
        anchors = resolve_option_values(encoding["ref"], encoding["subsection"])
        return direct(stored) unless anchors&.any?

        key = wire_key(stored)
        return anchors[key] if anchors[key]

        numeric = interpolate_lcd_anchors(stored, anchors)
        numeric || unknown_label(stored)
      end

      def interpolate_lcd_anchors(stored, anchors)
        points = anchors.filter_map do |wire, label|
          value = wire.to_i(16)
          number = label[/[-+]?\d+(?:\.\d+)?/]
          next unless number

          [value, number.to_f, label]
        end.sort_by(&:first)

        return nil if points.size < 2

        lower = points.select { |value, _, _| value <= stored }.last
        upper = points.find { |value, _, _| value >= stored }

        if lower && upper && lower.first == upper.first
          return format_lcd_label(lower[2], lower[1])
        end

        if lower && upper
          ratio = (stored - lower.first).to_f / (upper.first - lower.first)
          interpolated = lower[1] + ((upper[1] - lower[1]) * ratio)
          return format_interpolated(interpolated, lower[2], upper[2])
        end

        format_lcd_label(points.first[2], points.first[1]) if stored < points.first.first
        format_lcd_label(points.last[2], points.last[1]) if stored > points.last.first
      end

      def format_lcd_label(label, _number)
        label
      end

      def format_interpolated(value, lower_label, upper_label)
        unit = lower_label[/[%°cm]+/] || upper_label[/[%°cm]+/] || ""
        if unit.include?("°")
          format("%+.0f°", value)
        elsif unit.include?("cm")
          format("%.1f cm", value)
        elsif unit.include?("%")
          format("%+.1f%%", value)
        else
          format("%.1f", value)
        end
      end

      def strict_enum_lookup(stored, encoding)
        label = enum_lookup(stored, encoding)
        return label unless label.start_with?("Unknown")

        "Invalid (#{wire_key(stored)})"
      end

      def sparse_enum_lookup(stored, encoding)
        label = enum_lookup(stored, encoding)
        return label unless label.start_with?("Unknown")

        fallback = encoding["fallback"]
        fallback ? decode(stored, fallback) : label
      end

      def decode_shared_dump(stored, encoding)
        primary = decode(stored, encoding["primary"])
        return primary unless primary.start_with?("Unknown")

        shared = decode(stored, encoding["fallback"])
        "#{encoding['fallback_label']}: #{shared}"
      end

      def lfo_shape(stored)
        values = options.dig("lfo-shape", "values")
        return values[wire_key(stored)] if values&.dig(wire_key(stored))

        if stored.between?(0x06, 0x43)
          "Wave #{stored - 3}"
        else
          unknown_label(stored)
        end
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

      def decode_mod_matrix_source(stored, encoding)
        source = enum_lookup(stored, { "type" => "enum", "ref" => encoding["ref"] })
        return source unless invalid_source_wire?(stored, source)

        overlap = encoding["overlap"]
        if overlap
          shared = decode(stored, overlap["encoding"])
          return "#{overlap["label"]}: #{shared}"
        end

        invalid_source_wire_label(stored)
      end

      def invalid_source_wire?(stored, decoded)
        decoded.start_with?("Unknown") || stored > MAX_MOD_MATRIX_SOURCE_WIRE
      end

      def invalid_source_wire_label(stored)
        "Invalid source wire (#{wire_key(stored)})"
      end

      MAX_MOD_MATRIX_SOURCE_WIRE = 0x27
      private_constant :MAX_MOD_MATRIX_SOURCE_WIRE

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
