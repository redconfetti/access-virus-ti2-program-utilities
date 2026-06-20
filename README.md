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

# Brief file summary (type, message counts)
ruby bin/virus-scan spec/fixtures/ostirus/arrangements/arcadia-arrangement.syx

# List programs or arrangement parts
ruby bin/virus-list spec/fixtures/ostirus/banks/redconfetti.syx

# Show all parameters for one program or part
ruby bin/virus-show --slot 1 spec/fixtures/ostirus/programs/organ-stab.syx
ruby bin/virus-show --slot 3 spec/fixtures/ostirus/arrangements/arcadia-arrangement.syx
ruby bin/virus-show --slot 1 --output csv params.csv spec/fixtures/ostirus/programs/organ-stab.syx
```

Or via Rake:

```bash
bundle exec rake spec
```

## Commands

| Command | Description |
| ------- | ----------- |
| `bin/virus-scan` | Brief summary: file type, message counts, SysEx commands |
| `bin/virus-list` | List programs (bank) or parts (arrangement) with names |
| `bin/virus-show` | Full parameter dump for one `--slot` (program or part) |

All commands support `--help`.

`virus-show` additionally supports:

- `--output csv FILE` — write parameters as CSV
- `--output pdf FILE` — write parameters as PDF (requires `prawn` gem)

### Typical workflow

1. **`virus-scan`** — identify file type (single, bank, arrangement)
2. **`virus-list`** — see numbered programs/parts
3. **`virus-show --slot N`** — inspect all parameters for that entry

Supported file types:

- `.syx` / `.sysex` — raw SysEx dumps
- `.mid` / `.midi` — Standard MIDI files containing embedded SysEx (SMF track parsing)

## Project layout

```text
bin/                  User-facing executables
lib/virus_ti/         Library code
  sysex/              Generic SysEx parsing (split, headers, message types)
  dumps/              Single Dump (524 B) and Multi Dump (267 B) interpreters
  parameters/         Single Dump parameter map (from access-virus-ti-sysex)
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

MIT License

Copyright (c) 2026 Jason Miller

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
