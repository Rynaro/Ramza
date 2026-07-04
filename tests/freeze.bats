#!/usr/bin/env bats
# tests/freeze.bats — behavioral tests for bin/ramza-freeze.

load helpers

setup() {
  ramza_setup_repo
  state="$BATS_TEST_TMPDIR/state.json"
  criteria="$BATS_TEST_TMPDIR/criteria.md"
  init_state "$state"
  printf '# criteria\nAC-001 ok\n' > "$criteria"
}

teardown() {
  ramza_teardown_repo
}

@test "freeze: freeze then verify passes" {
  run ramza-freeze --state "$state" --criteria "$criteria"
  [ "$status" -eq 0 ]
  [[ "$output" == *"frozen:"* ]]
  hash="$(jq -r '.criteria_sha256' "$state")"
  [ -n "$hash" ] && [ "$hash" != "null" ]

  run ramza-freeze --state "$state" --criteria "$criteria" --verify
  [ "$status" -eq 0 ]
  [[ "$output" == *"criteria match frozen hash"* ]]
}

@test "freeze: second freeze without --amend is DENY (exit 1)" {
  ramza-freeze --state "$state" --criteria "$criteria"
  run ramza-freeze --state "$state" --criteria "$criteria"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DENY"* ]]
  [[ "$output" == *"already frozen"* ]]
}

@test "freeze: tampering after freeze fails verify with DRIFT (exit 1)" {
  ramza-freeze --state "$state" --criteria "$criteria"
  printf 'AC-002 tampered in\n' >> "$criteria"
  run ramza-freeze --state "$state" --criteria "$criteria" --verify
  [ "$status" -eq 1 ]
  [[ "$output" == *"DRIFT"* ]]
  [[ "$output" == *"hash mismatch"* ]]
}

@test "freeze: --amend without --reason is DENY (exit 1)" {
  ramza-freeze --state "$state" --criteria "$criteria"
  printf 'AC-002 new\n' >> "$criteria"
  run ramza-freeze --state "$state" --criteria "$criteria" --amend
  [ "$status" -eq 1 ]
  [[ "$output" == *"DENY"* ]]
  [[ "$output" == *"--amend requires --reason"* ]]
}

@test "freeze: --amend before any initial freeze is DENY (exit 1)" {
  run ramza-freeze --state "$state" --criteria "$criteria" --amend --reason "no prior freeze"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DENY"* ]]
  [[ "$output" == *"cannot amend before an initial freeze"* ]]
}

@test "freeze: --amend with --reason updates the hash and records exactly one amendment; verify is green after" {
  ramza-freeze --state "$state" --criteria "$criteria"
  prev="$(jq -r '.criteria_sha256' "$state")"
  printf 'AC-002 new\n' >> "$criteria"

  run ramza-freeze --state "$state" --criteria "$criteria" --amend --reason "added AC-002 after Assemble review"
  [ "$status" -eq 0 ]
  new="$(jq -r '.criteria_sha256' "$state")"
  [ "$new" != "$prev" ]
  [ "$(jq '.amendments | length' "$state")" -eq 1 ]
  [ "$(jq -r '.amendments[0].prev' "$state")" = "$prev" ]
  [ "$(jq -r '.amendments[0].new' "$state")" = "$new" ]
  [ "$(jq -r '.amendments[0].reason' "$state")" = "added AC-002 after Assemble review" ]

  run ramza-freeze --state "$state" --criteria "$criteria" --verify
  [ "$status" -eq 0 ]
}
