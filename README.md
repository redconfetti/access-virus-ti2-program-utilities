# Access Virus TI2 Program Utilities

Ruby command-line utilities for interpreting **Access Virus TI mk2** SysEx and
MIDI files — single programs, full banks, and multi/arrangement dumps.

Specifications are based on the reverse-engineered
[access-virus-ti-sysex](https://github.com/redconfetti/access-virus-ti-sysex/)
documentation.

## Requirements

- Ruby 3.0 or newer
- macOS or Linux (or [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
  on Windows)

## Quick start

```bash
bundle install
bundle exec rspec

# Scan a SysEx file for message types
ruby bin/virus-syx-scan spec/fixtures/ostirus/programs/organ-stab.syx

# List an arrangement (multi + 16 parts)
ruby bin/virus-syx-list spec/fixtures/ostirus/arrangements/arcadia-arrangement.syx
```

Or via Rake:

```bash
bundle exec rake spec
```

## Commands

| Command | Description |
| ------- | ----------- |
| `bin/virus-syx-scan` | Summarize SysEx/MIDI messages in a file |
| `bin/virus-syx-list` | List Single/Multi dumps, or Arrangement parts with names |

Supported file types:

- `.syx` / `.sysex` — raw SysEx dumps
- `.mid` / `.midi` — Standard MIDI files containing embedded SysEx (SMF track parsing)

## Project layout

```text
bin/                  User-facing executables
lib/virus_ti/         Library code
  sysex/              Generic SysEx parsing (split, headers, message types)
  dumps/              Single Dump (524 B) and Multi Dump (267 B) interpreters
  midi/               MIDI file SysEx extraction
  banks.rb            Bank byte → RAM/ROM label mapping
  file_reader.rb      Route .syx vs .mid to the appropriate reader
spec/                 RSpec suite
  fixtures/           Committed test files (OsTIrus, AURA)
  support/            Spec helpers and fixture registry
artifacts/            Temporary local samples (not used by tests)
```

## Library usage

```ruby
require "virus_ti"

messages = VirusTi::FileReader.read_messages("program.syx")

messages.each do |message|
  next unless message.single_dump?

  single = VirusTi::Dumps::Single.parse(message.bytes)
  puts "#{single.bank_label} #{single.slot_label}: #{single.name}"
end
```

## Windows

Use WSL and follow the Linux instructions above. Files on the Windows side are
available under `/mnt/c/Users/...`.

## Status

This project is early boilerplate. Behavior and output formats will evolve as
specifications are refined. See
[access-virus-ti-sysex](https://github.com/redconfetti/access-virus-ti-sysex/)
for the underlying SysEx documentation.

## License

TBD
