# Wiring RAMZA into OpenCode

## 1. Install

```bash
# EIIS Eidolons framework (requires .opencode/ dir to exist in consumer project)
bash install.sh --hosts opencode
```

## 2. Config

OpenCode reads agent definitions from `.opencode/agents/`. The installer creates:

```
.opencode/agents/ramza.md
```

The agent file content:

```markdown
# RAMZA — Planning Specialist

Entry point: `.eidolons/ramza/agent.md`
Full spec: `.eidolons/ramza/SPEC.md`

RAMZA produces specifications, never code. RS right-sizes every request first —
ceremony scales with tier (trivial/lite/full), not a fixed complexity threshold.
```

**EIIS install creates:**
```
.eidolons/ramza/agent.md
.opencode/agents/ramza.md       ← dispatch file (if .opencode/ exists)
```

## 3. Verify

In OpenCode:

```
@ramza What are your hard constraints?
```

Expected: the agent identifies as RAMZA and lists the P0 constraints: READ-ONLY,
RS runs first (ceremony proportional to tier), every gate is a `bin/ramza-*`
tool call, dual-format output, confidence <85 → Refine (max 3 cycles),
spec-not-code, everything under `.spectra/`.

## 4. Mechanical enforcement

OpenCode's `permission` config (`opencode.json` at the project root, or the
global `~/.config/opencode/config.json`) supports per-tool rules, and — for
`edit` and `bash` — per-pattern rules within that tool, with **the last
matching rule winning**. This gives RAMZA's read-only constraint a real,
host-native enforcement layer instead of a prose promise:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "edit": {
      "*": "deny",
      ".spectra/plans/*.md": "allow"
    },
    "bash": {
      "*": "ask",
      "./bin/ramza-*": "allow",
      "git log*": "allow",
      "git diff*": "allow",
      "git show*": "allow"
    }
  }
}
```

This denies `edit` everywhere except RAMZA's own plan output
(`.spectra/plans/*.md` — still writable because a plan IS the deliverable, not
a mutation of the consumer project), auto-allows the `ramza-*` gate tools and
read-only git inspection, and falls back to `ask` for anything else `bash`
might attempt. Scope the `.spectra/plans/*.md` pattern further (e.g. to a
specific plan slug) if you want per-plan granularity.

If your installed OpenCode version predates path-scoped `edit` permissions,
the honest fallback is `"edit": "ask"` (forces confirmation on every edit,
with a project convention that confirmations are only granted for
`.spectra/plans/*.md`) — check the permission-config reference for your
version before relying on the pattern-map form above.

## 5. Troubleshooting

**Agent not detected:** OpenCode auto-discovery requires the `.opencode/`
directory to exist before running `install.sh`. Create it first:

```bash
mkdir .opencode
bash install.sh --hosts opencode
```

**File not created:** Verify `.opencode/agents/ramza.md` was written.
Re-run with `--force`: `bash install.sh --hosts opencode --force`.

**Entry point not loading:** Confirm `.eidolons/ramza/agent.md` exists in your
consumer project. If the EIIS install was run from a different working directory,
re-run: `bash install.sh --target ./.eidolons/ramza --hosts opencode`.

**Permission rules not applying:** Confirm `opencode.json`'s `$schema` points
at `https://opencode.ai/config.json` and that the file is at the project root
(or merged from the global config) — OpenCode reports the active permission
set with `opencode config show` (check your version's exact flag).
