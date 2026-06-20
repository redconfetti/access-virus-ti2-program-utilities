# frozen_string_literal: true

module VirusTi
  module Parameters
    # Maps parameter-options.md anchor refs to wire decoders.
    # See: https://github.com/redconfetti/access-virus-ti-sysex/blob/main/docs/reference/parameter-options.md
    module EncodingRefs
      ASSIGN_TARGET = {
        "type" => "enum",
        "ref" => "lfo-1-destination",
        "subsection" => "assign-target"
      }.freeze

      REFS = {
        "lfo-rate" => { "type" => "direct" },
        "key-follow-0x48" => { "type" => "key_follow" },
        "contour" => { "type" => "bipolar" },
        "mode-0x46" => {
          "type" => "shared_dump",
          "primary" => { "type" => "enum", "ref" => "lfo-settings", "subsection" => "mode-0x46-lfo-3-0x09" },
          "fallback" => ASSIGN_TARGET,
          "fallback_label" => "Mod Matrix destination"
        },
        "envelope-mode" => { "type" => "enum", "ref" => "lfo-settings", "subsection" => "envelope-mode" },
        "trigger-phase" => { "type" => "trigger_phase" },
        "lfo-shape" => { "type" => "lfo_shape" },
        "lfo-clock" => { "type" => "enum", "ref" => "lfo-clock" },
        "mod-matrix-sources" => { "type" => "enum", "ref" => "mod-matrix-sources" },
        "mod-matrix-amount" => { "type" => "bipolar" },
        "mod-matrix-destinations" => ASSIGN_TARGET,
        "assign-target" => ASSIGN_TARGET,
        "phaser-mix-lcd" => { "type" => "level_off" },
        "chorus-rotary-mic-angle-lcd" => { "type" => "lcd_anchors", "ref" => "chorus-rotary-mic-angle-lcd" },
        "chorus-rotary-distance-lcd" => { "type" => "lcd_anchors", "ref" => "chorus-rotary-distance-lcd" },
        "chorus-rotary-lowhigh-balance-lcd" => { "type" => "percent_bipolar" },
        "chorus-amount-lcd" => { "type" => "percent_bipolar" },
        "filter-bank-comb-frequency" => { "type" => "comb_frequency" },
        "filter-bank-frequency-direct" => { "type" => "direct" },
        "filter-bank-resonance-lcd" => { "type" => "percent_bipolar" },
        "filter-bank-mix-lcd" => { "type" => "percent_bipolar" },
        "character-intensity-lcd" => { "type" => "percent_bipolar" },
        "arpeggiator-note-length-lcd" => { "type" => "percent_bipolar" },
        "arpeggiator-swing-factor-lcd" => { "type" => "percent_bipolar" },
        "arpeggiator-resolution" => {
          "type" => "sparse_enum",
          "ref" => "arpeggiator-resolution",
          "fallback" => { "type" => "direct" }
        },
        "delay-send-lcd" => { "type" => "enum", "ref" => "delay-send-lcd" },
        "reverb-send-lcd" => { "type" => "enum", "ref" => "reverb-send-lcd" },
        "edit-single-panorama-lcd" => { "type" => "percent_bipolar" },
        "bender-scale" => { "type" => "strict_enum", "ref" => "bender-scale" },
        "patch-name-categories" => { "type" => "enum", "ref" => "patch-name-categories" },
        "wavetable-names" => { "type" => "enum", "ref" => "wavetable-names" },
        "filter-1-mode" => {
          "type" => "enum",
          "values" => {
            "00" => "Low Pass",
            "01" => "High Pass",
            "02" => "Band Pass",
            "03" => "Band Stop",
            "04" => "Analog 1 Pole",
            "05" => "Analog 2 Pole",
            "06" => "Analog 3 Pole",
            "07" => "Analog 4 Pole"
          }
        },
        "filter-2-mode" => {
          "type" => "enum",
          "values" => {
            "00" => "Low Pass",
            "01" => "High Pass",
            "02" => "Band Pass",
            "03" => "Band Stop"
          }
        }
      }.freeze

      # Live-edit anchors from effects.md (not parameter-options.md).
      EFFECTS_REFS = {
        "chorus-feedback" => { "type" => "percent_bipolar_64" },
        "phaser-feedback" => { "type" => "percent_bipolar_64" },
        "chorus-lowhigh-balance--rotary-speaker" => { "type" => "percent_bipolar_64" }
      }.freeze

      module_function

      def for_ref(ref)
        REFS[ref]
      end

      def for_effects_ref(ref)
        EFFECTS_REFS[ref]
      end
    end
  end
end
