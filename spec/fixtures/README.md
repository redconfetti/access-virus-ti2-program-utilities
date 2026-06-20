# Test fixtures

Binary SysEx and MIDI files used by the RSpec suite. Each file is an export of
user-owned patches so the utilities are verified against multiple sources and
formats without redistributing Access factory content.

## Layout

```text
spec/fixtures/
  ostirus/
    banks/            OsTIrus bank exports (.syx, .mid)
    arrangements/     OsTIrus multi + 16-part exports (.syx, .mid)
    programs/         OsTIrus single-program exports (.syx, .mid)
  aura/               AURA plugin exports (add files here)
spec/support/fixtures.rb   Registry and helpers for specs
```

## Adding fixtures

1. Place the file under the appropriate source directory.
2. Register it in `spec/support/fixtures.rb` with expected message counts and sample metadata.
3. Run `bundle exec rspec` to confirm parsing.

Use lowercase, hyphenated filenames (e.g. `redconfetti.mid`).

## Sources

| Path | Source | Format | Contents |
| ---- | ------ | ------ | -------- |
| `ostirus/banks/redconfetti.syx` | OsTIrus | SysEx | RAM A bank excerpt (10 singles) |
| `ostirus/banks/redconfetti.mid` | OsTIrus | MIDI | Same bank as `.syx` |
| `ostirus/arrangements/arcadia-arrangement.syx` | OsTIrus | SysEx | Multi + 16 embedded singles |
| `ostirus/arrangements/arcadia-arrangement.mid` | OsTIrus | MIDI | Same arrangement as `.syx` |
| `ostirus/programs/organ-stab.syx` | OsTIrus | SysEx | Single program |
| `ostirus/programs/arkadia.syx` | OsTIrus | SysEx | Single program |
| `ostirus/programs/arkadia.mid` | OsTIrus | MIDI | Single program |

The top-level `artifacts/` directory is for temporary local samples during
development. Committed test data lives here under `spec/fixtures/`.
