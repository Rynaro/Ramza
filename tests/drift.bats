#!/usr/bin/env bats
# tests/drift.bats — behavioral tests for bin/ramza-drift (plan-vs-diff drift check).
#
# The plan-state file is deliberately kept OUTSIDE the git repo under test
# (at $BATS_TEST_TMPDIR, a sibling of the repo at $RAMZA_TMPDIR) so that the
# state file itself never shows up as an untracked change in `git status`,
# which would otherwise pollute every drift assertion below.

load helpers

setup() {
  ramza_setup_repo
  state="$BATS_TEST_TMPDIR/state.json"
  init_state "$state"
}

teardown() {
  ramza_teardown_repo
}

@test "drift: --declare records the scope globs" {
  run ramza-drift --state "$state" --declare "src/* docs/*.md"
  [ "$status" -eq 0 ]
  [ "$(jq '.declared_scope | length' "$state")" -eq 2 ]
  [ "$(jq -r '.declared_scope[0]' "$state")" = "src/*" ]
  [ "$(jq -r '.declared_scope[1]' "$state")" = "docs/*.md" ]
}

@test "drift: a covered change (tracked edit inside declared scope) passes" {
  mkdir -p src
  printf 'x = 1\n' > src/main.sh
  git add src/main.sh
  git commit -qm "add src/main.sh"
  ramza-drift --state "$state" --declare "src/*"

  printf 'x = 2\n' >> src/main.sh   # tracked, uncommitted edit, inside scope

  run ramza-drift --state "$state"
  [ "$status" -eq 0 ]
  [[ "$output" == *"all within declared scope"* ]]
  [ "$(jq '.drift_reports | length' "$state")" -eq 1 ]
  [ "$(jq '.drift_reports[0].uncovered | length' "$state")" -eq 0 ]
}

@test "drift: an uncovered NEW untracked file is caught (exit 1)" {
  ramza-drift --state "$state" --declare "src/*"

  printf 'stray\n' > stray.txt   # new, untracked, outside declared scope

  run ramza-drift --state "$state"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DRIFT"* ]]
  [[ "$output" == *"stray.txt"* ]]
  [ "$(jq -r '.drift_reports[0].uncovered[0]' "$state")" = "stray.txt" ]
}

@test "drift: .spectra/* is allowed by default even when outside declared scope" {
  ramza-drift --state "$state" --declare "src/*"

  mkdir -p .spectra/plans
  printf '{}\n' > .spectra/plans/scratch.json   # untracked, outside src/*, default-allowed

  run ramza-drift --state "$state"
  [ "$status" -eq 0 ]
  [[ "$output" == *"all within declared scope"* ]]
}

@test "drift: --range mode over a commit range catches an out-of-scope committed file" {
  ramza-drift --state "$state" --declare "src/*"
  base="$(git rev-parse HEAD)"

  mkdir -p src other
  printf 'a\n' > src/a.sh
  printf 'b\n' > other/b.sh
  git add src/a.sh other/b.sh
  git commit -qm "add in-scope and out-of-scope files"

  run ramza-drift --state "$state" --range "${base}..HEAD"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DRIFT"* ]]
  [[ "$output" == *"other/b.sh"* ]]
  [[ "$output" != *"  - src/a.sh"* ]]
}

@test "drift: check without a declared scope dies (exit 2)" {
  fresh_state="$BATS_TEST_TMPDIR/fresh-state.json"
  init_state "$fresh_state" --plan other-plan
  run ramza-drift --state "$fresh_state"
  [ "$status" -eq 2 ]
  [[ "$output" == *"no declared scope"* ]]
}
