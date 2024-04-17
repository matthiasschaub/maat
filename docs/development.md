# Development

## Requirements

- Python ^3.11
- Node

## Setup

Setup this project either by using
[pilothouse](https://git.sr.ht/~talfus-laddus/pilothouse) or by hand.

### Setup by using Pilothouse

See [pilothouse](https://git.sr.ht/~talfus-laddus/pilothouse).

```bash
npm install
npm run build
pilothouse chain zod maat/
```

### Setup by Hand

```bash
npm install
npm run build
urbit -F zod
```

```hoon
|merge %maat our %base
|mount %maat
```

Start continuous synchronisation between the git repository's `maat`
directory (Earth) and the `maat` desk's directory (Mars):

```bash
watch "rsync -zr maat/* zod/maat"
```

```dojo
|commit %maat
|install our %maat
```


## Debugging

```
|start %dbug
http://localhost:8080/~debug
```

## Tests

### Integration & Property-Based Tests (Python)

Integration and property-based tests written in Python. These tests utilize the
`pytest` and `hypothesis` frameworks. The tests run against Maat's API
on three fake ships (`~zod`, `~nus` and `lus`). Fake ships are managed
with [pilothouse](https://git.sr.ht/~talfus-laddus/pilothouse).

```bash
pytest
```

