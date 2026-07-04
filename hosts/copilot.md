# Wiring RAMZA into GitHub Copilot

## 1. Install

```bash
# EIIS Eidolons framework
bash install.sh --hosts copilot

# Direct RAMZA adoption (also creates .github/agents/ entry)
bash install.sh /path/to/your/project
# then select vendor: copilot
```

## 2. Config

Copilot reads `.github/copilot-instructions.md` as custom instructions.
The installer creates or appends this file automatically:

```markdown
## RAMZA Planning Agent

The RAMZA planning agent is installed at `.eidolons/ramza/`.
Entry point: `.eidolons/ramza/agent.md`
Full spec: `.eidolons/ramza/SPEC.md`
```

**Copilot agent mode** (`.github/agents/`):
```
.github/agents/ramza.agent.md
```

**EIIS install creates:**
```
.eidolons/ramza/agent.md
.github/copilot-instructions.md   ← created or appended
```

## 3. Verify

In a GitHub Copilot Chat or Copilot Workspace session:

```
Using the RAMZA methodology at .eidolons/ramza/agent.md, what phases
should I run for a complex multi-service feature, and which tool gates each one?
```

Expected: Copilot describes the RS → S → P → E → C → T → (R) → A cycle,
names the `bin/ramza-*` tool per gate, and references the installed files.

## 4. Mechanical enforcement

**Honest note:** `.github/copilot-instructions.md` and the `.github/agents/`
agent file are prompt-level instructions — Copilot has no equivalent of
Claude Code's subagent `tools:` allowlist or OpenCode's `permission` config
that can make a `Write`/`Edit`-shaped action mechanically impossible while
RAMZA's instructions are loaded. Treat the READ-ONLY constraint here as
convention, honestly, not enforcement (the same posture the market-wide
evidence in `DESIGN-RATIONALE.md` D1 documents for prompted constraints
generally).

The mechanical backstop is the same one recommended for Cursor: catch a
violation after the fact rather than assume it can't happen. Run
`ramza-drift` against the executed diff —

```bash
bin/ramza-drift --state .spectra/plans/<slug>.state.json --range <base>..<head>
```

— in CI or as a pre-merge convention. Any file changed outside the plan's
declared scope fails the check (exit 1), which is the closest thing to
enforcement available in a host that can't gate tool calls directly.

## 5. Troubleshooting

**Instructions not loading:** Verify `.github/copilot-instructions.md` exists
and references `.eidolons/ramza/agent.md`. Copilot must have "custom instructions"
enabled (Settings → Copilot → Custom Instructions).

**File size limits:** If Copilot truncates the instructions, keep only the
`agent.md` pointer in `.github/copilot-instructions.md`. Load `SPEC.md`
on demand by pasting its path into the chat: `.eidolons/ramza/SPEC.md`.

**Workspace agent not found:** Copilot Workspace agent mode requires
`.github/agents/ramza.agent.md`. Run the direct installer
(`install.sh`, select `copilot`, select `agent` mode) to create it.
