#!/usr/bin/env bats
# Tests for tests/evals/compare-experiment.sh
#
# Each test creates the minimum JSON fixtures it needs in $BATS_TEST_TMPDIR.
# Variance-aware tests use non-zero ci95 bands; score-only tests use zeros.
# run ... 2>&1 is used where stderr output (warnings) must be asserted.

setup() {
    source "$BATS_TEST_DIRNAME/test_helper.bash"
    SCRIPT="$BATS_TEST_DIRNAME/../../evals/compare-experiment.sh"
}

# ---- input validation ----

@test "exits 2 when called with no arguments" {
    run bash "$SCRIPT"
    [ "$status" -eq 2 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "exits 2 when before file does not exist" {
    printf '%s\n' '{"summary":{"aggregate_score":0},"tasks":[]}' \
        > "$BATS_TEST_TMPDIR/after.json"
    run bash "$SCRIPT" /nonexistent/before.json "$BATS_TEST_TMPDIR/after.json"
    [ "$status" -eq 2 ]
    [[ "$output" =~ "file not found" ]]
}

@test "exits 2 when after file does not exist" {
    printf '%s\n' '{"summary":{"aggregate_score":0},"tasks":[]}' \
        > "$BATS_TEST_TMPDIR/before.json"
    run bash "$SCRIPT" "$BATS_TEST_TMPDIR/before.json" /nonexistent/after.json
    [ "$status" -eq 2 ]
    [[ "$output" =~ "file not found" ]]
}

# ---- variance-aware (ci95 bands present in both files) ----

@test "exits 0 when at least one task shows SIGNAL in variance-aware mode" {
    # t1: a_lo=0.92 > b_hi=0.90 -> SIGNAL; t2: bands overlap -> INCONCLUSIVE
    printf '%s\n' '{"summary":{"aggregate_score":0.82},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.80,"ci95_lo":0.70,"ci95_hi":0.90}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.75,"ci95_lo":0.65,"ci95_hi":0.85}}
    ]}' > "$BATS_TEST_TMPDIR/before.json"
    printf '%s\n' '{"summary":{"aggregate_score":0.90},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.96,"ci95_lo":0.92,"ci95_hi":1.00}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.80,"ci95_lo":0.70,"ci95_hi":0.90}}
    ]}' > "$BATS_TEST_TMPDIR/after.json"
    run bash "$SCRIPT" "$BATS_TEST_TMPDIR/before.json" "$BATS_TEST_TMPDIR/after.json"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "CANDIDATE IMPROVES" ]]
    [[ "$output" =~ "SIGNAL" ]]
}

@test "exits 2 when any task shows REGRESSION in variance-aware mode" {
    # t1: a_hi=0.62 < b_lo=0.70 -> REGRESSION; t2: unchanged
    printf '%s\n' '{"summary":{"aggregate_score":0.82},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.80,"ci95_lo":0.70,"ci95_hi":0.90}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.75,"ci95_lo":0.65,"ci95_hi":0.85}}
    ]}' > "$BATS_TEST_TMPDIR/before.json"
    printf '%s\n' '{"summary":{"aggregate_score":0.70},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.55,"ci95_lo":0.45,"ci95_hi":0.62}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.75,"ci95_lo":0.65,"ci95_hi":0.85}}
    ]}' > "$BATS_TEST_TMPDIR/after.json"
    run bash "$SCRIPT" "$BATS_TEST_TMPDIR/before.json" "$BATS_TEST_TMPDIR/after.json"
    [ "$status" -eq 2 ]
    [[ "$output" =~ "REGRESSION DETECTED" ]]
}

@test "exits 1 when all bands overlap in variance-aware mode" {
    # all tasks: overlapping bands, non-identical averages -> INCONCLUSIVE
    printf '%s\n' '{"summary":{"aggregate_score":0.82},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.80,"ci95_lo":0.70,"ci95_hi":0.90}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.75,"ci95_lo":0.65,"ci95_hi":0.85}}
    ]}' > "$BATS_TEST_TMPDIR/before.json"
    printf '%s\n' '{"summary":{"aggregate_score":0.83},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.83,"ci95_lo":0.73,"ci95_hi":0.93}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.78,"ci95_lo":0.68,"ci95_hi":0.88}}
    ]}' > "$BATS_TEST_TMPDIR/after.json"
    run bash "$SCRIPT" "$BATS_TEST_TMPDIR/before.json" "$BATS_TEST_TMPDIR/after.json"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "INCONCLUSIVE" ]]
}

# ---- score-only fallback (ci95 bands absent) ----

@test "exits 0 with warning when scores improve and no ci bands are present" {
    printf '%s\n' '{"summary":{"aggregate_score":0.78},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.80,"ci95_lo":0,"ci95_hi":0}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.75,"ci95_lo":0,"ci95_hi":0}}
    ]}' > "$BATS_TEST_TMPDIR/before.json"
    printf '%s\n' '{"summary":{"aggregate_score":0.88},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.90,"ci95_lo":0,"ci95_hi":0}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.85,"ci95_lo":0,"ci95_hi":0}}
    ]}' > "$BATS_TEST_TMPDIR/after.json"
    run bash "$SCRIPT" "$BATS_TEST_TMPDIR/before.json" "$BATS_TEST_TMPDIR/after.json" 2>&1
    [ "$status" -eq 0 ]
    [[ "$output" =~ "ci95 bands are missing" ]]
    [[ "$output" =~ "CANDIDATE IMPROVES" ]]
}

@test "exits 2 with warning when scores drop and no ci bands are present" {
    printf '%s\n' '{"summary":{"aggregate_score":0.82},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.80,"ci95_lo":0,"ci95_hi":0}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.75,"ci95_lo":0,"ci95_hi":0}}
    ]}' > "$BATS_TEST_TMPDIR/before.json"
    printf '%s\n' '{"summary":{"aggregate_score":0.70},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.70,"ci95_lo":0,"ci95_hi":0}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.65,"ci95_lo":0,"ci95_hi":0}}
    ]}' > "$BATS_TEST_TMPDIR/after.json"
    run bash "$SCRIPT" "$BATS_TEST_TMPDIR/before.json" "$BATS_TEST_TMPDIR/after.json" 2>&1
    [ "$status" -eq 2 ]
    [[ "$output" =~ "ci95 bands are missing" ]]
    [[ "$output" =~ "REGRESSION DETECTED" ]]
}

@test "falls back to score-only with warning when before has ci bands but after does not" {
    # Mixed: before has bands, after does not. has_ci_a=false -> global fallback.
    printf '%s\n' '{"summary":{"aggregate_score":0.82},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.80,"ci95_lo":0.70,"ci95_hi":0.90}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.75,"ci95_lo":0.65,"ci95_hi":0.85}}
    ]}' > "$BATS_TEST_TMPDIR/before.json"
    printf '%s\n' '{"summary":{"aggregate_score":0.90},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.90,"ci95_lo":0,"ci95_hi":0}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.85,"ci95_lo":0,"ci95_hi":0}}
    ]}' > "$BATS_TEST_TMPDIR/after.json"
    run bash "$SCRIPT" "$BATS_TEST_TMPDIR/before.json" "$BATS_TEST_TMPDIR/after.json" 2>&1
    [ "$status" -eq 0 ]
    [[ "$output" =~ "ci95 bands are missing" ]]
    [[ "$output" =~ "CANDIDATE IMPROVES" ]]
}

# ---- per-task ci band guard ----

@test "does not produce REGRESSION for zero-band tasks when global has_ci is true" {
    # before: both tasks have ci bands -> has_ci=true globally
    # after: t1 has bands, t2 has zero bands (partial run)
    # Without the per-task guard: t2 variance-aware comparison gives a_hi=0 < b_lo=0.65 -> REGRESSION.
    # With the guard: t2 falls back to score-only, avg 0.75 == 0.75 -> NO_CHANGE.
    # t1: bands overlap (a_lo=0.72, b_hi=0.90) -> INCONCLUSIVE.
    # Overall: 0 SIGNAL, 0 REGRESSION -> exit 1 (INCONCLUSIVE).
    printf '%s\n' '{"summary":{"aggregate_score":0.82},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.80,"ci95_lo":0.70,"ci95_hi":0.90}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.75,"ci95_lo":0.65,"ci95_hi":0.85}}
    ]}' > "$BATS_TEST_TMPDIR/before.json"
    printf '%s\n' '{"summary":{"aggregate_score":0.83},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.82,"ci95_lo":0.72,"ci95_hi":0.92}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.75,"ci95_lo":0,"ci95_hi":0}}
    ]}' > "$BATS_TEST_TMPDIR/after.json"
    run bash "$SCRIPT" "$BATS_TEST_TMPDIR/before.json" "$BATS_TEST_TMPDIR/after.json"
    [ "$status" -eq 1 ]
    [[ ! "$output" =~ "REGRESSION" ]]
    [[ "$output" =~ "INCONCLUSIVE" ]]
}

# ---- mismatched task sets ----

@test "tasks in before but not in after are silently skipped" {
    # before: t1, t2, t3; after: t1 only (t2 and t3 absent)
    # t1: after_avg > before_avg (score-only, no ci bands) -> SIGNAL
    # t2, t3: absent in after -> skipped, no REGRESSION
    # Overall: 1 SIGNAL, 0 REGRESSION -> exit 0
    printf '%s\n' '{"summary":{"aggregate_score":0.70},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.70,"ci95_lo":0,"ci95_hi":0}},
      {"test_id":"t2","display_name":"T2","stats":{"avg_score":0.80,"ci95_lo":0,"ci95_hi":0}},
      {"test_id":"t3","display_name":"T3","stats":{"avg_score":0.90,"ci95_lo":0,"ci95_hi":0}}
    ]}' > "$BATS_TEST_TMPDIR/before.json"
    printf '%s\n' '{"summary":{"aggregate_score":0.85},"tasks":[
      {"test_id":"t1","display_name":"T1","stats":{"avg_score":0.85,"ci95_lo":0,"ci95_hi":0}}
    ]}' > "$BATS_TEST_TMPDIR/after.json"
    run bash "$SCRIPT" "$BATS_TEST_TMPDIR/before.json" "$BATS_TEST_TMPDIR/after.json" 2>&1
    [ "$status" -eq 0 ]
    [[ "$output" =~ "CANDIDATE IMPROVES" ]]
    [[ ! "$output" =~ "REGRESSION" ]]
}
