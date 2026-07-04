#!/usr/bin/env bats
# tests/score.bats — behavioral tests for bin/ramza-score, the rubric arithmetic.

load helpers

setup() {
  ramza_setup_repo
  dims="$BATS_TEST_TMPDIR/dims.json"
}

teardown() {
  ramza_teardown_repo
}

# --- explore -------------------------------------------------------------------

@test "score: explore rubric arithmetic is exact (total 77.5, solid, exit 0)" {
  printf '{"alignment":9,"correctness":8,"maintainability":7,"performance":7,"simplicity":8,"risk":7,"innovation":6}' > "$dims"
  run ramza-score --rubric explore --in "$dims"
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | jq -r '.total')" = "77.5" ]
  [ "$(printf '%s' "$output" | jq -r '.verdict')" = "solid" ]
  [ "$(printf '%s' "$output" | jq -r '.rubric')" = "explore" ]
}

@test "score: explore rubric weak verdict exits 1" {
  printf '{"alignment":1,"correctness":1,"maintainability":1,"performance":1,"simplicity":1,"risk":1,"innovation":1}' > "$dims"
  run ramza-score --rubric explore --in "$dims"
  [ "$status" -eq 1 ]
  [ "$(printf '%s' "$output" | jq -r '.verdict')" = "weak" ]
  [ "$(printf '%s' "$output" | jq -r '.total')" = "10" ]
}

@test "score: explore rubric missing dimension dies (exit 2)" {
  printf '{"alignment":9,"correctness":8,"maintainability":7,"performance":7,"simplicity":8,"risk":7}' > "$dims"
  run ramza-score --rubric explore --in "$dims"
  [ "$status" -eq 2 ]
  [[ "$output" == *"missing dimension: innovation"* ]]
}

@test "score: explore rubric out-of-range dimension dies (exit 2)" {
  printf '{"alignment":11,"correctness":8,"maintainability":7,"performance":7,"simplicity":8,"risk":7,"innovation":6}' > "$dims"
  run ramza-score --rubric explore --in "$dims"
  [ "$status" -eq 2 ]
  [[ "$output" == *"must be a number in [1,10]"* ]]
}

# --- confidence ------------------------------------------------------------------

@test "score: confidence verdict is AUTO_PROCEED at 85 (exit 0)" {
  printf '{"pattern_match":85,"requirement_clarity":85,"decomposition_stability":85,"constraint_compliance":85}' > "$dims"
  run ramza-score --rubric confidence --in "$dims"
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | jq -r '.verdict')" = "AUTO_PROCEED" ]
  [ "$(printf '%s' "$output" | jq -r '.total')" = "85" ]
}

@test "score: confidence verdict is ESCALATE at 49 (exit 1)" {
  printf '{"pattern_match":49,"requirement_clarity":49,"decomposition_stability":49,"constraint_compliance":49}' > "$dims"
  run ramza-score --rubric confidence --in "$dims"
  [ "$status" -eq 1 ]
  [ "$(printf '%s' "$output" | jq -r '.verdict')" = "ESCALATE" ]
  [ "$(printf '%s' "$output" | jq -r '.total')" = "49" ]
}

# --- complexity ------------------------------------------------------------------

@test "score: complexity sums the four dims and routes standard/extended/human_loop" {
  printf '{"scope":1,"ambiguity":1,"dependencies":1,"risk":1}' > "$dims"
  run ramza-score --rubric complexity --in "$dims"
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | jq -r '.total')" = "4" ]
  [ "$(printf '%s' "$output" | jq -r '.verdict')" = "standard" ]

  printf '{"scope":2,"ambiguity":2,"dependencies":2,"risk":2}' > "$dims"
  run ramza-score --rubric complexity --in "$dims"
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | jq -r '.total')" = "8" ]
  [ "$(printf '%s' "$output" | jq -r '.verdict')" = "extended" ]

  printf '{"scope":3,"ambiguity":3,"dependencies":3,"risk":3}' > "$dims"
  run ramza-score --rubric complexity --in "$dims"
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | jq -r '.total')" = "12" ]
  [ "$(printf '%s' "$output" | jq -r '.verdict')" = "human_loop" ]
}

# --- refine --------------------------------------------------------------------

@test "score: refine cycle 1 passes when the minimum dimension is >= 3" {
  printf '{"clarity":3,"completeness":5,"actionability":5,"efficiency":5,"testability":5}' > "$dims"
  run ramza-score --rubric refine --in "$dims" --cycle 1
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | jq -r '.verdict')" = "pass" ]
  [ "$(printf '%s' "$output" | jq -r '.min')" = "3" ]
}

@test "score: refine cycle 1 fails when the minimum dimension is < 3" {
  printf '{"clarity":2,"completeness":5,"actionability":5,"efficiency":5,"testability":5}' > "$dims"
  run ramza-score --rubric refine --in "$dims" --cycle 1
  [ "$status" -eq 1 ]
  [ "$(printf '%s' "$output" | jq -r '.verdict')" = "fail" ]
}

@test "score: refine cycle 2 requires min >= 4 (cycle-1-passing input now fails)" {
  printf '{"clarity":3,"completeness":5,"actionability":5,"efficiency":5,"testability":5}' > "$dims"
  run ramza-score --rubric refine --in "$dims" --cycle 2
  [ "$status" -eq 1 ]
  [ "$(printf '%s' "$output" | jq -r '.verdict')" = "fail" ]
}

# --- --state / --log side effects -------------------------------------------------

@test "score: --state appends the verdict to gates[]" {
  state="$BATS_TEST_TMPDIR/state.json"
  init_state "$state"
  printf '{"alignment":9,"correctness":8,"maintainability":7,"performance":7,"simplicity":8,"risk":7,"innovation":6}' > "$dims"
  run ramza-score --rubric explore --in "$dims" --state "$state" --label "first-pass"
  [ "$status" -eq 0 ]
  [ "$(jq '.gates | length' "$state")" -eq 1 ]
  [ "$(jq -r '.gates[0].rubric' "$state")" = "explore" ]
  [ "$(jq -r '.gates[0].verdict' "$state")" = "solid" ]
  [ "$(jq -r '.gates[0].label' "$state")" = "first-pass" ]
}

@test "score: --state defaults the calibration JSONL log alongside it" {
  state="$BATS_TEST_TMPDIR/state.json"
  init_state "$state"
  printf '{"alignment":9,"correctness":8,"maintainability":7,"performance":7,"simplicity":8,"risk":7,"innovation":6}' > "$dims"
  run ramza-score --rubric explore --in "$dims" --state "$state"
  [ "$status" -eq 0 ]
  log="$BATS_TEST_TMPDIR/ramza-calibration.jsonl"
  [ -f "$log" ]
  [ "$(wc -l < "$log" | tr -d ' ')" -eq 1 ]
  [ "$(jq -r '.rubric' "$log")" = "explore" ]
}

@test "score: --log appends across repeated runs" {
  log="$BATS_TEST_TMPDIR/calib.jsonl"
  printf '{"alignment":9,"correctness":8,"maintainability":7,"performance":7,"simplicity":8,"risk":7,"innovation":6}' > "$dims"
  run ramza-score --rubric explore --in "$dims" --log "$log"
  [ "$status" -eq 0 ]
  run ramza-score --rubric explore --in "$dims" --log "$log"
  [ "$status" -eq 0 ]
  [ "$(wc -l < "$log" | tr -d ' ')" -eq 2 ]
}
