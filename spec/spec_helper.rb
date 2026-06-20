# frozen_string_literal: true

require "bundler/setup" if File.exist?(File.expand_path("../Gemfile", __dir__))

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require_relative "support/fixtures"
require_relative "support/matchers"

module SpecHelpers
  module_function

  def fixture_path(relative)
    Fixtures.path(relative)
  end

  def fixture_bytes(relative)
    File.binread(fixture_path(relative))
  end
end

RSpec.configure do |config|
  config.include SpecHelpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
