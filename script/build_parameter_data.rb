#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "fileutils"

require_relative "../lib/virus_ti/parameters/encoding_refs"

ROOT = File.expand_path("..", __dir__)
PARAM_DIR = File.join(ROOT, "lib/virus_ti/parameters")
OPTIONS_MD = File.join(PARAM_DIR, "parameter-options.md")
SINGLE_MD = File.join(PARAM_DIR, "single.md")
OPTIONS_JSON = File.join(PARAM_DIR, "parameter_options.json")
MAP_JSON = File.join(PARAM_DIR, "single_dump_map.json")

module BuildParameterData
  module_function

  def slugify(text)
    text.downcase
        .gsub(/[^\w\s-]/, "")
        .strip
        .gsub(/\s+/, "-")
  end

  def parse_options_markdown(path)
    lines = File.read(path, encoding: "UTF-8").lines
    sections = {}
    current = nil
    current_sub = nil
    in_table = false

    lines.each do |line|
      if (match = line.match(/^## (.+)\s*$/))
        current = slugify(match[1])
        current_sub = nil
        sections[current] = {
          "title" => match[1].strip,
          "values" => {},
          "subsections" => {}
        }
        in_table = false
        next
      end

      if current && (match = line.match(/^### (.+)\s*$/))
        current_sub = slugify(match[1])
        sections[current]["subsections"][current_sub] = { "values" => {} }
        in_table = false
        next
      end

      next unless current

      target =
        if current_sub
          sections[current]["subsections"][current_sub]
        else
          sections[current]
        end

      if line.strip.start_with?("|") && line.include?("`<value>`")
        in_table = true
        next
      end

      next unless in_table
      next if line.match?(/^\|\s*-+\s*\|/)

      cells = line.split("|").map(&:strip).reject(&:empty?)
      next if cells.size < 2

      if cells[0].match?(/^Index$/i)
        next
      elsif cells[0].match?(/^`([0-9A-Fa-f]{2})`$/)
        value = cells[0].delete("`").upcase
        label = cells[1].delete("*").strip
        target["values"][value] = label
      elsif cells.size >= 3 && cells[1].match?(/^`([0-9A-Fa-f]{2})`$/)
        value = cells[1].delete("`").upcase
        label = cells[2].delete("*").strip
        target["values"][value] = label
      elsif cells.size >= 2 && cells[1].match?(/^`([0-9A-Fa-f]{2})`$/)
        value = cells[1].delete("`").upcase
        label = cells[0].delete("*").strip
        target["values"][value] = label
      end
    end

    sections.each_value do |section|
      section["subsections"].each_value do |sub|
        infer_subsection_encoding!(sub)
      end
      infer_section_encoding!(section)
    end

    finalize_options!(sections)

    sections
  end

  def infer_section_encoding!(section)
    if section["values"].any?
      section["encoding"] = "enum"
    elsif section["title"]&.match?(/note index \(c1\.\.g9\)/i)
      section["encoding"] = "note_c1_g9"
    end
  end

  def infer_subsection_encoding!(sub)
    return if sub["values"].any?

    sub["encoding"] = "percent_bipolar" if sub["title"]&.match?(/modulation depth|amount/i)
  end

  def infer_encoding(live_edit, control)
    live = live_edit.to_s
    control = control.to_s

    if control.match?(/^Mod Matrix Slot \d+ Destination/)
      return assign_target_encoding
    end

    if control.match?(/^Mod Matrix Slot \d+ Amount/)
      return { "type" => "bipolar" }
    end

    if (match = control.match(/^Mod Matrix Slot (\d+) Source/))
      return mod_matrix_source_encoding(match[1].to_i)
    end

    if (ref = live[/effects\.md#([^\)\s]+)/, 1])
      mapped = VirusTi::Parameters::EncodingRefs.for_effects_ref(ref)
      return mapped.dup if mapped
    end

    if (ref = live[/parameter-options\.md#([^\)]+)/, 1])
      mapped = VirusTi::Parameters::EncodingRefs.for_ref(ref)
      return mapped.dup if mapped

      if control.match?(/Assign Target|User Destination/i)
        return assign_target_encoding
      end

      if control.match?(/Mod Matrix|Matrix Slot/i) && control.match?(/Destination/i)
        return assign_target_encoding
      end

      if control.match?(/Mod Matrix|Matrix Slot/i) && control.match?(/Source/i)
        slot = control[/Slot (\d+)/, 1]&.to_i
        return mod_matrix_source_encoding(slot) if slot
      end

      if control.match?(/Mod Matrix|Matrix Slot/i) && control.match?(/Amount/i)
        return { "type" => "bipolar" }
      end

      if control.match?(/Amount|Depth|-->|\-\->/i) || live.match?(/Panorama|Velocity Map|±100\s*%|±100\.0/i)
        return { "type" => "percent_bipolar" }
      end

      if ref == "wavetable-names" || live.match?(/#wavetable-names/)
        return VirusTi::Parameters::EncodingRefs.for_ref("wavetable-names")
      end

      return { "type" => "enum", "ref" => ref }
    end

    if live.match?(/Square `00`, Triangle `01`/i)
      return {
        "type" => "enum",
        "values" => { "00" => "Square", "01" => "Triangle" }
      }
    end

    if live.match?(/Classic `00`, Hypersaw `01`/i) ||
       live.match?(/Mode\/Wave `02`–`43`/i)
      return { "type" => "enum_index" }
    end

    if live.match?(/Off `00`, \*\*1\.\.127\*\*|Off `00`, \*\*1\.\.127\*\* direct/i)
      return { "type" => "direct_off" }
    end

    if live.match?(/50\.0 %\.\.100 %|Pulse Width.*Shape ≥ `40`/i)
      return { "type" => "classic_pulse_width" }
    end

    if live.match?(/±100\s*%|±100\.0|Velocity Map/i)
      return { "type" => "percent_bipolar" }
    end

    if live.match?(/−48\.\.\+48/)
      return { "type" => "bipolar_narrow" }
    end

    if live.match?(/Keyfollow|Key Follow|Norm @ \+32/i)
      return { "type" => "key_follow" }
    end

    if live.match?(/ui\+64|bipolar `ui\+64`|−64\.\.\+63|F-Shift \*\*−64\.\.\+63\*\*/i)
      return { "type" => "bipolar" }
    end

    if live.match?(/stored = lcd|\*\*0\.\.127\*\*|0\.\.127\*\* `stored = lcd`|\*\*0\.\.127\*\* →|Index \*\*0–99\*\*/i)
      return { "type" => "direct" }
    end

    if live.match?(/50\.0 %\.\.100 %/i)
      return { "type" => "classic_pulse_width" }
    end

    if live.match?(/1\.0\.\.9\.0|Hypersaw/i) && control.match?(/Density/i)
      return { "type" => "hypersaw_density" }
    end

    if live.match?(/−100\.0\.\.\+100\.0|percent/i)
      return { "type" => "percent_bipolar" }
    end

    { "type" => "direct" }
  end

  def mod_matrix_source_encoding(slot)
    encoding = {
      "type" => "mod_matrix_source",
      "ref" => "mod-matrix-sources"
    }

    overlap =
      case slot
      when 2
        { "label" => "LFO 1 Rate", "encoding" => { "type" => "direct" } }
      when 3
        { "label" => "LFO 1 Keyfollow", "encoding" => { "type" => "key_follow" } }
      end

    encoding["overlap"] = overlap if overlap
    encoding
  end

  def assign_target_encoding
    {
      "type" => "enum",
      "ref" => "lfo-1-destination",
      "subsection" => "assign-target"
    }
  end

  def finalize_options!(sections)
    assign_target = sections.dig("lfo-1-destination", "subsections", "assign-target", "values")
    if assign_target&.any?
      if (destinations = sections["mod-matrix-destinations"])
        destinations["values"] = assign_target.dup
        destinations["encoding"] = "wire_enum"
        destinations["wire_map_ref"] = "lfo-1-destination/assign-target"
      end
    end

    if (amount = sections["mod-matrix-amount"])
      amount["encoding"] = "bipolar"
    end

    if (chorus = sections["chorus-type"])
      chorus["values"] = { "00" => "Off" }.merge(chorus["values"]) unless chorus["values"]["00"]
    end

    if (shape = sections["lfo-shape"])
      merged = {}
      shape["subsections"].each_value { |sub| merged.merge!(sub["values"]) }
      shape["values"] = merged if merged.any?
      shape["encoding"] = "enum"
    end

    if (rate = sections["lfo-rate"])
      rate["encoding"] = "direct"
    end

    if (settings = sections["lfo-settings"])
      if (key_follow = settings["subsections"]["key-follow-0x48-lfo-3-0x0a"])
        settings["subsections"]["key-follow-0x48"] = key_follow.dup
      end
    end

    %w[chorus-rotary-mic-angle-lcd chorus-rotary-distance-lcd].each do |key|
      sections[key]["encoding"] = "lcd_anchors" if sections[key]
    end

    sections["phaser-mix-lcd"]["encoding"] = "level_off" if sections["phaser-mix-lcd"]
  end

  def parse_single_map(path)
    lines = File.read(path, encoding: "UTF-8").lines
    entries = []
    category = nil

    lines.each do |line|
      if (match = line.match(/^### (.+)\s*$/))
        category = match[1].strip
        next
      end

      next unless line.start_with?("|")
      next if line.include?("Control |")
      next if line.match?(/^\|\s*-+\s*\|/)

      cells = line.split("|").map(&:strip).reject(&:empty?)
      next if cells.size < 4

      control, panel, offset_cell, live_edit = cells
      next unless offset_cell&.match?(/^`0x[0-9A-Fa-f]+`$/)

      offset = offset_cell.delete("`").to_i(16)
      entries << {
        "name" => control,
        "panel" => panel,
        "offset" => offset,
        "category" => map_category(category),
        "encoding" => infer_encoding(live_edit, control)
      }
    end

    entries
  end

  def map_category(section)
    case section
    when "Oscillators" then "Osc/Mixer"
    when "Filters" then "Filters"
    when "LFO" then "Modulators"
    when "Modulation Matrix" then "Matrix"
    when "Arpeggiator" then "Arpeggiator"
    when "FX 1", "FX 2" then "Effects"
    when "Common" then "Single"
    else section
    end
  end

  def build!
    options = parse_options_markdown(OPTIONS_MD)
    map = parse_single_map(SINGLE_MD)

    File.write(OPTIONS_JSON, JSON.pretty_generate(options))
    File.write(MAP_JSON, JSON.pretty_generate(map))

    puts "Wrote #{OPTIONS_JSON} (#{options.size} sections)"
    puts "Wrote #{MAP_JSON} (#{map.size} parameters)"
  end
end

BuildParameterData.build! if $PROGRAM_NAME == __FILE__
