# Unit Test Design — `.github/scripts/`

Test design for the 10 CI scripts extracted from GitHub Actions workflows.
Follows the existing patterns in `tests/unit/` (Pester 5 + bats-core).

---

## Directory Layout

```
tests/unit/
├── bash/
│   ├── test_helper.bash                      # EXISTING — unchanged
│   ├── ci/                                   # NEW — CI script bash tests
│   │   ├── ci_test_helper.bash               # NEW — shared CI test helpers
│   │   ├── extract-version.bats              # release/extract-version.sh
│   │   ├── extract-changelog.bats            # release/extract-changelog.sh
│   │   ├── create-tag-and-release.bats       # release/create-tag-and-release.sh
│   │   ├── back-merge.bats                   # release/back-merge.sh
│   │   ├── create-backmerge-pr.bats          # release/create-backmerge-pr.sh
│   │   ├── detect-change-scope.bats          # validate/detect-change-scope.sh
│   │   └── install-bats.bats                 # test/install-bats.sh
│   └── ...existing tests...
├── powershell/
│   ├── ci/                                   # NEW — CI script PowerShell tests
│   │   ├── Invoke-Validation.Tests.ps1       # validate/Invoke-Validation.ps1
│   │   ├── Install-Pester.Tests.ps1          # test/Install-Pester.ps1
│   │   └── Invoke-ScriptAnalyzer.Tests.ps1   # test/Invoke-ScriptAnalyzer.ps1
│   └── ...existing tests...
├── Run-PesterTests.ps1                       # EXISTING — no changes needed
└── run-bats-tests.sh                         # EXISTING — no changes needed
```

Both test runners auto-discover recursively (`find *.bats`, Pester scans
`tests/unit/powershell/`), so no runner changes are needed.

---

## Test Helper Extensions

### `tests/unit/bash/ci/ci_test_helper.bash`

A helper specific to CI scripts, sourcing the base `test_helper.bash` for
mock utilities and adding CI-specific concerns.

**Constants:**

```bash
CI_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/../.github/scripts"
```

Points to `.github/scripts/` from `tests/unit/bash/ci/`.

**GITHUB_OUTPUT mocking:**

Most CI scripts write step outputs to `$GITHUB_OUTPUT`. Tests need to
create a temp file, export the variable, and read results back.

```bash
setup_github_output() {
    GITHUB_OUTPUT="$(mktemp)"
    export GITHUB_OUTPUT
}

teardown_github_output() {
    [[ -n "${GITHUB_OUTPUT:-}" && -f "$GITHUB_OUTPUT" ]] && rm -f "$GITHUB_OUTPUT"
}

# Read a simple key=value from GITHUB_OUTPUT
get_output_value() {
    local key="$1"
    grep "^${key}=" "$GITHUB_OUTPUT" | head -1 | cut -d= -f2-
}

# Read a heredoc value (key<<DELIM ... DELIM) from GITHUB_OUTPUT
get_output_heredoc() {
    local key="$1"
    awk -v k="$key" '
        $0 ~ "^" k "<<" { delim=substr($0, length(k)+3); found=1; next }
        found && $0 == delim { exit }
        found { print }
    ' "$GITHUB_OUTPUT"
}
```

**Git mock with subcommand dispatch:**

Several CI scripts call `git` with different subcommands in the same run.
A dispatch mock routes responses by subcommand.

```bash
# Initializes git mock with dispatch-by-subcommand.
# After calling this, use set_git_response to configure per-subcommand behavior.
create_git_dispatch_mock() {
    mkdir -p "$MOCK_DIR/git_state"
    cat > "$MOCK_DIR/git" <<'SCRIPT'
#!/usr/bin/env bash
dir="$(dirname "$0")/git_state"
# First non-flag argument is the subcommand
for arg in "$@"; do
    [[ "$arg" == -* ]] && continue
    subcmd="$arg"; break
done
subcmd="${subcmd:-unknown}"
resp="$dir/${subcmd}_output"; exitf="$dir/${subcmd}_exit"
[[ -f "$resp" ]] && cat "$resp"
[[ -f "$exitf" ]] && exit "$(cat "$exitf")"
SCRIPT
    chmod +x "$MOCK_DIR/git"
}

set_git_response() {
    local subcmd="$1" output="$2" exit_code="${3:-0}"
    printf '%s' "$output" > "$MOCK_DIR/git_state/${subcmd}_output"
    printf '%s' "$exit_code" > "$MOCK_DIR/git_state/${subcmd}_exit"
}
```

**Sequenced mock (for scripts that call the same command multiple times
with different expected outcomes, e.g. back-merge retry loop):**

```bash
# Creates a mock that returns different results on each invocation.
# Usage: create_sequenced_mock "git" "output1|0" "output2|10" "output3|0"
# Format per call: "stdout_text|exit_code"
create_sequenced_mock() {
    local cmd_name="$1"; shift
    local seq_dir="$MOCK_DIR/${cmd_name}_seq"
    mkdir -p "$seq_dir"
    local i=0
    for entry in "$@"; do
        local output="${entry%|*}" exit_code="${entry##*|}"
        printf '%s' "$output" > "$seq_dir/${i}_output"
        printf '%s' "$exit_code" > "$seq_dir/${i}_exit"
        ((i++))
    done
    cat > "$MOCK_DIR/$cmd_name" <<SCRIPT
#!/usr/bin/env bash
dir="$seq_dir"
counter="\$dir/counter"
[[ -f "\$counter" ]] && n=\$(cat "\$counter") || n=0
printf '%s' "\$((n+1))" > "\$counter"
[[ -f "\$dir/\${n}_output" ]] && cat "\$dir/\${n}_output"
[[ -f "\$dir/\${n}_exit" ]] && exit "\$(cat "\$dir/\${n}_exit")"
SCRIPT
    chmod +x "$MOCK_DIR/$cmd_name"
}
```

---

## CI Workflow Changes Needed

The `unit-tests.yml` `dorny/paths-filter` blocks need to include
`.github/scripts/**` so CI tests run when the scripts themselves change:

```yaml
filters: |
  relevant:
    - 'skills/azure-cost-calculator/scripts/**'
    - 'tests/unit/**'
    - '.github/scripts/**'            # <-- add this line
```

Add to both the `powershell-tests` and `bash-tests` jobs. Also add to
the top-level `push.paths` list:

```yaml
push:
  branches: [dev]
  paths:
    - "skills/azure-cost-calculator/scripts/**"
    - "tests/unit/**"
    - ".github/scripts/**" # <-- add this line
```

The PSScriptAnalyzer step should also lint the CI PowerShell scripts:

```yaml
- name: Run PSScriptAnalyzer
  run: |
    .github/scripts/test/Invoke-ScriptAnalyzer.ps1 -TargetPath skills/azure-cost-calculator/scripts
    .github/scripts/test/Invoke-ScriptAnalyzer.ps1 -TargetPath .github/scripts
```

---

## Test Specifications by Script

### Priority Tiers

| Tier   | Scripts                                                 | Rationale                               |
| ------ | ------------------------------------------------------- | --------------------------------------- |
| **P0** | extract-version, extract-changelog, detect-change-scope | Pure logic, high testability, high risk |
| **P1** | Invoke-Validation, back-merge, create-backmerge-pr      | Important logic but heavier mocking     |
| **P2** | create-tag-and-release, Invoke-ScriptAnalyzer           | Thin wrappers, lower complexity         |
| **P3** | Install-Pester, install-bats                            | Linear installers, no conditional logic |

---

### P0 — `extract-version.bats`

**Script:** `.github/scripts/release/extract-version.sh`
**Mocks:** `jq`, `git`
**Test setup pattern:**

```bash
setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"
    setup_mock_path
}
teardown() { teardown_mock_path; }
```

**Test cases:**

| #   | Test                             | Mock Setup                                     | Assert                                |
| --- | -------------------------------- | ---------------------------------------------- | ------------------------------------- |
| 1   | Valid semver, tag does not exist | jq → "1.2.3", git rev-parse → exit 128         | status=0, stdout="1.2.3"              |
| 2   | Valid semver with prerelease     | jq → "1.0.0-beta.1", git rev-parse → exit 128  | status=0, stdout contains version     |
| 3   | Tag already exists               | jq → "1.2.3", git rev-parse → exit 0           | status=1, stderr ∋ "already exists"   |
| 4   | Invalid semver (letters)         | jq → "abc"                                     | status=1, stderr ∋ "not valid semver" |
| 5   | Invalid semver (leading zero)    | jq → "01.2.3"                                  | status=1, stderr ∋ "not valid semver" |
| 6   | Empty version                    | jq → ""                                        | status=1, stderr ∋ "empty"            |
| 7   | Missing plugin.json              | (no mock — file doesn't exist)                 | status=1, stderr ∋ "Failed to read"   |
| 8   | jq returns null                  | jq → exit 1                                    | status=1, stderr ∋ "Failed to read"   |
| 9   | Custom plugin.json path          | create temp file, jq → "2.0.0", git → exit 128 | status=0, stdout="2.0.0"              |

**Notes:**

- Script outputs version to stdout, errors to stderr with `::error::` prefix.
- `run bash "$CI_SCRIPTS_DIR/release/extract-version.sh"` captures both.
- For test 7, skip `jq` mock so real `jq` fails on missing file.
- For semver edge cases: `0.0.0`, `99.99.99`, `1.2.3+build.456`.

---

### P0 — `extract-changelog.bats`

**Script:** `.github/scripts/release/extract-changelog.sh`
**Mocks:** None — uses real `awk` against fixture files.
**Fixtures:** Temporary CHANGELOG.md files created in `setup()`.

**Test setup pattern:**

```bash
setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"
    TMPDIR_FIX="$(mktemp -d)"
    OUTPUT_FILE="$TMPDIR_FIX/release-body.md"

    # Standard changelog fixture
    cat > "$TMPDIR_FIX/CHANGELOG.md" <<'EOF'
# Changelog

## [2.0.0]
### Added
- New feature X

### Fixed
- Bug Y

## [1.0.0]
### Added
- Initial release
EOF
}
teardown() { rm -rf "$TMPDIR_FIX"; }
```

**Test cases:**

| #   | Test                          | Fixture Variation                       | Assert                                      |
| --- | ----------------------------- | --------------------------------------- | ------------------------------------------- |
| 1   | Extract existing version      | standard fixture, version=2.0.0         | status=0, output file has "New feature X"   |
| 2   | Extract older version         | standard fixture, version=1.0.0         | status=0, output file has "Initial release" |
| 3   | Version not in changelog      | standard fixture, version=9.9.9         | status=1, stderr ∋ "No changelog section"   |
| 4   | Missing version argument      | standard fixture, no $1                 | status=1 (bash :? expansion)                |
| 5   | Changelog file does not exist | version=1.0.0, bogus path               | status!=0 (awk fails)                       |
| 6   | Empty section (header only)   | `## [3.0.0]` followed by `## [2.0.0]`   | status=1, stderr ∋ "No changelog section"   |
| 7   | Section with special chars    | body has backticks, links, `[brackets]` | status=0, output file preserves them        |
| 8   | Custom output path            | version=2.0.0, custom $3                | status=0, writes to custom path             |
| 9   | Version with prerelease tag   | `## [1.0.0-rc.1]` section               | status=0, extracted correctly               |

**Notes:**

- No mocking needed — `awk` runs against real temp files.
- Verify output file content with `cat "$OUTPUT_FILE"`.
- Most testable script in the set.

---

### P0 — `detect-change-scope.bats`

**Script:** `.github/scripts/validate/detect-change-scope.sh`
**Mocks:** `git`, `openssl`
**Env vars:** `DIFF_BASE`, `DIFF_HEAD`, `SERVICES_ROOT`, `INFRA_PATHS`, `GITHUB_OUTPUT`

**Test setup pattern:**

```bash
setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"
    setup_mock_path
    setup_github_output
    export DIFF_BASE="abc123" DIFF_HEAD="def456"
    export SERVICES_ROOT="skills/azure-cost-calculator/references/services"
    export INFRA_PATHS="tests/ docs/TEMPLATE.md"
    # Stable openssl output for predictable delimiters
    create_mock "openssl" "deadbeef1234567890abcdef12345678"
}
teardown() {
    teardown_github_output
    teardown_mock_path
}
```

**Test cases:**

| #   | Test                                | git diff mock output                          | Assert on GITHUB_OUTPUT                                                       |
| --- | ----------------------------------- | --------------------------------------------- | ----------------------------------------------------------------------------- |
| 1   | Service files only                  | 1st call: "services/compute/vm.md", 2nd: ""   | service_changed=true, infra_changed=false, all_changed_files contains "vm.md" |
| 2   | Infra files only                    | 1st call: "", 2nd: "tests/foo.ps1"            | service_changed=false, infra_changed=true                                     |
| 3   | Both service and infra              | 1st: "services/compute/vm.md", 2nd: "tests/x" | service_changed=true, infra_changed=true                                      |
| 4   | No changes at all                   | Both calls: ""                                | service_changed=false, infra_changed=false                                    |
| 5   | Non-markdown service files ignored  | 1st call: "services/compute/image.png"        | service_changed=false (grep filters .md)                                      |
| 6   | Missing DIFF_BASE env var           | n/a                                           | status=1, stderr ∋ "DIFF_BASE"                                                |
| 7   | Missing SERVICES_ROOT env var       | n/a                                           | status=1, stderr ∋ "SERVICES_ROOT"                                            |
| 8   | Heredoc delimiter written correctly | 1st: "services/x.md"                          | Heredoc value readable via get_output_heredoc                                 |
| 9   | Multiple service files              | 1st: "a.md\nb.md\nc.md"                       | all_changed_files has 3 lines                                                 |

**Mocking challenge:** The script calls `git diff` twice with different
`--diff-filter` flags and different path arguments. A dispatch mock keyed
only on "diff" can't distinguish the two calls. Options:

- **Sequenced mock** — first call returns service files, second returns infra.
- **Custom script mock** — inspect `$@` for `SERVICES_ROOT` vs `INFRA_PATHS` args.

Recommend: sequenced mock (simpler). The script always calls service diff
first, then infra diff, so ordering is deterministic.

---

### P1 — `Invoke-Validation.Tests.ps1`

**Script:** `.github/scripts/validate/Invoke-Validation.ps1`
**Framework:** Pester 5
**Mocking:** Mock the downstream `ValidationScript` call.

**Test setup pattern:**

```powershell
BeforeAll {
    $script:ScriptPath = Join-Path $PSScriptRoot '../../../../.github/scripts/validate/Invoke-Validation.ps1'
}
```

**Test cases:**

| #   | Mode            | Setup                                       | Assert                                                 |
| --- | --------------- | ------------------------------------------- | ------------------------------------------------------ |
| 1   | ChangedOnly     | 3 temp .md files, ChangedFiles listing them | Calls ValidationScript with all 4 check flags          |
| 2   | ChangedOnly     | ChangedFiles lists files that don't exist   | Exit 0, "No service reference files"                   |
| 3   | ChangedOnly     | Empty ChangedFiles string                   | Exit 0, "No service reference files"                   |
| 4   | Full            | ServicesRoot with 5 .md files               | Calls ValidationScript with all 4 check flags          |
| 5   | Full            | ServicesRoot is empty                       | Exit 0, "No service reference files found"             |
| 6   | RoutingSyncOnly | ServicesRoot with 2 .md files               | Calls ValidationScript with only -CheckRoutingFileSync |
| 7   | RoutingSyncOnly | ServicesRoot is empty                       | "skipping routing sync check"                          |
| 8   | Invalid mode    | Mode="Bogus"                                | PowerShell validation error (ValidateSet)              |

**Mocking strategy:**

```powershell
Context 'ChangedOnly with valid files' {
    BeforeAll {
        # Create temp services dir with .md files
        $script:TempDir = Join-Path $TestDrive 'services'
        New-Item -Path $script:TempDir -ItemType Directory
        'test' | Set-Content (Join-Path $script:TempDir 'vm.md')
        'test' | Set-Content (Join-Path $script:TempDir 'sql.md')

        # Mock the validation script as a no-op
        $script:MockValidator = Join-Path $TestDrive 'Mock-Validator.ps1'
        'param($Path, $ServicesRoot, [switch]$CheckAliasUniqueness,
               [switch]$CheckAliasRoutingSync, [switch]$CheckBillingNeeds,
               [switch]$CheckRoutingFileSync)' | Set-Content $script:MockValidator
    }
    It 'calls validator with all flags' { ... }
}
```

**Notes:**

- Use Pester's `$TestDrive` for temp files (auto-cleaned).
- The `ValidationScript` param is a path, so pass a mock script file
  rather than Pester `Mock` (it's called via `& $ValidationScript`).
- To verify flags were passed, have the mock script write received
  params to a file, then read that file in assertions.

---

### P1 — `back-merge.bats`

**Script:** `.github/scripts/release/back-merge.sh`
**Mocks:** `git` (sequenced — multiple calls per run)
**Env vars:** `GITHUB_OUTPUT`

This is the most complex script (retry loop, multiple git subcommands,
return code state machine). Tests require the sequenced mock.

**Test cases:**

| #   | Scenario                          | Mock Sequence                                                                      | Assert                                               |
| --- | --------------------------------- | ---------------------------------------------------------------------------------- | ---------------------------------------------------- |
| 1   | Success on first try              | fetch→ok, reset→ok, merge→ok, push→ok                                              | result=success, fallback_reason=none                 |
| 2   | Conflict, resolved with -X theirs | fetch→ok, reset→ok, merge→fail(10), reset→ok, merge-theirs→ok, push→ok             | result=success                                       |
| 3   | Push race, success on retry       | fetch→ok, reset→ok, merge→ok, push→fail(20), fetch→ok, reset→ok, merge→ok, push→ok | result=success                                       |
| 4   | Unresolvable conflict             | fetch→ok, merge→fail(10), merge-theirs→fail(10)                                    | result=conflict, fallback_reason=unresolved_conflict |
| 5   | Fetch failure all 3 attempts      | fetch→fail × 3                                                                     | result=conflict, fallback_reason=fetch_failure       |
| 6   | Push race all 3 attempts          | (merge→ok, push→fail(20)) × 3                                                      | result=conflict, fallback_reason=push_race           |

**Mocking challenge:** The script calls `git` ~10+ times per run with
different subcommands (`config`, `reset`, `fetch`, `merge`, `push`,
`merge --abort`). The sequenced mock treats all calls identically.

**Recommended approach:** A custom git mock that dispatches on the full
argument list. Use `$@` inspection to match:

- `*fetch*` → return configured fetch result
- `*merge --abort*` → always succeed
- `*merge*theirs*` → return configured theirs-merge result
- `*merge*` → return configured normal-merge result
- `*push*` → return configured push result
- `*reset*`, `*config*` → always succeed

Implement as a per-test mock script written in `setup()`:

```bash
setup_back_merge_git_mock() {
    local fetch_rc="${1:-0}" merge_rc="${2:-0}" theirs_rc="${3:-0}" push_rc="${4:-0}"
    cat > "$MOCK_DIR/git" <<SCRIPT
#!/usr/bin/env bash
case "\$*" in
    *fetch*)        exit $fetch_rc ;;
    *"merge --abort"*) exit 0 ;;
    *merge*theirs*) exit $theirs_rc ;;
    *merge*)        exit $merge_rc ;;
    *push*)         exit $push_rc ;;
    *)              exit 0 ;;  # config, reset
esac
SCRIPT
    chmod +x "$MOCK_DIR/git"
}
```

For retry scenarios where results change across attempts, use a
counter file that the mock increments on each matched subcommand.

---

### P1 — `create-backmerge-pr.bats`

**Script:** `.github/scripts/release/create-backmerge-pr.sh`
**Mocks:** `git`, `gh`
**Env vars:** `GH_TOKEN`, `FALLBACK_REASON`, `RUN_ID`

**Test cases:**

| #   | Scenario                     | Mock Setup                             | Assert                                          |
| --- | ---------------------------- | -------------------------------------- | ----------------------------------------------- |
| 1   | New PR, push_race reason     | gh pr list → empty, git/gh → success   | gh pr create called, body ∋ "concurrently"      |
| 2   | New PR, fetch_failure reason | gh pr list → empty, git/gh → success   | body ∋ "could not fetch"                        |
| 3   | New PR, unresolved_conflict  | gh pr list → empty, git/gh → success   | body ∋ "Merge conflicts remained"               |
| 4   | Existing PR found            | gh pr list → "42", gh pr view → branch | gh pr edit called (not create), existing branch |
| 5   | Missing GH_TOKEN             | unset GH_TOKEN                         | status=1, stderr ∋ "GH_TOKEN"                   |
| 6   | Missing FALLBACK_REASON      | unset FALLBACK_REASON                  | status=1, stderr ∋ "FALLBACK_REASON"            |
| 7   | Missing RUN_ID               | unset RUN_ID                           | status=1, stderr ∋ "RUN_ID"                     |

**Mocking strategy:** The script calls `gh pr list`, `gh pr view`,
`gh pr edit`, `gh pr create` — all via the `gh` binary. Use a dispatch
mock on `$2` (the subcommand after `pr`):

```bash
create_gh_mock() {
    cat > "$MOCK_DIR/gh" <<'SCRIPT'
#!/usr/bin/env bash
dir="$(dirname "$0")/gh_state"
# e.g. "pr list" → pr_list, "pr create" → pr_create
key="${1}_${2}"
resp="$dir/${key}_output"; exitf="$dir/${key}_exit"
# Capture args for assertion
echo "$@" >> "$dir/call_log"
[[ -f "$resp" ]] && cat "$resp"
[[ -f "$exitf" ]] && exit "$(cat "$exitf")"
SCRIPT
    mkdir -p "$MOCK_DIR/gh_state"
    chmod +x "$MOCK_DIR/gh"
}
```

Then verify calls via `cat "$MOCK_DIR/gh_state/call_log"`.

---

### P2 — `create-tag-and-release.bats`

**Script:** `.github/scripts/release/create-tag-and-release.sh`
**Mocks:** `git`, `gh`
**Env vars:** `GH_TOKEN`

**Test cases:**

| #   | Test                    | Mock Setup                     | Assert                        |
| --- | ----------------------- | ------------------------------ | ----------------------------- |
| 1   | Successful release      | git/gh → success, GH_TOKEN set | status=0                      |
| 2   | Missing version arg     | n/a                            | status=1 (bash :? expansion)  |
| 3   | Missing notes file arg  | n/a                            | status=1 (bash :? expansion)  |
| 4   | Missing GH_TOKEN        | unset GH_TOKEN                 | status=1, stderr ∋ "GH_TOKEN" |
| 5   | git push fails          | git push → exit 1              | status!=0                     |
| 6   | gh release create fails | gh → exit 1                    | status!=0                     |

**Notes:** Low complexity — mostly argument validation. A dispatch mock
for git and a simple mock for gh are sufficient.

---

### P2 — `Invoke-ScriptAnalyzer.Tests.ps1`

**Script:** `.github/scripts/test/Invoke-ScriptAnalyzer.ps1`
**Framework:** Pester 5
**Mocking:** Mock `Invoke-ScriptAnalyzer`

**Test cases:**

| #   | Test                       | Mock Return                     | Assert |
| --- | -------------------------- | ------------------------------- | ------ |
| 1   | No diagnostics             | empty array                     | exit 0 |
| 2   | Only Info/Hint diagnostics | array with Severity=Information | exit 0 |
| 3   | Error diagnostic present   | array with Severity=Error       | exit 1 |
| 4   | Warning diagnostic present | array with Severity=Warning     | exit 1 |
| 5   | Mix of Info + Error        | both in array                   | exit 1 |

**Mocking pattern:**

```powershell
Mock Invoke-ScriptAnalyzer {
    @(
        [PSCustomObject]@{ RuleName='PSAvoidUsingWriteHost'; Severity='Warning';
                           ScriptName='test.ps1'; Line=5; Message='Avoid Write-Host' }
    )
}
```

**Notes:**

- The script calls the cmdlet directly (no wrapper), so `Mock` works.
- Need to dot-source or call with `&` since it uses `param()` at top
  level rather than exporting a function.

---

### P3 — `Install-Pester.Tests.ps1`

**Script:** `.github/scripts/test/Install-Pester.ps1`
**Framework:** Pester 5

**Test cases:**

| #   | Test                      | Mock Setup                         | Assert                                      |
| --- | ------------------------- | ---------------------------------- | ------------------------------------------- |
| 1   | Installs correct versions | Mock Install-Module, Import-Module | Install-Module called with 5.7.1 and 1.24.0 |
| 2   | Uses CurrentUser scope    | same                               | -Scope CurrentUser in call                  |
| 3   | Uses -Force flag          | same                               | -Force present in call                      |

**Notes:** Very low value — tests only verify exact parameter passing.
Include for completeness but lowest priority.

---

### P3 — `install-bats.bats`

**Script:** `.github/scripts/test/install-bats.sh`
**Mocks:** `sudo`, `bats`

**Test cases:**

| #   | Test                          | Mock Setup                | Assert                                        |
| --- | ----------------------------- | ------------------------- | --------------------------------------------- |
| 1   | Calls npm with pinned version | Mock sudo, bats           | sudo called with "npm install -g bats@1.11.1" |
| 2   | Reports bats version          | Mock bats → "Bats 1.11.1" | stdout ∋ "1.11.1"                             |

**Notes:** Requires mocking `sudo` to capture its arguments without
actually running privileged commands. Low priority.

---

## Implementation Phasing

### Phase 1 — Foundation + P0 Tests

1. Create `tests/unit/bash/ci/ci_test_helper.bash` with helpers above
2. Write `extract-version.bats` (9 tests)
3. Write `extract-changelog.bats` (9 tests)
4. Write `detect-change-scope.bats` (9 tests)

These 3 scripts have the highest test value-to-effort ratio — pure logic,
no heavyweight mocking, high risk if broken.

**Estimated test count: ~27 tests**

### Phase 2 — P1 Tests

4. Write `Invoke-Validation.Tests.ps1` (8 tests)
5. Write `back-merge.bats` (6 tests)
6. Write `create-backmerge-pr.bats` (7 tests)

Heavier mocking but important business logic.

**Estimated test count: ~21 tests**

### Phase 3 — P2 + P3 Tests + CI

7. Write `create-tag-and-release.bats` (6 tests)
8. Write `Invoke-ScriptAnalyzer.Tests.ps1` (5 tests)
9. Write `Install-Pester.Tests.ps1` (3 tests)
10. Write `install-bats.bats` (2 tests)
11. Update `unit-tests.yml` path filters

**Estimated test count: ~16 tests**

### Total: ~64 tests across 10 test files + 1 helper

---

## Open Questions

1. **Back-merge test isolation** — The back-merge script modifies git
   state aggressively (`reset --hard`, `merge`, `push`). Tests must
   ensure the mock intercepts ALL git calls. Should we also set
   `GIT_DIR` to a temp location as a safety net?

2. **PSScriptAnalyzer coverage** — Should the CI workflow's
   PSScriptAnalyzer step also lint `.github/scripts/*.ps1` files?
   Currently it only lints `skills/azure-cost-calculator/scripts/`.
   (Recommendation: yes — added to CI changes above.)

3. **Cross-platform test runners** — The bats tests assume Linux
   utilities (`openssl`, `grep`, `awk`). The existing skill tests have
   the same assumption and run on `ubuntu-latest`. Confirm CI-only
   scope is acceptable (no local macOS bats runner needed for CI tests).
