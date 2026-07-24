#!/usr/bin/env python3

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from validate_documentation import DocumentationValidator


ENTRY = """---
initiative: sample
artifact: entrypoint
status: proposed
owner: maintainer
authority: []
---
# Sample
## Purpose
[Requirements](requirements.md)
"""

REQUIREMENTS = """---
initiative: sample
artifact: requirements
status: accepted
owner: maintainer
authority: [requirements]
---
# Requirements
## REQ-001 — Behaviour
Required behaviour.
"""

DELIVERY = """---
initiative: sample
artifact: delivery
status: proposed
owner: maintainer
authority: [delivery]
---
# Delivery
## WP-001 — Implement
**Status:** Proposed
**Objective:** Deliver it.
**Requirement references:** `REQ-001`
**Decision references:** None.
**Dependencies and blockers:** None.
**In scope:**
- Work.
**Out of scope:**
- Other work.
**Expected files or outputs:**
- Output.
**Acceptance criteria:**
- Passes.
**Validation commands:**
`true`
**Operational or documentation updates:**
- None.
**Permitted assumptions:**
- None.
**Approval-required decisions:**
- None.
**Completion evidence:** Pending.
"""


class DocumentationValidatorTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary_directory.name)
        initiative = self.root / "specs" / "sample"
        initiative.mkdir(parents=True)
        (initiative / "README.md").write_text(ENTRY, encoding="utf-8")
        (initiative / "requirements.md").write_text(REQUIREMENTS, encoding="utf-8")
        (initiative / "work-packages.md").write_text(DELIVERY, encoding="utf-8")

    def tearDown(self) -> None:
        self.temporary_directory.cleanup()

    def validate(self) -> list[str]:
        return DocumentationValidator(self.root).validate()

    def test_valid_initiative_passes(self) -> None:
        self.assertEqual([], self.validate())

    def test_duplicate_authority_fails(self) -> None:
        duplicate = REQUIREMENTS.replace("# Requirements", "# Other requirements")
        (self.root / "specs" / "sample" / "other.md").write_text(duplicate, encoding="utf-8")
        self.assertTrue(any("already owned" in error for error in self.validate()))

    def test_broken_link_fails(self) -> None:
        readme = (self.root / "specs" / "sample" / "README.md")
        readme.write_text(ENTRY.replace("requirements.md", "missing.md"), encoding="utf-8")
        self.assertTrue(any("broken local link" in error for error in self.validate()))

    def test_missing_work_package_field_fails(self) -> None:
        delivery = self.root / "specs" / "sample" / "work-packages.md"
        delivery.write_text(
            DELIVERY.replace("**Completion evidence:** Pending.\n", ""),
            encoding="utf-8",
        )
        self.assertTrue(any("Completion evidence" in error for error in self.validate()))

    def test_unknown_identifier_fails(self) -> None:
        delivery = self.root / "specs" / "sample" / "work-packages.md"
        delivery.write_text(DELIVERY.replace("REQ-001", "REQ-999"), encoding="utf-8")
        self.assertTrue(any("unknown identifier reference REQ-999" in error for error in self.validate()))

    def test_historical_artifact_cannot_claim_authority(self) -> None:
        historical = """---
initiative: sample
artifact: historical
status: historical
owner: maintainer
authority: [requirements]
---
# Old plan
"""
        (self.root / "specs" / "sample" / "old.md").write_text(historical, encoding="utf-8")
        self.assertTrue(any("historical artifacts must use authority" in error for error in self.validate()))

    def test_placeholder_fails(self) -> None:
        requirements = self.root / "specs" / "sample" / "requirements.md"
        requirements.write_text(REQUIREMENTS + "\nTODO: decide this.\n", encoding="utf-8")
        self.assertTrue(any("unresolved placeholder" in error for error in self.validate()))

    def test_superseded_decision_reference_fails(self) -> None:
        decision = """---
initiative: sample
artifact: decisions
status: accepted
owner: maintainer
authority: [technical-decisions]
---
# Decisions
## ADR-001 — Old choice
**Status:** Superseded
"""
        (self.root / "specs" / "sample" / "decisions.md").write_text(decision, encoding="utf-8")
        delivery = self.root / "specs" / "sample" / "work-packages.md"
        delivery.write_text(
            DELIVERY.replace("**Decision references:** None.", "**Decision references:** `ADR-001`"),
            encoding="utf-8",
        )
        self.assertTrue(any("references superseded ADR-001" in error for error in self.validate()))


if __name__ == "__main__":
    unittest.main()
