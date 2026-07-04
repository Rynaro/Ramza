# Wiring RAMZA into Cursor

## 1. Install

```bash
# EIIS Eidolons framework (requires .cursor/ dir to exist in consumer project)
bash install.sh --hosts cursor

# Direct RAMZA adoption
bash install.sh /path/to/your/project
# then select vendor: cursor
```

## 2. Config

Cursor loads rules from `.cursor/rules/*.mdc`. The installer creates:

```
.cursor/rules/ramza.mdc
```

The rule file content:

```markdown
---
description: RAMZA planning methodology
alwaysApply: false
---

# RAMZA — Planning Specialist

Entry point: `.eidolons/ramza/agent.md`
Full spec: `.eidolons/ramza/SPEC.md`

RAMZA produces specifications, never code. RS right-sizes every request first —
activate for anything beyond a trivial-tier change.
```

**Cursor agent mode** (direct install):
```
.cursor/agents/ramza.mdc
```

## 3. Verify

In Cursor Chat:

```
@ramza What is the RAMZA cycle? List all phases and the tool that gates each one.
```

Or referencing the rule directly:

```
Using RAMZA (see .cursor/rules/ramza.mdc), outline the planning phases
for adding OAuth2 to an existing REST API.
```

Expected: the agent describes the full RS → S → P → E → C → T → (R) → A
cycle, names the `bin/ramza-*` tool for each gate, and states the READ-ONLY
constraint.

## 4. Mechanical enforcement

**Honest note:** Cursor's `.cursor/rules/*.mdc` mechanism is a prompt-level
instruction, not a permission system Cursor enforces against tool calls —
unlike Claude Code's subagent `tools:` allowlist or OpenCode's `permission`
config, there is no Cursor-native gate that can make a `Write`/`Edit` call
mechanically impossible while the `ramza` rule is loaded. Cursor staff have
themselves acknowledged Plan Mode being violated by their own agent as an open
issue (see `DESIGN-RATIONALE.md` D1) — the rule file is convention, not
enforcement.

What IS mechanical here is downstream, after the fact: run `ramza-drift`
against the executed diff to catch a violation rather than prevent it —

```bash
bin/ramza-drift --state .spectra/plans/<slug>.state.json --range <base>..<head>
# or: --staged / (bare, worktree-vs-HEAD)
```

— which fails (exit 1) on any changed file outside the plan's declared scope,
including code changes RAMZA itself was never supposed to make. Wire this as
a CI check or a pre-merge convention so an ignored read-only instruction still
gets caught, even though it can't be blocked in the moment.

## 5. Troubleshooting

**Rule not loading:** Check `.cursor/rules/ramza.mdc` exists. Cursor requires
`.mdc` extension for rules. Verify "Rules for AI" is enabled in
Cursor Settings → Features → Rules for AI.

**Agent not found in @mentions:** Cursor agent mode requires `.cursor/agents/`.
Run `bash install.sh`, select `cursor` + `agent` mode.

**`.cursor/` not detected:** The EIIS installer checks for `.cursor/` directory
or `.cursorrules` file. If neither exists in your project, the cursor dispatch
file is skipped. Create `.cursor/` first, then re-run `bash install.sh --hosts cursor`.

**Windows path separators:** Run bash via WSL or Git Bash; forward slashes
are used internally by the installer.
