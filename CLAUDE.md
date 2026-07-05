# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

RAMZA is a **methodology repository with a mechanized core** — the planning Eidolon
succeeding SPECTRA. Unlike a pure methodology repo, the contract here is that every
quality gate the docs describe is enforced by a script in `bin/`. If you change a
gate's semantics in the docs, you change the tool (and its tests) in the same commit.

Cycle: `DISCOVER/CLARIFY → RS → S → [P] → [E] → C → [T] → (R, capped 3) → A`.

## Layout

- `bin/` — the 10 gate tools (bash 3.2 + jq only; no other runtime). Source of truth
  for every CLI contract. All logging to stderr; stdout is machine-readable.
- `docs/methodology/` — SPEC.md (cycle), tiers.md (right-sizing), scoring.md
  (rubrics-as-instruments + calibration protocol).
- `skills/` — host-loadable skill files; `templates/` — lintable artifact templates
  (acceptance-criteria.md must round-trip through `ramza-ears-lint`; planning-artifact.md
  through `ramza-lint --tier full`).
- `schemas/` — plan-state.v1.json (the audit trail), vendored ECL envelope schemas,
  install manifest schema.
- `tests/` — behavioral bats suites, one per tool. `anchors/` — calibration anchor
  plans with reference scores.
- `install.sh` — EIIS 1.4 installer (marker-bounded host wiring, sha256 manifest,
  post-install every-file assertion).

## Rules that will bite you

- **bash 3.2 compatibility** (macOS system shell): no `declare -A`, no `${var,,}`,
  no `mapfile`, no `&>>`. CI runs macos-latest to catch this.
- **jq 1.7.1 compatibility**: CI runners ship older jq than dev boxes. Two burned
  lessons: object-value sums need parens (`key: ({...} + {...})`), and
  `expr as $x` binds tighter than arithmetic — parenthesize the binding source
  (`((a+b)/5) as $mean`). Verify with a downloaded jq-1.7.1 before pushing.
- **Consumer artifacts live under `.spectra/`** (SPECTRA-compatible), and that
  directory name is intentional — do not rename it to `.ramza/`.
- **Tests are behavioral**: they run the tools and assert exit codes + state-file
  contents. Don't replace them with grep-the-prose assertions.
- Version stamps: AGENTS.md frontmatter `version:` must match the release being cut
  (the nexus release template validates EIIS conformance at tag time).

## Commands

```bash
bats tests/                                  # full behavioral suite
shellcheck -x -S error install.sh bin/*      # lint (CI severity)
bash install.sh --non-interactive /tmp/x     # smoke install
```
