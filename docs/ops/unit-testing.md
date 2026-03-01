# Unit Testing — Operations Guide

Unit tests for the core skill scripts (PowerShell + Bash) using **Pester 5** and **bats-core**.

| Item            | Detail                                                                               |
| --------------- | ------------------------------------------------------------------------------------ |
| Original issue  | [#405](https://github.com/ahmadabdalla/azure-cost-calculator-skill/issues/405)       |
| Workflow source | `.github/workflows/unit-tests.yml`                                                   |
| Test root       | `tests/unit/`                                                                        |
| PS runner       | `tests/unit/Run-PesterTests.ps1`                                                     |
| Bash runner     | `tests/unit/run-bats-tests.sh`                                                       |
| Trigger         | PRs and pushes touching `skills/azure-cost-calculator/scripts/**` or `tests/unit/**` |

---

## What it does

The unit testing framework validates the 12 core scripts that ship to users via the skill plugin:

| Layer   | PowerShell                    | Bash                           |
| ------- | ----------------------------- | ------------------------------ |
| Main    | Get-AzurePricing.ps1          | get-azure-pricing.sh           |
|         | Explore-AzurePricing.ps1      | explore-azure-pricing.sh       |
| Library | Build-ODataFilter.ps1         | build-odata-filter.sh          |
|         | Get-MonthlyMultiplier.ps1     | get-monthly-multiplier.sh      |
|         | Get-ReservationTermMonths.ps1 | get-reservation-term-months.sh |
|         | Invoke-RetailPricesQuery.ps1  | invoke-retail-prices-query.sh  |

Tests run **offline** — external API calls (`Invoke-RestMethod`, `curl`) are mocked with synthetic data. Library functions are exercised with their real implementations.

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

The GitHub Actions workflow installs Pester 5.7.1, PSScriptAnalyzer 1.24.0, and bats-core automatically — no manual setup needed.

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
- `-CIOutputPath results/pester.xml` — write NUnit XML report

### All Bash tests

```bash
bash tests/unit/run-bats-tests.sh
```

Options:

- `--tap` — TAP output for CI
- Pass a specific `.bats` file to run only that test

### Single test file

```bash
# PowerShell — run one test file directly
pwsh -Command "Invoke-Pester tests/unit/powershell/lib/Build-ODataFilter.Tests.ps1 -Output Detailed"

# Bash — run one bats file
bats tests/unit/bash/lib/build-odata-filter.bats
```

---

## Adding new tests

### Directory layout

```
tests/unit/
  powershell/
    lib/              ← library function tests
    *.Tests.ps1       ← main script tests
  bash/
    lib/              ← library function tests
    test_helper.bash  ← shared helpers (mock utilities)
    *.bats            ← main script tests
```

Tests **mirror the source layout**: each source file in `skills/azure-cost-calculator/scripts/` has a corresponding test file.

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

### Shared Bash helpers (`test_helper.bash`)

| Helper                               | Purpose                                   |
| ------------------------------------ | ----------------------------------------- |
| `SCRIPTS_DIR` / `LIB_DIR`            | Absolute paths to source scripts          |
| `setup_mock_path`                    | Creates temp dir, prepends to `$PATH`     |
| `teardown_mock_path`                 | Cleans up temp mock dir                   |
| `create_mock cmd output [exit_code]` | Creates a mock executable                 |
| `create_curl_mock body [http_code]`  | curl mock mimicking `-w '\n%{http_code}'` |

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

| Behaviour                               | PS 7+                                                                                     | PS 5.1                                                           | Mitigation                                                                                                                |
| --------------------------------------- | ----------------------------------------------------------------------------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `ConvertFrom-Json` on arrays            | Unwraps to individual objects                                                             | Returns a single nested array object                             | Use a `ConvertFrom-JsonArray` helper that pipes through `ForEach-Object { $_ }`                                           |
| Function returning `@()` single-element | Preserves array                                                                           | Unwraps to scalar                                                | Wrap call site with `@()` to force array                                                                                  |
| `[System.Uri]::EscapeDataString("'")`   | Encodes to `%27` (.NET 8)                                                                 | Keeps `'` as-is (.NET 4.x)                                       | Assert with `-match` accepting both forms                                                                                 |
| Typed `catch` blocks                    | Typed `catch` works; common HTTP exceptions (e.g. `[HttpRequestException]`) are available | Typed `catch` works, but some HTTP exception types may not exist | First `catch [System.Net.WebException]`, then generic `catch` with duck-typing on `$_.Exception.Response` / `.StatusCode` |
| Execution policy                        | Honours Windows execution policy (often RemoteSigned); unrestricted on macOS/Linux        | May block unsigned scripts                                       | Pass `-ExecutionPolicy Bypass` flag                                                                                       |

### The `ConvertFrom-JsonArray` helper

The `Explore-AzurePricing` Pester tests define a helper in their `Describe` `BeforeAll` block to normalize JSON array parsing (reuse this pattern in other tests as needed):

```powershell
function ConvertFrom-JsonArray {
    param([string]$Json)
    $Json | ConvertFrom-Json | ForEach-Object { $_ }
}
```

Use it wherever a mock returns a JSON array, and wrap the call site with `@()` to guarantee array type:

```powershell
$items = @(ConvertFrom-JsonArray $jsonString)
```

---

## References

- [Pester 5 documentation](https://pester.dev/docs/quick-start) — PowerShell testing framework
- [bats-core documentation](https://bats-core.readthedocs.io/) — Bash testing framework
- [Issue #405](https://github.com/ahmadabdalla/azure-cost-calculator-skill/issues/405) — original unit testing requirement
- [Issue #411](https://github.com/ahmadabdalla/azure-cost-calculator-skill/issues/411) — PS 5.1 compatibility regressions
- [PR #414](https://github.com/ahmadabdalla/azure-cost-calculator-skill/pull/414) — PS 5.1 fixes
