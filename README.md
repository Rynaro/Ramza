# RAMZA

**The plan mode you can audit. A vendor-agnostic planning Eidolon whose gates are code, not vibes.**

> Named for Ramza Beoulve of *Final Fantasy Tactics* — the tactician whose real war
> was erased by the official chronicle and vindicated only because the records survived.
> RAMZA's plans are those records: on-disk, scored, hash-frozen, drift-checked.
> Part of the Final-Fantasy-named [Eidolons](https://github.com/Rynaro/eidolons) family.
> Successor to [SPECTRA](https://github.com/Rynaro/SPECTRA) (retained as the conservative fallback).

## The problem, mid-2026

Every major tool converged on "plan before you code" — and then enforced it with hope:

- Cursor staff on Plan Mode being violated by their own agent: *"a known issue," "no fix yet."*
- Claude Code's `ExitPlanMode` is authored by the very model it gates — with documented
  cases of fabricated approval.
- No vendor ships a portable plan schema, an inspectable plan-quality gate, or any
  binding between the approved plan and the executed diff.
- Research caught up: prompted constraints measurably erode under pressure (ICLR 2026),
  and forced ceremony measurably hurts (2,577 lines of markdown for 689 lines of code).

The plan mode market is a blackbox that asks for trust. RAMZA is the opposite bet.

## What RAMZA is

A planning methodology (cycle, rubrics, templates — inherited from SPECTRA 4.11) whose
every gate is **mechanized** in `bin/` — ten bash-3.2 tools, no runtime beyond `jq` + git:

| Tool | Enforces |
|---|---|
| `ramza-rightsize` | Planning tier (trivial/lite/full) from observable signals — ceremony proportional to stakes, overrides recorded |
| `ramza-gate` | The phase state machine — out-of-order transitions DENIED, skips need reasons, refine capped at 3, **maker≠checker** on plan critique |
| `ramza-score` | Rubric arithmetic (complexity, explore, refine, confidence) — computed by code, never by the model; every score appended to a calibration log |
| `ramza-ears-lint` | EARS acceptance-criteria grammar: closed form set, one atomic assertion per criterion, mandatory VERIFY method |
| `ramza-freeze` | SHA-256 freeze of acceptance criteria — tamper-*evidence*, with first-class hash-chained `--amend` (mutable, never silently) |
| `ramza-lint` | Plan structural completeness per tier |
| `ramza-drift` | **Plan-vs-diff drift**: declared scope vs the files actually touched — the check no vendor and no MCP server ships |
| `ramza-verify-emit` | Emission gate: frontmatter contract + ECL envelope integrity (recomputed sha256, closed performative set) |
| `ramza-adherence` | Post-execution adherence report: Plan-Phase / Plan-Order / Plan-Fidelity, geometric-mean composite — "did we follow the plan" measured separately from plan quality |
| `ramza-calibrate` | Cross-model rubric calibration against shipped anchor plans (`anchors/`) — do not trust verdicts from an uncalibrated scorer |

Everything lands in `.spectra/` (SPECTRA-compatible layout): the plan, the state file
(the audit trail), the calibration log, the drift reports.

## What RAMZA is not

- **Not an executor.** Read-only during planning, always. Implementation belongs to a
  coder (in the Eidolons roster: Vivi). Handoffs ride ECL 2.0 envelopes.
- **Not ceremony.** The right-sizing gate exists to keep trivial work trivial — a
  trivial-tier plan over 120 lines *fails lint*.
- **Not benchmark theater.** RAMZA makes no outcome claims yet. Its rubric weights are
  instruments under calibration — which is why every scored gate logs to
  `ramza-calibration.jsonl` from day one.

## Install

```bash
bash install.sh /path/to/your/project        # EIIS 1.4; or via the Eidolons nexus:
eidolons add ramza                           # (once rostered)
```

Marker-bounded host wiring (Claude Code, Copilot, Cursor, opencode), manifest with
per-file SHA-256, idempotent re-runs. See `INSTALL.md` / `hosts/`.

## Model-tier doctrine (why this exists in the Fable era)

Frontier models hold the **boundaries** — plan authoring, judging, amendment. Executor
tiers get denser scaffolds and low-ambiguity contracts (the Aider lesson: pairing gains
are real *when the executor's output contract is unambiguous*). Escalation triggers are
deterministic, never model self-assessment. Blanket "big model plans, small model codes"
is explicitly refused — the evidence says it loses on coupled work.

## Docs

- `docs/methodology/SPEC.md` — the cycle (RS → S→P→E→C→T→R→A)
- `docs/methodology/tiers.md` — right-sizing tiers and what each mandates
- `docs/methodology/scoring.md` — rubrics as calibratable instruments
- `DESIGN-RATIONALE.md` — succession decisions D1–D8, evidence-mapped

## License

CC BY-SA 4.0. Fork it, adapt it, ship it — keep it open.
