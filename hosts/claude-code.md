# Wiring RAMZA into Claude Code

## 1. Install

```bash
# EIIS Eidolons framework — installs to ./.eidolons/ramza/
bash install.sh --hosts claude-code

# Direct RAMZA adoption — project analysis + adaptation prompts
bash install.sh /path/to/your/project
```

## 2. Config

After EIIS install, Claude Code finds RAMZA via your project's `CLAUDE.md`.
The installer appends this pointer automatically:

```markdown
## RAMZA Planning Agent

`@.eidolons/ramza/agent.md`
```

**Claude Code agent mode** (direct install):
```
.claude/agents/ramza.md
```

**Claude Code skill mode** (direct install):
```
.claude/skills/ramza-methodology/
```

**EIIS install path:**
```
.eidolons/ramza/agent.md               ← always-loaded entry
.eidolons/ramza/SPEC.md                ← full methodology
.eidolons/ramza/skills/methodology.md  ← quick routing card
.eidolons/ramza/skills/critic.md       ← maker≠checker critique protocol
.eidolons/ramza/templates/scoring.md   ← rubrics
.eidolons/ramza/bin/ramza-*            ← the mechanized gate tools
```

## 3. Verify

In Claude Code, run:

```
@.eidolons/ramza/agent.md What is your role and what are your hard constraints?
```

Expected: the agent identifies as RAMZA, the planning Eidolon (successor to
SPECTRA), states the READ-ONLY constraint, and describes the RS → S → P → E →
C → T → (R) → A cycle — RS first, every gate a `bin/ramza-*` tool call.

Or for direct install:
```
@ramza What phases do you run for a complex multi-service feature, and which
bin/ tool enforces each one?
```

## 4. Mechanical enforcement

RAMZA's read-only constraint is enforced two ways in a Claude Code host —
one already shipped, one optional defense-in-depth layer you wire yourself.

**Already shipped — the subagent's tool allowlist.** `.claude/agents/ramza.md`
declares `tools: Read, Grep, Glob, Bash` — no `Write`, no `Edit`. Claude Code
enforces this at tool-dispatch time: a `Task` invocation routed to the `ramza`
subagent cannot call `Write`/`Edit` at all, independent of any hook. This is
the durable guarantee; everything below is optional extra insurance for setups
where RAMZA runs in a shared/root context instead of the scoped subagent (e.g.
skill mode, where the host model keeps its full tool set).

**Recommended for interactive sessions — Plan Mode.** When driving RAMZA
directly from the top-level conversation (not via subagent dispatch), run the
session in Claude Code's built-in Plan Mode (`--permission-mode plan`, or the
Shift+Tab toggle interactively). Plan Mode requires explicit approval before
any `Write`/`Edit`/`Bash`-mutation call, which matches RAMZA's own P0 — use it
as the default posture for planning sessions rather than relying on prose
self-restraint.

**Optional — a `PreToolUse` hook shim.** For projects that want a mechanical
backstop even when neither of the above applies, add a hook that denies
`Write`/`Edit` while RAMZA is the active (sub)agent:

`.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "command", "command": "./.eidolons/ramza/hooks/deny-if-ramza.sh" }
        ]
      }
    ]
  }
}
```

`.eidolons/ramza/hooks/deny-if-ramza.sh` (illustrative — not shipped by
`install.sh`; write it yourself if you want this layer):
```bash
#!/usr/bin/env bash
set -eu
INPUT="$(cat)"
TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')"
# The field that identifies "which (sub)agent is active" is not part of a
# stable, versioned hook-payload contract as of this writing — check the
# Claude Code hooks reference for your installed version before relying on
# this. Adjust the jq path below (or the detection strategy entirely, e.g.
# a marker file written when the ramza agent starts) to match what your
# version actually sends.
AGENT="$(printf '%s' "$INPUT" | jq -r '.subagent_type // .agent // empty')"
case "$TOOL" in
  Write|Edit)
    if [ "$AGENT" = "ramza" ]; then
      echo "RAMZA is read-only: Write/Edit denied while the ramza agent is active." >&2
      exit 2   # non-zero exit on PreToolUse blocks the call
    fi
    ;;
esac
exit 0
```

This hook is honest about its own limits: it is a best-effort backstop, not
the primary guarantee. The primary guarantee is the tools: allowlist above.
See Claude Code's hooks reference for the current `PreToolUse` payload shape
before deploying this in a real project.

## 5. Troubleshooting

**Agent not found:** Verify `.eidolons/ramza/agent.md` exists. Re-run `bash install.sh --force`.

**Wrong file loaded:** Check `CLAUDE.md` contains the `@.eidolons/ramza/agent.md` pointer.
The pointer must be in `CLAUDE.md` at the project root, not only in `.claude/`.

**Skill mode not activating:** Confirm RAMZA files are at `.claude/skills/ramza-methodology/`
(direct install) or `.eidolons/ramza/` (EIIS install). See `INSTALL.md` for the full path matrix.

**Token budget:** `agent.md` is ≤1000 tokens by design. If Claude Code truncates context,
load `SPEC.md` explicitly: `@.eidolons/ramza/SPEC.md`.
