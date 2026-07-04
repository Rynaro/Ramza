#!/usr/bin/env bats
# tests/rightsize.bats — behavioral tests for bin/ramza-rightsize.

load helpers

setup() {
  ramza_setup_repo
}

teardown() {
  ramza_teardown_repo
}

@test "rightsize: files-est 1, low stakes -> trivial (score 0)" {
  run ramza-rightsize --files-est 1 --stakes low
  [ "$status" -eq 0 ]
  [ "$output" = "trivial" ]
}

@test "rightsize: files-est 6 + public-api + stakes med -> lite (score 3)" {
  run ramza-rightsize --files-est 6 --public-api --stakes med
  [ "$status" -eq 0 ]
  [ "$output" = "lite" ]
}

@test "rightsize: files-est 12 + migration + security + stakes high -> full (score 6)" {
  run ramza-rightsize --files-est 12 --migration --security --stakes high
  [ "$status" -eq 0 ]
  [ "$output" = "full" ]
}

@test "rightsize: --override without --reason fails" {
  run ramza-rightsize --files-est 1 --override full
  [ "$status" -eq 2 ]
  [[ "$output" == *"--override requires --reason"* ]]
}

@test "rightsize: --override with --reason records the override and prints the override tier" {
  run ramza-rightsize --files-est 1 --override full --reason "known high blast radius despite small file count"
  [ "$status" -eq 0 ]
  # stdout carries only the final tier; the "override: computed X -> Y" note
  # goes to stderr, and `run` merges both streams into $output/$lines.
  # (bash 3.2 compatible: no ${array[-1]} negative indexing.)
  last_line="${lines[$((${#lines[@]} - 1))]}"
  [ "$last_line" = "full" ]
  [[ "$output" == *"override: computed trivial -> full"* ]]
}

@test "rightsize: --state creates the plan-state file with tier + rightsize block" {
  state="$BATS_TEST_TMPDIR/state.json"
  run ramza-rightsize --files-est 6 --public-api --stakes med --plan demo --state "$state"
  [ "$status" -eq 0 ]
  [ -f "$state" ]
  [ "$(jq -r '.schema' "$state")" = "ramza/plan-state.v1" ]
  [ "$(jq -r '.plan' "$state")" = "demo" ]
  [ "$(jq -r '.tier' "$state")" = "lite" ]
  [ "$(jq -r '.phase' "$state")" = "RS" ]
  [ "$(jq -r '.phases_done | join(",")' "$state")" = "RS" ]
  [ "$(jq -r '.rightsize.score' "$state")" -eq 3 ]
  [ "$(jq -r '.rightsize.computed_tier' "$state")" = "lite" ]
  [ "$(jq -r '.rightsize.inputs.files_est' "$state")" -eq 6 ]
  [ "$(jq -r '.rightsize.inputs.public_api' "$state")" = "true" ]
  [ "$(jq -r '.rightsize.inputs.stakes' "$state")" = "med" ]
}

@test "rightsize: --state records the override block distinctly from the computed tier" {
  state="$BATS_TEST_TMPDIR/state.json"
  run ramza-rightsize --files-est 1 --plan demo --state "$state" \
    --override full --reason "escalate proactively"
  [ "$status" -eq 0 ]
  [ "$(jq -r '.tier' "$state")" = "full" ]
  [ "$(jq -r '.rightsize.computed_tier' "$state")" = "trivial" ]
  # note: the override record nests under .rightsize.override, not top-level .override
  [ "$(jq -r '.rightsize.override.tier' "$state")" = "full" ]
  [ "$(jq -r '.rightsize.override.reason' "$state")" = "escalate proactively" ]
}

@test "rightsize: existing state without --force fails" {
  state="$BATS_TEST_TMPDIR/state.json"
  init_state "$state"
  run ramza-rightsize --files-est 1 --plan test-plan --state "$state"
  [ "$status" -eq 2 ]
  [[ "$output" == *"state file exists"* ]]
}

@test "rightsize: existing state with --force re-initialises" {
  state="$BATS_TEST_TMPDIR/state.json"
  init_state "$state"
  run ramza-rightsize --files-est 12 --migration --security --stakes high \
    --plan test-plan --state "$state" --force
  [ "$status" -eq 0 ]
  [ "$(jq -r '.tier' "$state")" = "full" ]
}
