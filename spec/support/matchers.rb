# frozen_string_literal: true

RSpec::Matchers.define :be_virus_ti do
  match { |message| message.virus_ti? }
end

RSpec::Matchers.define :be_single_dump do
  match { |message| message.single_dump? }
end

RSpec::Matchers.define :be_checksum_valid do
  match { |single| single.checksum_valid? }
end
