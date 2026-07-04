#!/usr/bin/env bats
# tests/lint.bats — behavioral tests for bin/ramza-lint (plan-body structural lint).

load helpers

setup() {
  ramza_setup_repo
  plan="$BATS_TEST_TMPDIR/plan.md"
}

teardown() {
  ramza_teardown_repo
}

@test "lint: lite plan with all required sections passes (exit 0)" {
  cat > "$plan" <<'EOF'
# Plan

## Scope
In scope.

## Approach
The approach.

## Stories
As a user...

## Confidence
High.

## Acceptance Criteria
- AC-1
EOF
  run ramza-lint --plan "$plan" --tier lite
  [ "$status" -eq 0 ]
  [[ "$output" == *"passes structural lint (tier: lite)"* ]]
}

@test "lint: the same plan at --tier full fails, listing the missing sections" {
  cat > "$plan" <<'EOF'
# Plan

## Scope
In scope.

## Approach
The approach.

## Stories
As a user...

## Confidence
High.

## Acceptance Criteria
- AC-1
EOF
  run ramza-lint --plan "$plan" --tier full
  [ "$status" -eq 1 ]
  [[ "$output" == *"missing section: ## Rejected Alternatives"* ]]
  [[ "$output" == *"missing section: ## Risks"* ]]
}

@test "lint: trivial plan over the 120-line budget fails with the budget message" {
  {
    printf '## Scope\nin scope\n'
    printf '## Approach\nthe approach\n'
    printf '## Acceptance Criteria\n- AC-1\n'
    i=0
    while [ "$i" -lt 130 ]; do
      printf 'padding line %d\n' "$i"
      i=$((i + 1))
    done
  } > "$plan"
  run ramza-lint --plan "$plan" --tier trivial
  [ "$status" -eq 1 ]
  [[ "$output" == *"exceeds the 120-line budget"* ]]
}

@test "lint: --state resolves the tier from the plan-state file" {
  state="$BATS_TEST_TMPDIR/state.json"
  init_state "$state"   # trivial tier (files-est 1)
  cat > "$plan" <<'EOF'
## Scope
in scope

## Approach
the approach

## Acceptance Criteria
- AC-1
EOF
  run ramza-lint --plan "$plan" --state "$state"
  [ "$status" -eq 0 ]
}

@test "lint: missing required sections are reported (trivial tier)" {
  printf '# just a title\nno sections here\n' > "$plan"
  run ramza-lint --plan "$plan" --tier trivial
  [ "$status" -eq 1 ]
  [[ "$output" == *"missing section: ## Scope"* ]]
  [[ "$output" == *"missing section: ## Approach"* ]]
  [[ "$output" == *"missing section: ## Acceptance Criteria"* ]]
}
