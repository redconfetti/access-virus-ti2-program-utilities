# frozen_string_literal: true

require "spec_helper"
require "virus_ti"
require "virus_ti/show"

RSpec.describe VirusTi::Show do
  describe ".build" do
    it "selects a program from a bank fixture by slot" do
      selection = described_class.build(fixture_path("virus-ti2/banks/full-bank.syx"), slot: 1)

      expect(selection.label).to include("arkadia1")
      expect(selection.context).to eq(:bank)
    end

    it "selects a single edit-buffer export by slot" do
      selection = described_class.build(fixture_path("virus-ti2/programs/DulcimerJM.syx"), slot: 1)

      expect(selection.label).to include("Dulcimer")
      expect(selection.context).to eq(:single)
    end

    it "selects a part from an arrangement fixture by slot" do
      selection = described_class.build(
        fixture_path("virus-ti2/arrangements/multi-arrangement.syx"),
        slot: 1
      )

      expect(selection.label).to include("Part 1")
      expect(selection.label).to include("Cello")
      expect(selection.context).to eq(:arrangement)
    end

    it "requires a slot number" do
      expect do
        described_class.build(fixture_path("virus-ti2/banks/full-bank.syx"), slot: nil)
      end.to raise_error(ArgumentError, /--slot is required/)
    end
  end

  describe ".parameter_groups" do
    it "returns grouped parameters for all categories" do
      selection = described_class.build(fixture_path("virus-ti2/programs/DulcimerJM.syx"), slot: 1)
      groups = described_class.parameter_groups(selection)

      expect(groups.map(&:first)).to eq(VirusTi::Parameters::CATEGORY_ORDER)
      expect(groups.flat_map { |_category, params| params }.size).to eq(379)
    end
  end
end

RSpec.describe VirusTi::Output::Formatter do
  describe ".render" do
    let(:selection) do
      VirusTi::Show.build(fixture_path("virus-ti2/programs/DulcimerJM.syx"), slot: 1)
    end
    let(:groups) { VirusTi::Show.parameter_groups(selection) }

    it "renders text output with categories" do
      text = described_class.render(selection, groups, format: :text)

      expect(text).to include("Dulcimer")
      expect(text).to include("Osc/Mixer")
      expect(text).to include("Filters")
      expect(text).to include("Single")
    end

    it "renders csv output" do
      csv = described_class.render(selection, groups, format: :csv)

      expect(csv).to include("category,panel,parameter,offset,hex,decimal")
      expect(csv).to include("Dulcimer").or include("Osc/Mixer")
    end

    it "renders pdf output" do
      pdf = described_class.render(selection, groups, format: :pdf)

      expect(pdf).to start_with("%PDF")
    end
  end
end
