#!/usr/bin/env bats
# Behavioral tests for ramza-adherence and ramza-calibrate.

load helpers

setup() {
  ramza_setup_repo
}

teardown() {
  ramza_teardown_repo
}

# ── ramza-adherence ──────────────────────────────────────────────────────────

@test "adherence: clean lite walk with covered drift scores composite 1.0" {
  state=".spectra/plans/p.state.json"
  init_state "$state" --files-est 6 --public-api --stakes med   # lite tier
  for ph in S P E C T A; do ramza-gate advance --state "$state" --to "$ph"; done
  ramza-drift --state "$state" --declare 'src/*'
  mkdir -p src && echo x > src/a.txt
  ramza-drift --state "$state"
  run ramza-adherence --state "$state"
  [ "$status" -eq 0 ]
  result="$output"
  [ "$(printf '%s' "$result" | jq -r '.plan_phase')" = "1" ]
  [ "$(printf '%s' "$result" | jq -r '.plan_order')" = "1" ]
  [ "$(printf '%s' "$result" | jq -r '.plan_fidelity')" = "1" ]
  [ "$(printf '%s' "$result" | jq -r '.composite')" = "1" ]
}

@test "adherence: skipped mandatory phase lowers plan_phase" {
  state=".spectra/plans/p.state.json"
  init_state "$state" --files-est 6 --public-api --stakes med
  ramza-gate advance --state "$state" --to S
  ramza-gate advance --state "$state" --to C --reason "spike reuse, P/E covered by prior spec"
  ramza-gate advance --state "$state" --to T
  ramza-gate advance --state "$state" --to A
  run ramza-adherence --state "$state"
  [ "$status" -eq 0 ]
  result="$output"
  # lite mandatory = 7 phases; P and E were skipped => 5/7
  [ "$(printf '%s' "$result" | jq -r '.plan_phase')" = "0.714" ]
}

@test "adherence: refine churn lowers plan_order" {
  state=".spectra/plans/p.state.json"
  init_state "$state" --files-est 6 --public-api --stakes med
  for ph in S P E C T; do ramza-gate advance --state "$state" --to "$ph"; done
  ramza-gate refine --state "$state"; ramza-gate advance --state "$state" --to T
  ramza-gate refine --state "$state"; ramza-gate advance --state "$state" --to T
  ramza-gate refine --state "$state"; ramza-gate advance --state "$state" --to T
  run ramza-adherence --state "$state"
  result="$output"
  # 3 cycles: -0.2*2 beyond first, -0.3 cap reached => 0.3
  [ "$(printf '%s' "$result" | jq -r '.plan_order')" = "0.3" ]
}

@test "adherence: --min gate fails below threshold (exit 1)" {
  state=".spectra/plans/p.state.json"
  init_state "$state"
  ramza-gate advance --state "$state" --to S
  run ramza-adherence --state "$state" --min 0.9
  [ "$status" -eq 1 ]
}

@test "adherence: report is appended to state adherence_reports[]" {
  state=".spectra/plans/p.state.json"
  init_state "$state"
  ramza-gate advance --state "$state" --to S
  ramza-adherence --state "$state" >/dev/null
  ramza-adherence --state "$state" >/dev/null
  [ "$(jq '.adherence_reports | length' "$state")" -eq 2 ]
}

# ── ramza-calibrate ──────────────────────────────────────────────────────────

write_good_scores() {
  # Within ±1 of the v2 consensus references (see anchors/*.json notes).
  cat > "$1" <<'EOF'
{"solid-import":{"alignment":9,"correctness":8,"maintainability":9,"performance":8,"simplicity":9,"risk":8,"innovation":3},
 "weak-rewrite":{"alignment":3,"correctness":2,"maintainability":2,"performance":4,"simplicity":2,"risk":2,"innovation":7}}
EOF
}

@test "calibrate: within-tolerance scores => calibrated (exit 0)" {
  write_good_scores scored.json
  run ramza-calibrate --anchors "$RAMZA_ROOT/anchors" --scored scored.json
  [ "$status" -eq 0 ]
  result="$output"
  [ "$(printf '%s' "$result" | jq -r '.verdict')" = "calibrated" ]
}

@test "calibrate: grade-inflated scorer => uncalibrated (exit 1)" {
  cat > scored.json <<'EOF'
{"solid-import":{"alignment":10,"correctness":9,"maintainability":9,"performance":9,"simplicity":9,"risk":9,"innovation":8},
 "weak-rewrite":{"alignment":8,"correctness":8,"maintainability":7,"performance":8,"simplicity":7,"risk":7,"innovation":9}}
EOF
  run ramza-calibrate --anchors "$RAMZA_ROOT/anchors" --scored scored.json
  [ "$status" -eq 1 ]
  result="$output"
  [ "$(printf '%s' "$result" | jq -r '.verdict')" = "uncalibrated" ]
  [ "$(printf '%s' "$result" | jq -r '.anchors_failed')" = "2" ]
}

@test "calibrate: missing anchor scores counts as failure" {
  cat > scored.json <<'EOF'
{"solid-import":{"alignment":9,"correctness":7,"maintainability":7,"performance":7,"simplicity":8,"risk":7,"innovation":6}}
EOF
  run ramza-calibrate --anchors "$RAMZA_ROOT/anchors" --scored scored.json
  [ "$status" -eq 1 ]
}

@test "calibrate: --log appends a JSONL entry" {
  write_good_scores scored.json
  ramza-calibrate --anchors "$RAMZA_ROOT/anchors" --scored scored.json --log cal.jsonl >/dev/null
  [ "$(wc -l < cal.jsonl | tr -d ' ')" -eq 1 ]
  jq -e '.verdict == "calibrated"' cal.jsonl >/dev/null
}
