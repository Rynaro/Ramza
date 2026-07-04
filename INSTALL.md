# Installing RAMZA

## Via the Eidolons nexus (recommended once rostered)

```bash
eidolons add ramza && eidolons sync
```

## Standalone (EIIS 1.4)

```bash
git clone https://github.com/Rynaro/Ramza.git
bash Ramza/install.sh --target ./.eidolons/ramza --hosts claude-code --non-interactive --force
```

Flags (EIIS §3): `--target DIR`, `--hosts CSV` (`claude-code,copilot,cursor,opencode` or `all`),
`--shared-dispatch|--no-shared-dispatch`, `--non-interactive`, `--force`, `--dry-run`,
`--manifest-only`, `--version`, `--help`.

## What lands where

| Path | Contents |
|---|---|
| `./.eidolons/ramza/` | agent.md, skills/, templates/, schemas/, docs/methodology/, **bin/** (the 8 gate tools, executable) |
| `./.eidolons/ramza/install.manifest.json` | per-file SHA-256 manifest (verifiable via `eidolons verify`) |
| host dirs (`.claude/`, `.github/`, `.cursor/`, `.opencode/`) | dispatch files, marker-bounded blocks in shared files |
| `.spectra/` | created on first plan — plans/, state, calibration log (SPECTRA-compatible layout) |

Runtime dependencies for the gate tools: bash ≥3.2, `jq`, `git`, `shasum`/`sha256sum`.
Re-running the installer is idempotent; upgrades need `--force` (the overwrite gate).

## After install

The host agent drives the cycle in `agent.md`; gates run through
`./.eidolons/ramza/bin/ramza-*`. Try it:

```bash
./.eidolons/ramza/bin/ramza-rightsize --files-est 2 --stakes low \
  --plan hello --state .spectra/plans/hello.state.json
./.eidolons/ramza/bin/ramza-gate status --state .spectra/plans/hello.state.json
```
