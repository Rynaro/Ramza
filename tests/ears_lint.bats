#!/usr/bin/env bats
# tests/ears_lint.bats — behavioral tests for bin/ramza-ears-lint.

load helpers

setup() {
  ramza_setup_repo
  ac="$BATS_TEST_TMPDIR/acceptance.md"
}

teardown() {
  ramza_teardown_repo
}

@test "ears-lint: valid two-block file passes (exit 0)" {
  cat > "$ac" <<'EOF'
### AC-001 (event-driven)
GIVEN a precondition holds
WHEN  a trigger fires
THEN  the system SHALL do exactly one thing
VERIFY: test: tests/ears.bats#ac_001

### AC-002 (state-driven)
GIVEN a state holds
THEN  the system SHALL respond accordingly
VERIFY: test: tests/ears.bats#ac_002
EOF
  run ramza-ears-lint "$ac"
  [ "$status" -eq 0 ]
  [[ "$output" == *"2 criteria pass EARS lint"* ]]
}

@test "ears-lint: compound THEN (contains AND) is caught" {
  cat > "$ac" <<'EOF'
### AC-001 (event-driven)
GIVEN a precondition holds
WHEN  a trigger fires
THEN  the system SHALL do one thing AND also do a second thing
VERIFY: test: tests/ears.bats#ac_001
EOF
  run ramza-ears-lint "$ac"
  [ "$status" -eq 1 ]
  [[ "$output" == *"compound THEN"* ]]
}

@test "ears-lint: duplicate ID is caught" {
  cat > "$ac" <<'EOF'
### AC-001 (event-driven)
GIVEN a precondition holds
WHEN  a trigger fires
THEN  the system SHALL do exactly one thing
VERIFY: test: tests/ears.bats#ac_001a

### AC-001 (state-driven)
GIVEN a different state holds
THEN  the system SHALL respond accordingly
VERIFY: test: tests/ears.bats#ac_001b
EOF
  run ramza-ears-lint "$ac"
  [ "$status" -eq 1 ]
  [[ "$output" == *"AC-001: duplicate ID"* ]]
}

@test "ears-lint: unknown form is caught" {
  cat > "$ac" <<'EOF'
### AC-001 (made-up-form)
GIVEN a precondition holds
WHEN  a trigger fires
THEN  the system SHALL do exactly one thing
VERIFY: test: tests/ears.bats#ac_001
EOF
  run ramza-ears-lint "$ac"
  [ "$status" -eq 1 ]
  [[ "$output" == *"unknown form"* ]]
}

@test "ears-lint: missing VERIFY is caught" {
  cat > "$ac" <<'EOF'
### AC-001 (event-driven)
GIVEN a precondition holds
WHEN  a trigger fires
THEN  the system SHALL do exactly one thing
EOF
  run ramza-ears-lint "$ac"
  [ "$status" -eq 1 ]
  [[ "$output" == *"AC-001: missing VERIFY: method"* ]]
}

@test "ears-lint: missing THEN is caught" {
  cat > "$ac" <<'EOF'
### AC-001 (event-driven)
GIVEN a precondition holds
WHEN  a trigger fires
VERIFY: test: tests/ears.bats#ac_001
EOF
  run ramza-ears-lint "$ac"
  [ "$status" -eq 1 ]
  [[ "$output" == *"AC-001: missing THEN"* ]]
}

@test "ears-lint: empty file reports 'no criteria' (exit 1)" {
  : > "$ac"
  run ramza-ears-lint "$ac"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no criteria found"* ]]
}
