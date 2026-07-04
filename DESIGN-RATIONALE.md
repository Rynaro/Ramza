# RAMZA — Design Rationale

Succession decisions for the SPECTRA → RAMZA transition. Evidence citations refer to
the campaign research committed in the Eidolons nexus at `.spectra/plans/spectra-v2/`
(research dossiers + CURATION.md verdicts, 2026-07-04).

---

## D1 — Mechanize the gates

**Decision:** Every arithmetic, grammar, freeze, transition, and identity check that
can run as code runs as code (`bin/`, bash 3.2, jq-only). The methodology remains the
mind; the scripts are the spine. The model is never asked to police itself where a
tool can.

**Why:** SPECTRA 4.11's cognitive cycle was enforced by prose the model promised to
obey. The 2026 evidence closed that era: Cursor staff confirmed their Plan Mode is
violated by their own agent ("no fix yet"); Claude Code's `ExitPlanMode` fabricated
user approval in production (issue #9701); ICLR 2026 measured prompted constraints
eroding under pressure. Meanwhile every mechanized-plan-quality primitive (rubric
gates, EARS linting, criteria freezing, drift checking, maker≠checker) was verified
absent from the entire MCP/tooling ecosystem — unclaimed differentiation.

**Rejected:** an MCP-only surface. Scripts-first keeps MCP-less hosts fully gated;
an MCP wrapper can compose later (Junction's `harness_plan_from_prompt` seat).

## D2 — Inherit the discipline spine

**Decision:** Derived from `SPECTRA@v4.11.0`: same S→P→E→C→T→R→A cycle, read-only P0,
`.spectra/` output discipline (kept for consumer-project compatibility), EIIS 1.4
install contract, ECL 2.0 envelopes, CRYSTALIUM memory verbs, EARS criteria (DR-12
lineage). Succession, not rewrite — exactly as Vivi derived from APIVR-Δ@v3.6.0.

**Why:** the spine is the part the audits praised (strongest methodology in the
roster, tier-5 weak-model readiness). The failure mode was enforcement, not doctrine.

## D3 — Right-size mechanically; ceremony is a failure mode

**Decision:** A new mandatory first phase, **RS**: `ramza-rightsize` maps observable
signals (files touched, new deps, public API, migration, security, novelty, stakes)
to a tier — trivial / lite / full. The tier decides which phases and verification
layers are mandatory. Skipping a mandatory phase requires a recorded reason
(`ramza-gate` DENYs otherwise). Trivial plans over 120 lines fail lint. "Never skip"
is retired.

**Why:** forced scaffolds measurably hurt (an incomplete forced plan is *worse than
no plan*; strong models override imposed phase order — arXiv 2604.12147); planning
tokens show sharply diminishing returns past ~100 (BAGEN et al.); Spec Kit's ceremony
produced 2,577 markdown lines for 689 code lines (Scott Logic); the fastest-growing
2026 competitor (GSD) sells exactly "rigor without ceremony." ESL already ratified
mechanical right-sizing as the house pattern.

## D4 — Freeze for tamper-evidence, amend as first-class

**Decision:** Acceptance criteria are SHA-256-frozen at Assemble (`ramza-freeze`);
amendment is a cheap, hash-chained, reasoned operation (`--amend --reason`). A silent
edit makes every later `--verify`/drift check fail. Freeze ≠ immutability.

**Why:** the spec-driven wave's verdict is that the load-bearing variable is spec
*mutability during implementation* (Brooker): immutable specs collapse into waterfall,
mutable-but-silent specs rot into "worse than no spec." Hash-chaining resolves the
dichotomy: change freely, never invisibly. (Kiro's anti-freeze "living documents"
doctrine gets the mutability right and the auditability wrong.)

## D5 — Drift is measured, not hoped against

**Decision:** `ramza-drift` — declared plan scope (globs, recorded in state) checked
against the actually-changed files (worktree, staged, or commit range), report
appended to the audit trail; `ramza-verify-emit` recomputes envelope integrity before
any handoff. Plan-adherence (did execution follow the plan) becomes a measurable
canary, distinct from plan quality.

**Why:** no vendor and no MCP server ships plan-vs-diff binding (verified 2026-07);
externally-tracked spec state recovered 90% of spec-faithfulness degradation (SLUMP);
ESL §6.4 names `drift_check` without an implementation — this is it.

## D6 — Tier the models at boundaries, not phases

**Decision:** Frontier-tier models own plan authoring, judging, and amendment;
executor tiers receive *denser* scaffolds and low-ambiguity output contracts (story
hints carry tier + contract). Escalation to the frontier tier is deterministic
(observable triggers, routing data), never model self-assessment. Blanket
planner/executor splits are refused.

**Why:** Aider's architect/editor split shows real gains (+3–5pt same-model, SOTA
with pairs) *conditional on an unambiguous executor contract*; forced Opus-plans/
Haiku-executes lost 7 quality points at 3× cost on coupled work (AkitaOnRails);
sparse-advisor patterns (frontier consulted on ~12% of turns, SWE-Protégé) beat
mandatory delegation; weak models cannot self-detect their limits (Cognition).

## D7 — Honest instruments

**Decision:** Rubric weights, thresholds, and the tier mapping ship as *instruments
under calibration*, not validated truths. `ramza-score` appends every scored gate to
`ramza-calibration.jsonl`; no outcome claims are made until measured on the nexus
H-WIN instrument. THEORY-style formalisms are presented as named heuristics.

**Why:** SPECTRA's benchmark framework collected zero data while its README implied
evidence; AdaRubric's protocol (rubrics need AUC ≥ 0.8 / κ ≥ 0.75 against outcomes
before trust) is the 2026 bar. Transparency includes being honest about what is
heuristic — that honesty is the brand.

## D8 — Two planners, not bloat

**Decision:** RAMZA takes the `planner` seat through the staged intake path
(in_construction → measurement → default seat); SPECTRA remains `shipped` as the
conservative, named-dispatch fallback. Handoff shape is identical (upstream ATLAS,
downstream Vivi/APIVR-Δ, lateral FORGE/VIGIL), so the pipeline is structurally
unchanged and consumers can swap planners without re-wiring.

**Why:** the Vivi/APIVR-Δ precedent (succession-by-demotion) worked: measured
promotion, preserved fallback, no consumer breakage. Same play, planner seat.

---

*RAMZA — CC BY-SA 4.0*
