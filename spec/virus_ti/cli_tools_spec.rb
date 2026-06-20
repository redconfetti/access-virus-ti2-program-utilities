# frozen_string_literal: true

require "spec_helper"
require "fileutils"

RSpec.describe "CLI tools" do
  it "virus-scan reports file type" do
    output = `ruby bin/virus-scan #{fixture_path("ostirus/arrangements/arcadia-arrangement.syx")}`

    expect($CHILD_STATUS).to be_success
    expect(output).to include("Type: Arrangement")
  end

  it "virus-list shows arrangement parts" do
    output = `ruby bin/virus-list #{fixture_path("ostirus/arrangements/arcadia-arrangement.syx")}`

    expect($CHILD_STATUS).to be_success
    expect(output).to include("Part 1")
    expect(output).to include("Arkadia1-J")
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
    path = fixture_path("ostirus/programs/organ-stab.syx")
    status = system("ruby", "bin/virus-show", "--slot", "1", "--output", "csv", csv_path, path)

    expect(status).to be(true)
    expect(File.read(csv_path)).to include("category,panel,parameter")
  ensure
    File.delete(csv_path) if csv_path && File.exist?(csv_path)
  end
end
