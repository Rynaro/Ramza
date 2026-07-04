# Changelog

All notable changes to RAMZA. Format: [Keep a Changelog](https://keepachangelog.com/), versioning: SemVer.

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
