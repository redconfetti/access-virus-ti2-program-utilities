# frozen_string_literal: true

require "spec_helper"
require "fileutils"

RSpec.describe "CLI tools" do
  it "virus-scan reports file type" do
    output = `ruby bin/virus-scan #{fixture_path("virus-ti2/arrangements/multi-arrangement.syx")}`

    expect($CHILD_STATUS).to be_success
    expect(output).to include("Type: Arrangement")
  end

  it "virus-scan reports a singles and multis bank" do
    output = `ruby bin/virus-scan #{fixture_path("virus-ti2/multis-bank/multis-dump.syx")}`

    expect($CHILD_STATUS).to be_success
    expect(output).to include("Type: Singles + Multis bank")
    expect(output).to include("Programs: 256")
    expect(output).to include("Multis: 128")
  end

  it "virus-list shows arrangement parts" do
    output = `ruby bin/virus-list #{fixture_path("virus-ti2/arrangements/multi-arrangement.syx")}`

    expect($CHILD_STATUS).to be_success
    expect(output).to include("Part 1")
    expect(output).to include("Cello")
  end

  it "virus-show supports --help" do
    output = `ruby bin/virus-show --help`

    expect($CHILD_STATUS).to be_success
    expect(output).to include("Usage: virus-show")
    expect(output).to include("--output csv")
  end

  it "virus-show writes csv output" do
    csv_path = File.expand_path("../tmp/virus-show-test.csv", __dir__)
    FileUtils.mkdir_p(File.dirname(csv_path))
    path = fixture_path("virus-ti2/programs/DulcimerJM.syx")
    status = system("ruby", "bin/virus-show", "--slot", "1", "--output", "csv", csv_path, path)

    expect(status).to be(true)
    expect(File.read(csv_path)).to include("category,panel,parameter")
  ensure
    File.delete(csv_path) if csv_path && File.exist?(csv_path)
  end
end
