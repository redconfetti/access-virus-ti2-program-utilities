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
        "wavetable-names" => { "type" => "enum", "ref" => "wavetable-names" }
      }.freeze

      module_function

      def for_ref(ref)
        REFS[ref]
      end
    end
  end
end
