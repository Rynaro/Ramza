#!/usr/bin/env bash
# tests/helpers.bash — shared test helpers for the RAMZA bats suite.
# bash 3.2 compatible (no associative arrays, no ${var,,}, no mapfile) to mirror
# the compatibility bar the bin/ramza-* scripts themselves hold to.

RAMZA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export RAMZA_ROOT

# Put RAMZA's bin/ at the front of PATH so every test invokes the checkout's
# scripts (ramza-rightsize, ramza-gate, ...) rather than anything installed
# elsewhere on the system.
export PATH="${RAMZA_ROOT}/bin:${PATH}"

# ramza_setup_repo
# Creates a fresh temp dir, git-inits it with a base commit, and cd's into it.
# Sets RAMZA_TMPDIR (removed by ramza_teardown_repo). Call from setup().
ramza_setup_repo() {
  RAMZA_TMPDIR="$(mktemp -d)"
  cd "$RAMZA_TMPDIR" || return 1
  git init -q .
  git config user.email "ramza-tests@example.com"
  git config user.name "Ramza Tests"
  git config commit.gpgsign false
  printf 'seed\n' > README.md
  git add README.md
  git commit -q -m "initial commit"
}

# ramza_teardown_repo
# Removes the temp dir created by ramza_setup_repo. Call from teardown().
ramza_teardown_repo() {
  cd "$RAMZA_ROOT" 2>/dev/null || cd /
  if [ -n "${RAMZA_TMPDIR:-}" ] && [ -d "${RAMZA_TMPDIR}" ]; then
    rm -rf "${RAMZA_TMPDIR}"
  fi
}

# init_state <state-file> [extra ramza-rightsize args...]
# Initialises a plan-state file via `ramza-rightsize --state`, defaulting to a
# trivial-tier plan (files-est 1, plan "test-plan"). Extra args are appended
# after the defaults, so callers can override a default flag (ramza-rightsize's
# arg parser is last-one-wins) or add more (e.g. --force, --override/--reason).
init_state() {
  _state="$1"; shift
  ramza-rightsize --files-est 1 --plan test-plan --state "$_state" "$@"
}
