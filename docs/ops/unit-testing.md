# Unit Testing: Operations Guide

Unit tests for the core skill scripts and CI workflow scripts (PowerShell + Bash) using **Pester 5** and **bats-core**.

| Item            | Detail                                                                                                      |
| --------------- | ----------------------------------------------------------------------------------------------------------- |
| Workflow source | `.github/workflows/unit-tests.yml`                                                                          |
| Test root       | `tests/unit/`                                                                                               |
| PS runner       | `tests/unit/Run-PesterTests.ps1`                                                                            |
| Bash runner     | `tests/unit/run-bats-tests.sh`                                                                              |
| Trigger         | PRs and pushes touching `skills/azure-cost-calculator/scripts/**`, `tests/unit/**`, or `.github/scripts/**` |

---

## What it does

The unit testing framework validates two categories of scripts:

### Core skill scripts

The 12 scripts that ship to users via the skill plugin:

| Layer   | PowerShell                    | Bash                           |
| ------- | ----------------------------- | ------------------------------ |
| Main    | Get-AzurePricing.ps1          | get-azure-pricing.sh           |
|         | Explore-AzurePricing.ps1      | explore-azure-pricing.sh       |
| Library | Build-ODataFilter.ps1         | build-odata-filter.sh          |
|         | Get-MonthlyMultiplier.ps1     | get-monthly-multiplier.sh      |
|         | Get-ReservationTermMonths.ps1 | get-reservation-term-months.sh |
|         | Invoke-RetailPricesQuery.ps1  | invoke-retail-prices-query.sh  |

### CI workflow scripts

The 10 scripts under `.github/scripts/` that power the GitHub Actions workflows:

| Directory   | Script                      | Purpose                                 |
| ----------- | --------------------------- | --------------------------------------- |
| `release/`  | `extract-version.sh`        | Read + validate semver from plugin.json |
|             | `extract-changelog.sh`      | Extract changelog section via awk       |
|             | `create-tag-and-release.sh` | Create annotated tag + GitHub Release   |
|             | `back-merge.sh`             | 3-attempt retry merge of main into dev  |
|             | `create-backmerge-pr.sh`    | Fallback PR when merge fails            |
| `validate/` | `detect-change-scope.sh`    | Classify PR changes (service vs infra)  |
|             | `Invoke-Validation.ps1`     | 3-mode validation wrapper               |
| `test/`     | `Install-Pester.ps1`        | Install Pester + PSScriptAnalyzer       |
|             | `Invoke-ScriptAnalyzer.ps1` | Lint with Error/Warning fail gate       |
|             | `install-bats.sh`           | Install bats-core + jq                  |

Tests run **offline**; external API calls (`Invoke-RestMethod`, `curl`) and CI commands (`git`, `gh`) are mocked with synthetic data. Library functions are exercised with their real implementations.

---

## Prerequisites

### Local development

| Tool             | Install                                                                                  |
| ---------------- | ---------------------------------------------------------------------------------------- |
| PowerShell 5.1+  | Windows PowerShell 5.1 (built-in) or [pwsh 7+](https://aka.ms/install-powershell)        |
| Pester 5.7.1+    | `Install-Module Pester -MinimumVersion 5.7.1 -Force -Scope CurrentUser`                  |
| PSScriptAnalyzer | `Install-Module PSScriptAnalyzer -RequiredVersion 1.24.0 -Force -Scope CurrentUser`      |
| bats-core        | `brew install bats-core` (macOS) · `npm i -g bats` (Ubuntu/CI) · `sudo apt install bats` |
| jq               | `brew install jq` (macOS) · `sudo apt-get install jq` (Ubuntu)                           |

> **Note:** The test runner requires Pester 5.7.1 or later. If a compatible version is not installed, the runner will print a warning and exit. It does **not** auto-install Pester.

### CI

The GitHub Actions workflow installs Pester 5.7.1, PSScriptAnalyzer 1.24.0, and bats-core automatically; no manual setup needed.

---

## Running tests locally

### All PowerShell tests

```bash
# PowerShell 7+ (macOS / Linux / Windows)
pwsh tests/unit/Run-PesterTests.ps1

# Windows PowerShell 5.1
powershell.exe -ExecutionPolicy Bypass -File tests/unit/Run-PesterTests.ps1
```

Options:

- `-OutputFormat Detailed` (default) / `Normal` / `Minimal`
- `-CIOutputPath results/pester.xml`: write NUnit XML report

### All Bash tests

```bash
bash tests/unit/run-bats-tests.sh
```

Options:

- `--tap`: TAP output for CI
- Pass a specific `.bats` file to run only that test

### Single test file

```bash
# PowerShell: run one test file directly
pwsh -Command "Invoke-Pester tests/unit/powershell/lib/Build-ODataFilter.Tests.ps1 -Output Detailed"

# Bash: run one bats file
bats tests/unit/bash/lib/build-odata-filter.bats
```

---

## Adding new tests

### Directory layout

```
tests/unit/
  powershell/
    lib/              ← library function tests (skill scripts)
    ci/               ← CI workflow script tests (.github/scripts/)
    *.Tests.ps1       ← main script tests
  bash/
    lib/              ← library function tests (skill scripts)
    ci/               ← CI workflow script tests (.github/scripts/)
    test_helper.bash  ← shared helpers (mock utilities)
    *.bats            ← main script tests
```

Tests **mirror the source layout**: each source file in `skills/azure-cost-calculator/scripts/` has a corresponding test file, and each script in `.github/scripts/` has a corresponding test in the `ci/` subdirectory.

### PowerShell (Pester 5)

1. Create `tests/unit/powershell/<Name>.Tests.ps1` (or `lib/<Name>.Tests.ps1` for library functions).
2. Dot-source the function under test in `BeforeAll`:
   ```powershell
   BeforeAll {
       . "$PSScriptRoot/../../../../skills/azure-cost-calculator/scripts/lib/MyFunction.ps1"
   }
   ```
3. Use `Describe` / `Context` / `It` blocks following AAA pattern.
4. Mock `Invoke-RestMethod` for any test that would hit the API.
5. Run: `pwsh tests/unit/Run-PesterTests.ps1` (or `powershell.exe -ExecutionPolicy Bypass -File tests/unit/Run-PesterTests.ps1` on Windows PS 5.1)

### Bash (bats-core)

1. Create `tests/unit/bash/<name>.bats` (or `lib/<name>.bats`).
2. Source the helper and function in `setup()`:
   ```bash
   setup() {
       source "$BATS_TEST_DIRNAME/../test_helper.bash"  # or ../../test_helper.bash for lib/
       source "$LIB_DIR/my-function.sh"
   }
   ```
3. Use `@test "description" { ... }` blocks with `run` and assertions.
4. For API-calling functions, use `setup_mock_path` + `create_curl_mock` to mock curl.
5. Run: `bash tests/unit/run-bats-tests.sh`

### CI workflow scripts (`.github/scripts/`)

CI script tests live under `tests/unit/bash/ci/` and `tests/unit/powershell/ci/`. They follow the same framework conventions but use additional helpers for mocking `git`, `gh`, and `$GITHUB_OUTPUT`.

**Bash (bats-core):**

1. Create `tests/unit/bash/ci/<name>.bats`.
2. Source the CI helper in `setup()`:
   ```bash
   setup() {
       source "$BATS_TEST_DIRNAME/../test_helper.bash"
       source "$BATS_TEST_DIRNAME/ci_test_helper.bash"
       setup_mock_path
       setup_github_output   # if script writes to $GITHUB_OUTPUT
   }
   teardown() {
       teardown_github_output
       teardown_mock_path
   }
   ```
3. Run scripts via `run bash "$CI_SCRIPTS_DIR/release/my-script.sh" args...`.
4. Mock `git` with `create_git_dispatch_mock` + `set_git_response`.
5. Mock `gh` with `create_gh_dispatch_mock` + `set_gh_response`.
6. Read outputs with `get_output_value KEY` or `get_output_heredoc KEY`.

**PowerShell (Pester 5):**

1. Create `tests/unit/powershell/ci/<Name>.Tests.ps1`.
2. Reference the script in `BeforeAll`:
   ```powershell
   BeforeAll {
       $script:ScriptPath = Join-Path $PSScriptRoot '../../../../.github/scripts/validate/Invoke-Validation.ps1'
   }
   ```
3. For scripts that call external `.ps1` files, create a mock script in `$TestDrive` that logs its parameters to a JSON file for assertions.

### Shared Bash helpers (`test_helper.bash`)

| Helper                               | Purpose                                   |
| ------------------------------------ | ----------------------------------------- |
| `SCRIPTS_DIR` / `LIB_DIR`            | Absolute paths to source scripts          |
| `setup_mock_path`                    | Creates temp dir, prepends to `$PATH`     |
| `teardown_mock_path`                 | Cleans up temp mock dir                   |
| `create_mock cmd output [exit_code]` | Creates a mock executable                 |
| `create_curl_mock body [http_code]`  | curl mock mimicking `-w '\n%{http_code}'` |

### CI test helpers (`ci/ci_test_helper.bash`)

Extends the base `test_helper.bash` with utilities for testing CI scripts that interact with `git`, `gh`, and `$GITHUB_OUTPUT`:

| Helper                                           | Purpose                                            |
| ------------------------------------------------ | -------------------------------------------------- |
| `CI_SCRIPTS_DIR`                                 | Absolute path to `.github/scripts/`                |
| `setup_github_output` / `teardown_github_output` | Create/cleanup temp `$GITHUB_OUTPUT` file          |
| `get_output_value KEY`                           | Read a `key=value` line from `$GITHUB_OUTPUT`      |
| `get_output_heredoc KEY`                         | Read a heredoc value from `$GITHUB_OUTPUT`         |
| `create_git_dispatch_mock` / `set_git_response`  | Mock `git` with per-subcommand routing             |
| `create_gh_dispatch_mock` / `set_gh_response`    | Mock `gh` with per-subcommand routing + call log   |
| `create_sequenced_mock CMD "out\|rc" ...`        | Mock that returns different results per invocation |

---

## Troubleshooting

| Symptom                                                | Likely cause                         | Fix                                                                     |
| ------------------------------------------------------ | ------------------------------------ | ----------------------------------------------------------------------- |
| `Pester 5.7.1 or later is required but not installed.` | Module not installed or too old      | `Install-Module Pester -MinimumVersion 5.7.1 -Force -Scope CurrentUser` |
| `bats: command not found`                              | bats-core not installed              | `brew install bats-core` / `apt install bats` / `npm i -g bats`         |
| `jq: command not found`                                | jq missing for bash tests            | `brew install jq` / `apt install jq`                                    |
| Pester test hangs                                      | Mock missing for `Invoke-RestMethod` | Add `Mock Invoke-RestMethod { ... }` in `BeforeAll`                     |
| bats test fails with curl error                        | Mock not on PATH                     | Ensure `setup_mock_path` called in `setup()`                            |
| Tests pass locally, fail in CI                         | Path differences                     | Use `$PSScriptRoot` / `$BATS_TEST_DIRNAME` for relative paths           |
| PS 5.1 scripts won't load                              | Execution policy restriction         | Run with `-ExecutionPolicy Bypass` flag                                 |

---

## PS 5.1 compatibility notes

Tests run on both **PowerShell 7+ (pwsh)** and **Windows PowerShell 5.1**. When writing tests, be aware of these runtime differences:

| Behaviour                               | PS 7+                                                                                                                                  | PS 5.1                                                           | Mitigation                                                                                                                                   |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `ConvertFrom-Json` on arrays            | Unwraps to individual objects                                                                                                          | Returns a single nested array object                             | Use a `ConvertFrom-JsonArray` helper that pipes through `ForEach-Object { $_ }`                                                              |
| Function returning `@()` single-element | Preserves array                                                                                                                        | Unwraps to scalar                                                | Wrap call site with `@()` to force array                                                                                                     |
| `[System.Uri]::EscapeDataString("'")`   | Encodes to `%27` (.NET 8)                                                                                                              | Keeps `'` as-is (.NET 4.x)                                       | Assert with `-match` accepting both forms                                                                                                    |
| Network error exception types           | `Invoke-RestMethod` throws `TaskCanceledException` (timeouts) or `HttpRequestException` (connection failures); no `.Response` property | Throws `WebException` (no `.Response` for network errors)        | Check `$_.Exception -is [System.OperationCanceledException]`, `-is [System.Net.WebException]`, and string compare for `HttpRequestException` |
| `[type]` resolution for HTTP types      | `[System.Net.Http.HttpRequestException]` always available                                                                              | May not be loaded; `[type]` literal can throw `RuntimeException` | Use `$_.Exception.GetType().FullName -eq 'System.Net.Http.HttpRequestException'` for safe cross-version checks                               |
| Typed `catch` blocks                    | Typed `catch` works; common HTTP exceptions (e.g. `[HttpRequestException]`) are available                                              | Typed `catch` works, but some HTTP exception types may not exist | First `catch [System.Net.WebException]`, then generic `catch` with duck-typing on `$_.Exception.Response` / `.StatusCode`                    |
| Execution policy                        | Honours Windows execution policy (often RemoteSigned); unrestricted on macOS/Linux                                                     | May block unsigned scripts                                       | Pass `-ExecutionPolicy Bypass` flag                                                                                                          |

### The `ConvertFrom-JsonArray` helper

The `Explore-AzurePricing` Pester tests define a helper in their `Describe` `BeforeAll` block to normalize JSON array parsing (reuse this pattern in other tests as needed):

```powershell
function ConvertFrom-JsonArray {
    param([string]$Json)
    @($Json | ConvertFrom-Json | ForEach-Object { $_ })
}
```

Use it wherever a mock returns a JSON array:

```powershell
$items = ConvertFrom-JsonArray $jsonString
```

> **Note:** The actual test file uses `script:` scope (`function script:ConvertFrom-JsonArray`) because it is defined inside a Pester `BeforeAll` block. Adapt the scope to your context.

---

## References

- [Pester 5 documentation](https://pester.dev/docs/quick-start): PowerShell testing framework
- [bats-core documentation](https://bats-core.readthedocs.io/): Bash testing framework
