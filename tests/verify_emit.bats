#!/usr/bin/env bats
# tests/verify_emit.bats — behavioral tests for bin/ramza-verify-emit, the emission gate.
#
# NOTE: ramza-verify-emit's own required-field loop checks the envelope for a
# key literally named `envelope_version` (see the `for field in envelope_version ...`
# line in bin/ramza-verify-emit). Every other artefact in this repo — the
# vendored schemas/ecl-envelope.v2.json and templates/spec.envelope.json —
# names that field `envelope_version`. Fixtures below satisfy the tool's
# *actual* check (this is a behavioral suite, not a schema-conformance suite);
# the naming mismatch is called out as a suspected bug in the test run
# summary rather than patched here.

load helpers

setup() {
  ramza_setup_repo
  spec="$BATS_TEST_TMPDIR/spec.md"
  envelope="$BATS_TEST_TMPDIR/envelope.json"
  cat > "$spec" <<'EOF'
---
eidolon: ramza
kind: spec
version: 1.0.0
created_at: 2026-07-04T00:00:00Z
---

# Demo Spec

Body content.
EOF
}

teardown() {
  ramza_teardown_repo
}

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

# write_envelope <performative> <integrity-value>
write_envelope() {
  cat > "$envelope" <<EOF
{
  "envelope_version": "2.0",
  "message_id": "018e5e6a-0000-7000-8000-000000000000",
  "thread_id": "018e5e6a-0000-7000-8000-000000000001",
  "performative": "$1",
  "from": {"eidolon": "ramza", "version": "1.0.0"},
  "to": {"eidolon": "apivr", "version": "n/a"},
  "artifact": {"kind": "spec", "schema_version": "1.0", "path": "spec.md", "sha256": "$2", "size_bytes": 10},
  "integrity": {"method": "sha256", "value": "$2"}
}
EOF
}

@test "verify-emit: spec-only with valid frontmatter passes (exit 0)" {
  run ramza-verify-emit --spec "$spec"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok: emission gate passed"* ]]
}

@test "verify-emit: spec + envelope with correct sha256 and performative PROPOSE passes (exit 0)" {
  hash="$(sha256_of "$spec")"
  write_envelope "PROPOSE" "$hash"
  run ramza-verify-emit --spec "$spec" --envelope "$envelope" --schema-dir "$RAMZA_ROOT/schemas"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok: emission gate passed"* ]]
}

@test "verify-emit: wrong integrity.value fails (exit 1)" {
  write_envelope "PROPOSE" "0000000000000000000000000000000000000000000000000000000000000000"
  run ramza-verify-emit --spec "$spec" --envelope "$envelope" --schema-dir "$RAMZA_ROOT/schemas"
  [ "$status" -eq 1 ]
  [[ "$output" == *"integrity.value mismatch"* ]]
}

@test "verify-emit: performative outside the closed set fails (exit 1)" {
  hash="$(sha256_of "$spec")"
  write_envelope "FOO" "$hash"
  run ramza-verify-emit --spec "$spec" --envelope "$envelope" --schema-dir "$RAMZA_ROOT/schemas"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not in the closed set"* ]]
}

@test "verify-emit: missing spec frontmatter key fails (exit 1)" {
  cat > "$spec" <<'EOF'
---
eidolon: ramza
kind: spec
created_at: 2026-07-04T00:00:00Z
---

# Demo Spec missing version
EOF
  run ramza-verify-emit --spec "$spec"
  [ "$status" -eq 1 ]
  [[ "$output" == *"frontmatter missing 'version:'"* ]]
}

@test "verify-emit: missing frontmatter block entirely fails (exit 1)" {
  printf '# No frontmatter here\n' > "$spec"
  run ramza-verify-emit --spec "$spec"
  [ "$status" -eq 1 ]
  [[ "$output" == *"missing YAML frontmatter"* ]]
}

@test "verify-emit: envelope missing a required field fails (exit 1)" {
  hash="$(sha256_of "$spec")"
  cat > "$envelope" <<EOF
{
  "envelope_version": "2.0",
  "message_id": "018e5e6a-0000-7000-8000-000000000000",
  "performative": "PROPOSE",
  "from": {"eidolon": "ramza", "version": "1.0.0"},
  "to": {"eidolon": "apivr", "version": "n/a"},
  "artifact": {"kind": "spec", "schema_version": "1.0", "path": "spec.md", "sha256": "$hash", "size_bytes": 10},
  "integrity": {"method": "sha256", "value": "$hash"}
}
EOF
  run ramza-verify-emit --spec "$spec" --envelope "$envelope" --schema-dir "$RAMZA_ROOT/schemas"
  [ "$status" -eq 1 ]
  [[ "$output" == *"missing field 'thread_id'"* ]]
}
