# Changelog

All notable changes to RAMZA. Format: [Keep a Changelog](https://keepachangelog.com/), versioning: SemVer.

## [Unreleased]

### Changed
- Anchor references revised to v2 (consensus of two independent clean scorers — sonnet-5, haiku-4.5, 2026-07-05); v1 designer-authored references retired as a maker≠checker violation in reference authoring. First live calibration run: both scorer models now report `calibrated`; band agreement was universal even against v1 (the rubric discriminates — the references, not the scorers, were off on the weak anchor by 20-27 points).

## [0.2.0] — 2026-07-04

Stage-2 measurement instruments + EIIS conformance completion.

### Added
- **`bin/ramza-adherence`** — plan-adherence report (Plan-Phase / Plan-Order /
  Plan-Fidelity + geometric-mean composite) computed from the state-file audit trail
  and the latest drift evidence; `--min` threshold gate; appended to
  `adherence_reports[]`. Adherence is measured separately from plan quality.
- **`bin/ramza-calibrate`** — cross-model rubric calibration against shipped anchor
  plans (`anchors/`: one solid-band, one weak-band with reference dimensions);
  per-dimension tolerance + verdict-band agreement computed through the production
  `ramza-score` path. Lands the calibration verb parked since the nexus v2.0 Wave-3
  plan. Anchors ship in the repo/cache, not the consumer install target.
- Root `AGENTS.md` + `CLAUDE.md` (EIIS required-file set — the scaffold lacked them;
  caught preparing the attested release, which validates conformance at tag time).
- Installer: the two new tools join the closed `BIN_NAMES` assertion set;
  `templates/plan.junction.json` (Junction §7.5 plan template) now installs to
  `schemas/plan.junction.json` and is asserted post-install.

### Fixed
- `ramza-score` refine rubric: jq-1.7.1 `as`-binding precedence (`x/5 as $v` parsed
  as `x/(5 as $v|…)`) — parenthesized; full suite verified under jq 1.7.1.
- `ramza-rightsize`: jq-1.7.1 object-value sums need explicit parentheses.
- `ramza-verify-emit`: required-field check used `ecl_version`; the ECL v2.0 schema
  and template name it `envelope_version`.
- CI: shellcheck brew-installed on macos-latest (no longer preinstalled).

## [0.1.0] — 2026-07-04

Scaffold release — the SPECTRA → RAMZA succession (see DESIGN-RATIONALE.md D1–D8 and
the campaign record in the Eidolons nexus at `.spectra/plans/spectra-v2/`).

### Added
- **`bin/` mechanization layer** (bash 3.2, jq-only; every gate is code, not prose):
  `ramza-rightsize` (signals → trivial/lite/full tier), `ramza-gate` (phase state
  machine: order enforced, skips need reasons, refine capped at 3, maker≠checker on
  critic), `ramza-score` (complexity/explore/refine/confidence arithmetic + calibration
  log), `ramza-ears-lint` (EARS grammar + atomicity), `ramza-freeze` (SHA-256 criteria
  freeze + hash-chained amend), `ramza-lint` (tier-aware plan structure + trivial-tier
  120-line budget), `ramza-drift` (plan-vs-diff drift: declared scope vs touched files,
  worktree/staged/range), `ramza-verify-emit` (frontmatter + envelope integrity gate).
- `schemas/plan-state.v1.json` — the authoritative audit-trail state artifact.
- **RS phase** (mechanical right-sizing) prepended to the inherited cycle:
  RS → S → P → E → C → T → (R) → A. "Never skip" retired (evidence: D3).
- Executor-tier scaffold doctrine (`docs/methodology/tiers.md`): frontier holds
  boundaries; denser scaffolds + low-ambiguity contracts for economy tiers (D6).
- Calibration-first honesty posture (D7): every scored gate logs to
  `ramza-calibration.jsonl`; no outcome claims until measured.

### Inherited from SPECTRA v4.11.0 (succession spine, D2)
- S→P→E→C→T→R→A cycle semantics, DISCOVER/CLARIFY pre-phases, read-only P0,
  `.spectra/` output discipline (kept for consumer compatibility), EIIS 1.4 installer
  contract, ECL 2.0 envelope emission (opt-in via `ECL_VERSION`), EARS
  acceptance-criteria template lineage (DR-12), CRYSTALIUM memory verbs, host wiring
  (Claude Code / Copilot / Cursor / opencode).

### Known limitations (tracked for v1.0.0)
- `ramza-verify-emit` performs schema-shaped checks via jq (required fields, closed
  performative set read from the schema, recomputed sha256) — not full JSON Schema
  validation; deep transport checks remain Junction `harness_verify` L1–L4.
- MCP surface not yet exposed (scripts-first by design; Junction-catalogue candidate).
- Rubric weights inherited as v1 instruments — uncalibrated until Stage 2 measurement.
