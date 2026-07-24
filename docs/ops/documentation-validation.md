# Documentation Validation: Operations Guide

## What it does

`tests/docs/validate_documentation.py` enforces the mechanical parts of the
[Documentation Operating Model](../documentation-model.md). It scans repository
Markdown for broken local links and scans `specs/` initiative artifacts for:

- required metadata and lifecycle status;
- duplicate authority domains;
- invalid or duplicate `REQ-*`, `ADR-*`, `WP-*`, `OPEN-*`, and `EVID-*`
  definitions;
- unresolved placeholders in active artifacts;
- malformed heading structure;
- historical artifacts claiming authority;
- incomplete work-package delivery contracts; and
- active work packages that reference superseded decisions.

The check does not decide whether prose is clear or whether two differently
worded statements represent the same knowledge. Those remain review tasks.

## Prerequisites

- Python 3.10 or later.
- No third-party packages.

## Running locally

From the repository root:

```bash
python3 tests/docs/validate_documentation.py
```

Run the validator after changing `specs/`, the documentation model, initiative
templates, or local Markdown links.

## Making changes

- Edit validation logic in `tests/docs/validate_documentation.py`.
- Add regression coverage in `tests/docs/test_validate_documentation.py`.
- Keep the script dependency-free unless a demonstrated Markdown parsing need
  justifies a maintained dependency.
- Update `docs/documentation-model.md` before enforcing a new repository rule.
- Keep generated and historical artifacts excluded only when their role makes a
  rule inapplicable; do not add broad path exceptions to hide failures.

The GitHub Actions workflow is
`.github/workflows/validate-documentation.yml`. It runs on every pull request so
the required check is always reported, and executes the same local commands.

## Troubleshooting

| Failure                            | Likely cause                                        | Resolution                                                             |
| ---------------------------------- | --------------------------------------------------- | ---------------------------------------------------------------------- |
| Broken local link                  | Target path or heading changed                      | Update the link or restore a stable heading                            |
| Duplicate authority                | Two active artifacts list the same authority domain | Select one owner and turn the other into a view or historical artifact |
| Unknown identifier                 | A reference has no active definition                | Correct the ID or add its authoritative definition                     |
| Missing work-package field         | A `WP-*` cannot be assigned independently           | Add the missing delivery-contract field                                |
| Historical artifact owns knowledge | Historical front matter has a non-empty `authority` | Set `authority: []` and link the current owner                         |
| Superseded ADR reference           | Active delivery still depends on an obsolete choice | Reference the replacement ADR and update affected scope                |

## External references

- [CommonMark specification](https://spec.commonmark.org/)
- [GitHub documentation: basic writing and formatting syntax](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)
