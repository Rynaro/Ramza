#!/usr/bin/env bats
# tests/gate.bats — behavioral tests for bin/ramza-gate, the phase state machine.

load helpers

setup() {
  ramza_setup_repo
  state="$BATS_TEST_TMPDIR/state.json"
}

teardown() {
  ramza_teardown_repo
}

# --- happy walks -------------------------------------------------------------

@test "gate: trivial tier happy walk RS -> S -> C -> A" {
  ramza-gate init --plan demo --tier trivial --state "$state"
  [ "$(jq -r '.phase' "$state")" = "RS" ]

  run ramza-gate advance --to S --state "$state"
  [ "$status" -eq 0 ]
  run ramza-gate advance --to C --state "$state"
  [ "$status" -eq 0 ]
  run ramza-gate advance --to A --state "$state"
  [ "$status" -eq 0 ]

  [ "$(jq -r '.phase' "$state")" = "A" ]
  [ "$(jq -r '.phases_done | join(",")' "$state")" = "RS,S,C,A" ]
  [ "$(jq '.skips | length' "$state")" -eq 0 ]
}

@test "gate: lite tier happy walk RS -> S -> P -> E -> C -> T -> A" {
  ramza-gate init --plan demo --tier lite --state "$state"
  for p in S P E C T A; do
    run ramza-gate advance --to "$p" --state "$state"
    [ "$status" -eq 0 ]
  done
  [ "$(jq -r '.phase' "$state")" = "A" ]
  [ "$(jq -r '.phases_done | join(",")' "$state")" = "RS,S,P,E,C,T,A" ]
  [ "$(jq '.skips | length' "$state")" -eq 0 ]
}

@test "gate: next reports the mandatory phase sequence for trivial tier" {
  ramza-gate init --plan demo --tier trivial --state "$state"
  run ramza-gate next --state "$state"
  [ "$status" -eq 0 ]
  [ "$output" = "S" ]

  ramza-gate advance --to S --state "$state"
  run ramza-gate next --state "$state"
  [ "$output" = "C" ]

  ramza-gate advance --to C --state "$state"
  run ramza-gate next --state "$state"
  [ "$output" = "A" ]

  ramza-gate advance --to A --state "$state"
  run ramza-gate next --state "$state"
  [ "$output" = "DONE" ]
}

@test "gate: status reports tier, phase and next" {
  ramza-gate init --plan demo --tier lite --state "$state"
  ramza-gate advance --to S --state "$state"
  run ramza-gate status --state "$state"
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | jq -r '.tier')" = "lite" ]
  [ "$(printf '%s' "$output" | jq -r '.phase')" = "S" ]
  [ "$(printf '%s' "$output" | jq -r '.next')" = "P" ]
}

# --- ordering rules ------------------------------------------------------------

@test "gate: advancing past mandatory phases without --reason is DENY (exit 1)" {
  ramza-gate init --plan demo --tier lite --state "$state"
  run ramza-gate advance --to E --state "$state"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DENY"* ]]
  [[ "$output" == *"skips mandatory phase"* ]]
  # denied transitions must not mutate state
  [ "$(jq -r '.phase' "$state")" = "RS" ]
}

@test "gate: skip-with-reason records the skipped mandatory phases in skips[]" {
  ramza-gate init --plan demo --tier lite --state "$state"
  run ramza-gate advance --to E --state "$state" \
    --reason "fast-track: S and P validated out of band"
  [ "$status" -eq 0 ]
  [ "$(jq -r '.phase' "$state")" = "E" ]
  [ "$(jq '.skips | length' "$state")" -eq 2 ]
  [ "$(jq -r '.skips[0].phase' "$state")" = "S" ]
  [ "$(jq -r '.skips[0].mandatory' "$state")" = "true" ]
  [ "$(jq -r '.skips[0].reason' "$state")" = "fast-track: S and P validated out of band" ]
  [ "$(jq -r '.skips[1].phase' "$state")" = "P" ]
}

@test "gate: backwards move is DENY (exit 1)" {
  ramza-gate init --plan demo --tier trivial --state "$state"
  ramza-gate advance --to S --state "$state"
  ramza-gate advance --to C --state "$state"
  run ramza-gate advance --to S --state "$state"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DENY"* ]]
  [[ "$output" == *"cannot move backwards"* ]]
  [ "$(jq -r '.phase' "$state")" = "C" ]
}

@test "gate: re-entering the current phase is DENY (exit 1)" {
  ramza-gate init --plan demo --tier trivial --state "$state"
  ramza-gate advance --to S --state "$state"
  run ramza-gate advance --to S --state "$state"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DENY"* ]]
}

@test "gate: advance --to R is always DENY (must use refine)" {
  ramza-gate init --plan demo --tier lite --state "$state"
  run ramza-gate advance --to R --state "$state"
  [ "$status" -eq 1 ]
  [[ "$output" == *"entered via 'ramza-gate refine'"* ]]
}

@test "gate: DONE state permits no further transitions" {
  ramza-gate init --plan demo --tier trivial --state "$state"
  ramza-gate advance --to S --state "$state"
  ramza-gate advance --to C --state "$state"
  ramza-gate advance --to A --state "$state"
  ramza-gate advance --to DONE --state "$state"
  run ramza-gate advance --to DONE --state "$state"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DENY"* ]]
  [[ "$output" == *"plan is DONE"* ]]
}

# --- refine cycle --------------------------------------------------------------

@test "gate: refine is denied unless current phase is T" {
  ramza-gate init --plan demo --tier trivial --state "$state"
  run ramza-gate refine --state "$state"
  [ "$status" -eq 1 ]
  [[ "$output" == *"refine is entered from T only"* ]]
}

@test "gate: refine cap allows 3 cycles then DENY on the 4th" {
  ramza-gate init --plan demo --tier lite --state "$state"
  for p in S P E C T; do ramza-gate advance --to "$p" --state "$state"; done

  run ramza-gate refine --state "$state"          # cycle 1
  [ "$status" -eq 0 ]
  [ "$(jq -r '.phase' "$state")" = "R" ]
  [ "$(jq -r '.refine_cycles' "$state")" -eq 1 ]
  ramza-gate advance --to T --state "$state"

  run ramza-gate refine --state "$state"          # cycle 2
  [ "$status" -eq 0 ]
  ramza-gate advance --to T --state "$state"

  run ramza-gate refine --state "$state"          # cycle 3
  [ "$status" -eq 0 ]
  [ "$(jq -r '.refine_cycles' "$state")" -eq 3 ]
  ramza-gate advance --to T --state "$state"

  run ramza-gate refine --state "$state"          # cycle 4: cap reached
  [ "$status" -eq 1 ]
  [[ "$output" == *"refine cycle cap"* ]]
  [ "$(jq -r '.refine_cycles' "$state")" -eq 3 ]
  [ "$(jq -r '.phase' "$state")" = "T" ]
}

# --- critic gate -----------------------------------------------------------------

@test "gate: critic self-approval is DENY (maker != checker)" {
  ramza-gate init --plan demo --tier full --state "$state"
  run ramza-gate critic --author agent-a --checker agent-a --state "$state"
  [ "$status" -eq 1 ]
  [[ "$output" == *"maker!=checker violated"* ]]
  [ "$(jq -r '.critic.checker // "null"' "$state")" = "null" ]
}

@test "gate: full tier denies advance to A without a critic record, allows it with one" {
  ramza-gate init --plan demo --tier full --state "$state"
  for p in S P E C T; do ramza-gate advance --to "$p" --state "$state"; done

  run ramza-gate advance --to A --state "$state"
  [ "$status" -eq 1 ]
  [[ "$output" == *"requires a critic record"* ]]

  run ramza-gate critic --author agent-a --checker agent-b --state "$state"
  [ "$status" -eq 0 ]
  [ "$(jq -r '.critic.author' "$state")" = "agent-a" ]
  [ "$(jq -r '.critic.checker' "$state")" = "agent-b" ]

  run ramza-gate advance --to A --state "$state"
  [ "$status" -eq 0 ]
  [ "$(jq -r '.phase' "$state")" = "A" ]
}
