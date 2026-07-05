# Canary Missions — RAMZA

> DSL-format missions for `eidolons canary ramza`. Adapted from SPECTRA's
> canary suite for the mechanized RS-first cycle — every mission now expects
> `bin/ramza-*` tool invocations, not self-reported arithmetic. The legacy
> free-form catalog is preserved under "Legacy mission catalog (pre-DSL,
> SPECTRA)" below as historical reference to the predecessor's original
> missions; the validator parses only the `## Mission: <id>` blocks above it.

---

## Mission: smoke-default

### Prompt

Using the RAMZA methodology, plan the following feature:

> Add a health-check endpoint to a REST API that returns service status and version.

Assume: Node.js / TypeScript, Express, no existing health check, no authentication required, single file touched, no new dependency, no public API/migration/security flag, stakes low. The request is unambiguous; CLARIFY should be brief or skipped.

Run `ramza-rightsize` first and let its tier drive the cycle. Walk through RS → S → P → E → C → T → A (per the computed tier) and produce the final dual-format specification artefact (markdown body + YAML companion block), citing the `ramza-*` tool used at each gate. Do NOT write implementation code — specification only.

### Expected output shape

The response opens with a `ramza-rightsize` call/result (tier + score), then a Scope section with a complexity score (1-12, via `ramza-score --rubric complexity`) and request-type tag, then Pattern naming Express conventions, then Explore with at least two hypotheses scored via `ramza-score --rubric explore`, then Construct with EARS acceptance criteria, then Test citing `ramza-lint`/`ramza-ears-lint` and at least one GIVEN/WHEN/THEN story, then Assemble with confidence via `ramza-score --rubric confidence` and the final dual-format artefact. The markdown body is followed by a YAML block companion. No JS/TS implementation code is present.

### Validation criteria

- MUST contain heading: `## Scope`
- MUST contain phrase: `ramza-rightsize`
- MUST contain phrase: `complexity`
- MUST contain phrase: `GIVEN`
- MUST contain phrase: `WHEN`
- MUST contain phrase: `THEN`
- MUST contain heading: ```yaml
- SHOULD contain phrase: `READ-ONLY`
- SHOULD contain phrase: `hypothes`
- SHOULD contain phrase: `ramza-score`
- SHOULD have token count between 1200 and 4000

---

## Mission: dual-format

### Prompt

Using RAMZA, plan this change against an existing brownfield codebase:

> Extend the user authentication system to support multi-factor authentication via TOTP.

Assume: Ruby on Rails, Devise gem, PostgreSQL, existing RSpec suite, ~50k LOC, ~5-8 files touched, a public API surface change (new MFA endpoints), stakes medium.

Run `ramza-rightsize` first (expect `lite` or `full`) and produce the dual-format RAMZA artefact. The Test phase MUST cite `ramza-lint`/`ramza-ears-lint` and include a YAML risk register listing at least one P0, P1, or P2 item. The Construct phase MUST tag identified risks with `P0`, `P1`, or `P2` markers.

### Expected output shape

A RAMZA artefact whose final Assemble section contains both a markdown body and a YAML block, with confidence computed via `ramza-score --rubric confidence`. The markdown body has Scope, Pattern, Explore, Construct, Test, and Assemble sections. Explore lists at least three hypotheses with comparative `ramza-score` results. Construct includes P0/P1/P2 risk tags. The YAML block contains at least: a Scope summary, a hypothesis array, and a risk register array with severity entries. No Ruby implementation code is present.

### Validation criteria

- MUST contain heading: `## Scope`
- MUST contain phrase: `ramza-rightsize`
- MUST contain phrase: `P0|P1|P2`
- MUST contain heading: ```yaml
- MUST contain phrase: `risk`
- MUST mention paths: `Gemfile`
- SHOULD contain phrase: `Devise`
- SHOULD contain phrase: `hypothes`
- SHOULD contain phrase: `ramza-score`
- SHOULD have token count between 1500 and 5000

---

## Mission: memory-round-trip

### Prompt

Using the RAMZA methodology, plan the following feature:

> Add a rate-limiting middleware to a REST API to cap requests per IP to 100/min.

Assume: Node.js / TypeScript, Express, no existing rate limiting, Redis available, ~2-3 files touched, one new dependency (rate-limit library), stakes low-to-medium.

Run `ramza-rightsize` first. Before starting Scope, demonstrate the memory pre-flight: call `mcp__crystalium__recall` with `scope={project: "test-project", agent_class_visibility: "ramza"}`, `query="rate limiting middleware Node.js Express Redis"`, `k=5`, `layers=["semantic","episodic","procedural"]`. After producing the final spec Markdown + YAML artefact (Assemble phase — run `ramza-freeze` then `ramza-verify-emit`), emit the ECL envelope skeleton (fill `from.eidolon: ramza`, `to.eidolon: apivr`, `performative: PROPOSE`, `author_agent: ramza`) then call `mcp__crystalium__ingest(envelope=<envelope>, payload=<spec markdown>)`. Finally call `mcp__crystalium__session_end()`.

If `mcp__crystalium__*` tools are not available, proceed without them and note "CRYSTALIUM absent — memory hooks skipped" at each would-be call site.

### Expected output shape

The response begins with a `ramza-rightsize` call, then a `mcp__crystalium__recall` call (or the graceful-skip note). It then runs the full RAMZA cycle — every gate via a named `bin/ramza-*` tool — and emits a dual-format spec artefact, including `ramza-freeze` and `ramza-verify-emit` at Assemble. After Assemble, it shows a `mcp__crystalium__ingest` call (or graceful-skip note) with `author_agent: ramza` in the provenance, followed by `mcp__crystalium__session_end()` (or graceful-skip note).

### Validation criteria

- MUST contain phrase: `ramza-rightsize`
- MUST contain phrase: `mcp__crystalium__recall` OR `CRYSTALIUM absent`
- MUST contain phrase: `mcp__crystalium__ingest` OR `CRYSTALIUM absent`
- MUST contain phrase: `mcp__crystalium__session_end` OR `CRYSTALIUM absent`
- MUST contain phrase: `author_agent` OR `CRYSTALIUM absent`
- MUST contain phrase: `ramza` (in provenance context)
- MUST contain heading: ```yaml
- MUST contain phrase: `GIVEN`
- SHOULD contain phrase: `T1`
- SHOULD contain phrase: `graceful` OR `CRYSTALIUM absent`

---

## Mission: discovery-elicitation

### Prompt

Using the RAMZA methodology, plan the following:

> We need better observability for our platform.

This request is **under-GOALED** — the objective itself is unspecified (no metric, no
scope, no named stakeholder, no platform definition). Before RS or CLARIFY, run the
DISCOVER sub-mode: elicit stakeholders, the latent goal, success metrics, hard
constraints, and non-goals as a checklist; emit `[GAP]` markers for each unknown so
coverage is mechanically countable; produce an elicitation summary and hand it to
CLARIFY. Do NOT jump straight to `ramza-rightsize`, a Scope artifact, or a plan. Do
NOT write implementation code.

### Expected output shape

The response opens with a `## DISCOVER` section formatted as a checklist (`- [ ]` /
`- [x]` per axis) that elicits stakeholders, latent goal, success metrics, hard
constraints, and non-goals, with `[GAP]` markers on unresolved lines and an explicit
coverage/unresolved-count line. DISCOVER produces an elicitation summary (NOT a plan)
and explicitly hands off to CLARIFY. No `ramza-rightsize` call, Scope artifact, story
hierarchy, or implementation code appears before discovery completes.

### Validation criteria

- MUST contain phrase: `DISCOVER`
- MUST contain phrase: `[GAP]`
- MUST contain phrase: `stakeholder`
- MUST contain phrase: `CLARIFY`
- MUST contain phrase: `non-goal` OR `Non-goal` OR `out of scope`
- SHOULD contain phrase: `success metric` OR `baseline`
- SHOULD contain phrase: `latent` OR `elicit`
- SHOULD contain phrase: `coverage` OR `unresolved`
- SHOULD NOT contain heading: `## Construct`
- SHOULD NOT contain phrase: `ramza-rightsize`

---

## Mission: parallel-spec-trance

### Prompt

Using RAMZA at **TRANCE tier** (assume the cortex has authorized TRANCE for this
high-stakes, high-complexity request), plan the following:

> Design the cross-service migration to split a monolithic order-processing service
> into independent inventory, payment, and fulfilment services with a new event bus.

Assume: complexity 10-12 (per `ramza-score --rubric complexity`), multi-service
STRATEGIC change, high rework risk. Because TRANCE is authorized, run the **Parallel
Spec Mode (G3 evaluator-optimizer)**: GENERATE ≥2 perspective-diverse candidate specs
in clean-context branches, EVALUATE them with `ramza-score --rubric explore` and the
bias-hardened judge (note the mitigations applied), JUDGE-MERGE into one spec with
per-dimension `[DECISION]` provenance, and TERMINATE at the `ramza-score --rubric
confidence` gate or within the 3-iteration cap — then run `ramza-freeze` and
`ramza-verify-emit` before emission like any other Assemble exit. Do NOT write
implementation code.

### Expected output shape

The response shows ≥2 perspective-diverse candidate specs (e.g. conservative,
pattern-leveraging, innovative), an EVALUATE step scored via `ramza-score` that
explicitly notes the LLM-as-judge bias mitigations (identity stripped / order
rotated / length-normalized / deterministic-anchor), a JUDGE-MERGE step that
synthesizes ONE spec with per-dimension `[DECISION]` provenance and a Rejected
Alternatives section, and a termination note at the confidence gate or ≤3
iterations. The final output is a single dual-format spec that still passes through
`ramza-freeze`/`ramza-verify-emit`.

### Validation criteria

- MUST contain phrase: `GENERATE` OR `candidate spec`
- MUST contain phrase: `[DECISION]`
- MUST contain phrase: `JUDGE-MERGE` OR `judge-merge`
- MUST contain phrase: `Rejected Alternatives` OR `rejected`
- MUST contain phrase: `bias` OR `identity` OR `rotate`
- MUST contain phrase: `ramza-score`
- MUST contain heading: ```yaml
- SHOULD contain phrase: `TRANCE`
- SHOULD contain phrase: `cap 3` OR `3 iterations` OR `confidence`
- SHOULD contain phrase: `worktree` OR `read-only`

---

## Mission: rightsize-gate

### Prompt

Using the RAMZA methodology, plan the following:

> Rename the `getUserData` function to `fetchUserProfile` in a single file, updating its 3 call sites in the same module.

Assume: a single-file rename, no new dependency, no public API surface change, no
migration, no security implications, low stakes. Run `ramza-rightsize --files-est 1
--stakes low` (or the equivalent invocation) first and let the resulting tier drive
everything else — do NOT plan at a heavier tier than the signals warrant. Produce the
final plan as a single Markdown artefact, and state explicitly which `ramza-lint`
invocation it would pass.

### Expected output shape

The response opens with an explicit `ramza-rightsize` call/result showing tier
`trivial` (score 0 from `--files-est 1` + `--stakes low`). It then runs only the
trivial-mandatory phases (RS, S, C, A) — Pattern, Explore, Test, and Refine are not
run, and this is stated as tier-driven, not an omission needing a `--reason` skip
(they aren't trivial-mandatory). The plan body contains only `## Scope`, `##
Approach`, and `## Acceptance Criteria` (no `## Stories`, `## Confidence`, `##
Rejected Alternatives`, or `## Risks`), stays well under 120 lines, and the response
states it would pass `ramza-lint --plan <file> --tier trivial`.

### Validation criteria

- MUST contain phrase: `ramza-rightsize`
- MUST contain phrase: `trivial`
- MUST contain heading: `## Scope`
- MUST contain heading: `## Approach`
- MUST contain heading: `## Acceptance Criteria`
- MUST contain phrase: `ramza-lint`
- SHOULD NOT contain heading: `## Stories`
- SHOULD NOT contain heading: `## Confidence`
- SHOULD NOT contain heading: `## Rejected Alternatives`
- SHOULD have token count between 200 and 1200

---

## Mission: drift-tamper

### Prompt

Using the RAMZA methodology, walk through this failure-mode scenario and report what
the tooling does (do not skip to a happy-path answer, and do not write implementation
code):

> A plan's acceptance criteria were frozen at Assemble with `ramza-freeze --state
> .spectra/plans/demo.state.json --criteria .spectra/plans/demo.acceptance.md`. After
> freeze, someone hand-edited `.spectra/plans/demo.acceptance.md` directly — adding a
> new THEN clause to `AC-002` — without running `ramza-freeze --amend --reason`.

Explain, step by step, what running `ramza-freeze --state .spectra/plans/demo.state.json
--criteria .spectra/plans/demo.acceptance.md --verify` reports, including its exit
code, and name the two legitimate remediations. Do NOT claim the tool silently
accepts the edit.

### Expected output shape

The response explains that `--verify` recomputes the SHA-256 of the current criteria
file and compares it to `criteria_sha256` recorded at freeze time; since the content
changed without `--amend`, the hashes differ, the tool reports a `DRIFT: criteria
hash mismatch` (both the frozen and current hash shown) and exits 1 — tamper
*evidence*, not silent acceptance. It names the two remediations: `ramza-freeze
--amend --reason "<why>"` (the plan legitimately grew) or reverting the unrecorded
edit, and notes neither hash is fabricated — both are real SHA-256 computations over
file bytes.

### Validation criteria

- MUST contain phrase: `ramza-freeze`
- MUST contain phrase: `--verify`
- MUST contain phrase: `DRIFT`
- MUST contain phrase: `sha256` OR `SHA-256`
- MUST contain phrase: `exit 1` OR `exits 1` OR `exit code 1`
- MUST contain phrase: `--amend`
- MUST contain phrase: `AC-002`
- SHOULD contain phrase: `tamper`
- SHOULD contain phrase: `reason`
- SHOULD NOT contain phrase: `silently accept`

---

## Legacy mission catalog (pre-DSL, SPECTRA)

> The original three free-form missions ("Simple Feature Spec", "Brownfield
> Analysis", "Ambiguous Request") are preserved below as a historical record of
> SPECTRA's pre-DSL canary suite (RAMZA's predecessor, still `shipped` in the
> roster per `DESIGN-RATIONALE.md` D8). They describe SPECTRA's self-policed
> CLARIFY → Scope → Pattern → Explore → Construct → Test → Refine → Assemble
> cycle, not RAMZA's mechanized RS-first one — they are not adapted, and the
> validator parses only the `## Mission: <id>` blocks above.

---

## Mission 1 — Simple Feature Spec (Greenfield)

**What it checks:** SPECTRA activates, runs CLARIFY, produces a dual-format artifact.

**Input prompt:**

```
Using SPECTRA, plan the following feature:
"Add a health check endpoint to a REST API that returns service status and version."

Assume: Node.js/TypeScript, Express framework, no existing health check, no authentication needed.
```

**Expected phase activations:**
CLARIFY (brief — intent is unambiguous), Scope (complexity 4–6, REQUEST type),
Pattern (Express routing patterns), Explore (2–3 hypotheses), Construct, Test, Assemble.

**Expected artifact shape:**
- CLARIFY: ≤2 clarifying questions, or skipped as unambiguous
- Scope score: 4–6/12
- ≥2 hypotheses in Explore
- Final artifact: Markdown spec + YAML block
- No implementation code in output

**Pass criteria:**
- [ ] Dual-format output produced (Markdown + YAML/JSON)
- [ ] No code written — specification only
- [ ] Story uses GIVEN/WHEN/THEN acceptance criteria
- [ ] Agent cites the READ-ONLY constraint at least once

---

## Mission 2 — Brownfield Analysis (Pattern Phase Emphasis)

**What it checks:** Pattern phase reads existing conventions, complexity routing triggers extended thinking.

**Input prompt:**

```
Using SPECTRA, plan the following change:
"Extend an existing user authentication system to support multi-factor authentication (MFA) via TOTP."

Assume: Ruby on Rails app, Devise gem for auth, PostgreSQL, existing RSpec test suite, ~50k LOC codebase.
```

**Expected phase activations:**
CLARIFY (asks about MFA recovery codes, enforcement policy), Scope (complexity 8–10,
CHANGE type, extended thinking triggered), Pattern (Devise patterns, auth migration risks),
Explore (3–5 hypotheses with 7-dim scoring), Construct, Test (adversarial layer),
Refine (likely 1 cycle), Assemble.

**Expected artifact shape:**
- CLARIFY: 2–3 questions about recovery flow, enforcement rollout, existing Devise config
- Scope complexity: ≥8/12 (triggers extended thinking notice)
- Pattern catalog: ≥2 existing auth conventions + risk flags
- ≥3 hypotheses in Explore with numeric scores
- Risk tags P0/P1/P2 present in Construct artifact

**Pass criteria:**
- [ ] CLARIFY asks ≥1 question about existing patterns before proceeding
- [ ] Scope score ≥7/12 with extended thinking noted
- [ ] Pattern catalog lists ≥2 existing conventions
- [ ] Dual-format output includes a YAML risk register

---

## Mission 3 — Ambiguous Request (CLARIFY Stress Test)

**What it checks:** SPECTRA does not begin planning when intent is underspecified.

**Input prompt:**

```
Using SPECTRA, plan: "Make the app faster."
```

**Expected behavior:**
CLARIFY phase activates fully. The agent does NOT proceed to Scope until
critical disambiguation questions are answered.

**Expected CLARIFY output:**
The agent asks ≤3 specific, numbered questions addressing at minimum:
1. Which part of the app is slow? (frontend, backend API, database queries, startup, etc.)
2. What does "faster" mean? (target metric, current baseline — e.g., p95 < 200ms)
3. What is the scope? (one endpoint, all endpoints, background jobs, initial load, etc.)

**Pass criteria:**
- [ ] Agent does NOT output a Scope artifact or plan before clarifying
- [ ] Exactly ≤3 clarifying questions (not more)
- [ ] Questions are numbered and specific (not vague)
- [ ] Agent explains why each question changes the plan's shape

---

*RAMZA — run these missions after `bash install.sh` or `bash tools/ramza-init.sh`*
