#!/usr/bin/env python3
"""Validate repository Markdown and initiative documentation contracts."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import unquote


ID_RE = re.compile(r"\b(REQ|ADR|WP|OPEN|EVID)-\d{3}\b")
ID_DEFINITION_RE = re.compile(r"^##\s+((?:REQ|ADR|WP|OPEN|EVID)-\d{3})\b", re.MULTILINE)
LINK_RE = re.compile(r"!?\[[^\]]*]\(([^)\n]+)\)")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$", re.MULTILINE)
PLACEHOLDER_RE = re.compile(r"\b(?:TODO|TBD|FIXME|PLACEHOLDER)\b")

REQUIRED_METADATA = {"initiative", "artifact", "status", "owner", "authority"}
HISTORICAL_STATUSES = {"historical", "superseded", "cancelled"}
WORK_PACKAGE_FIELDS = (
    "Status",
    "Objective",
    "Requirement references",
    "Decision references",
    "Dependencies and blockers",
    "In scope",
    "Out of scope",
    "Expected files or outputs",
    "Acceptance criteria",
    "Validation commands",
    "Operational or documentation updates",
    "Permitted assumptions",
    "Approval-required decisions",
    "Completion evidence",
)


@dataclass
class Document:
    path: Path
    text: str
    metadata: dict[str, object]
    body: str


def parse_front_matter(text: str) -> tuple[dict[str, object], str]:
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, text

    try:
        end = next(i for i, line in enumerate(lines[1:], start=1) if line.strip() == "---")
    except StopIteration:
        return {}, text

    metadata: dict[str, object] = {}
    for line in lines[1:end]:
        if not line.strip() or line.lstrip().startswith("#") or ":" not in line:
            continue
        key, raw_value = line.split(":", 1)
        value = raw_value.strip()
        if value.startswith("[") and value.endswith("]"):
            inner = value[1:-1].strip()
            metadata[key.strip()] = (
                [item.strip().strip("'\"") for item in inner.split(",") if item.strip()]
                if inner
                else []
            )
        else:
            metadata[key.strip()] = value.strip("'\"")
    return metadata, "\n".join(lines[end + 1 :])


def markdown_files(root: Path) -> list[Path]:
    ignored_parts = {".git", "node_modules", "results"}
    return sorted(
        path
        for path in root.rglob("*.md")
        if not path.is_symlink()
        and not ignored_parts.intersection(path.relative_to(root).parts)
    )


def initiative_documents(root: Path) -> list[Document]:
    specs = root / "specs"
    if not specs.exists():
        return []
    documents = []
    for path in sorted(specs.rglob("*.md")):
        text = path.read_text(encoding="utf-8")
        metadata, body = parse_front_matter(text)
        documents.append(Document(path, text, metadata, body))
    return documents


def github_slug(heading: str) -> str:
    slug = heading.strip().lower()
    slug = re.sub(r"[^\w\- ]", "", slug, flags=re.UNICODE)
    return slug.replace(" ", "-")


def heading_slugs(path: Path) -> set[str]:
    text = path.read_text(encoding="utf-8")
    counts: dict[str, int] = {}
    slugs: set[str] = set()
    for _, heading in HEADING_RE.findall(text):
        base = github_slug(re.sub(r"\s+#+$", "", heading))
        count = counts.get(base, 0)
        counts[base] = count + 1
        slugs.add(base if count == 0 else f"{base}-{count}")
    return slugs


def strip_code_fences(text: str) -> str:
    return re.sub(r"```.*?```", "", text, flags=re.DOTALL)


class DocumentationValidator:
    def __init__(self, root: Path):
        self.root = root.resolve()
        self.errors: list[str] = []
        self.documents = initiative_documents(self.root)

    def error(self, path: Path, message: str) -> None:
        try:
            display = path.resolve().relative_to(self.root)
        except ValueError:
            display = path
        self.errors.append(f"{display}: {message}")

    def validate(self) -> list[str]:
        self.check_local_links()
        self.check_metadata_and_authority()
        self.check_headings()
        self.check_placeholders()
        self.check_identifiers()
        self.check_work_packages()
        self.check_superseded_decision_references()
        return self.errors

    def check_local_links(self) -> None:
        slug_cache: dict[Path, set[str]] = {}
        for source in markdown_files(self.root):
            text = source.read_text(encoding="utf-8")
            for raw_target in LINK_RE.findall(text):
                target = raw_target.strip()
                if target.startswith("<") and ">" in target:
                    target = target[1 : target.index(">")]
                else:
                    target = target.split(maxsplit=1)[0]
                target = unquote(target)
                if (
                    not target
                    or target.startswith(("http://", "https://", "mailto:", "data:"))
                    or any(marker in target for marker in ("{", "}", "replace-with"))
                ):
                    continue

                path_text, separator, fragment = target.partition("#")
                resolved = (source.parent / path_text).resolve() if path_text else source.resolve()
                try:
                    resolved.relative_to(self.root)
                except ValueError:
                    # Repository-relative GitHub navigation such as ../../issues/new
                    # intentionally resolves outside a local checkout.
                    continue

                if not resolved.exists():
                    self.error(source, f"broken local link: {target}")
                    continue
                if resolved.is_dir():
                    continue
                if separator and fragment and resolved.suffix.lower() == ".md":
                    slugs = slug_cache.setdefault(resolved, heading_slugs(resolved))
                    if fragment.lower() not in slugs:
                        self.error(source, f"missing Markdown anchor '{fragment}' in {target}")

    def check_metadata_and_authority(self) -> None:
        ownership: dict[tuple[str, str], Path] = {}
        for document in self.documents:
            missing = sorted(REQUIRED_METADATA - document.metadata.keys())
            if missing:
                self.error(document.path, f"missing front-matter fields: {', '.join(missing)}")
                continue

            initiative = str(document.metadata["initiative"])
            status = str(document.metadata["status"]).lower()
            artifact = str(document.metadata["artifact"]).lower()
            authority = document.metadata["authority"]
            if not isinstance(authority, list):
                self.error(document.path, "authority must be an inline YAML list")
                continue

            if artifact in {"historical", "entrypoint", "view"} and authority:
                self.error(document.path, f"{artifact} artifacts must use authority: []")
            if status in HISTORICAL_STATUSES and authority:
                self.error(document.path, f"{status} artifacts cannot claim authority")

            if status not in HISTORICAL_STATUSES:
                for domain in authority:
                    key = (initiative, str(domain))
                    if key in ownership:
                        self.error(
                            document.path,
                            f"authority '{domain}' is already owned by "
                            f"{ownership[key].relative_to(self.root)}",
                        )
                    else:
                        ownership[key] = document.path

    def check_headings(self) -> None:
        for document in self.documents:
            headings = HEADING_RE.findall(strip_code_fences(document.body))
            h1_count = sum(1 for marks, _ in headings if len(marks) == 1)
            if h1_count != 1:
                self.error(document.path, f"expected exactly one H1 heading, found {h1_count}")
            previous = 0
            for marks, heading in headings:
                level = len(marks)
                if previous and level > previous + 1:
                    self.error(
                        document.path,
                        f"heading level jumps from H{previous} to H{level} at '{heading}'",
                    )
                previous = level

    def check_placeholders(self) -> None:
        for document in self.documents:
            status = str(document.metadata.get("status", "")).lower()
            if status in HISTORICAL_STATUSES:
                continue
            cleaned = strip_code_fences(document.body)
            match = PLACEHOLDER_RE.search(cleaned)
            if match:
                self.error(document.path, f"unresolved placeholder: {match.group(0)}")

    def check_identifiers(self) -> None:
        by_initiative: dict[str, list[Document]] = {}
        for document in self.documents:
            status = str(document.metadata.get("status", "")).lower()
            if status not in HISTORICAL_STATUSES:
                by_initiative.setdefault(str(document.metadata.get("initiative", "")), []).append(
                    document
                )

        for initiative, documents in by_initiative.items():
            definitions: dict[str, Path] = {}
            occurrences: list[tuple[str, Path]] = []
            for document in documents:
                for identifier in ID_DEFINITION_RE.findall(document.body):
                    if identifier in definitions:
                        self.error(
                            document.path,
                            f"duplicate definition {identifier}; first defined in "
                            f"{definitions[identifier].relative_to(self.root)}",
                        )
                    else:
                        definitions[identifier] = document.path
                occurrences.extend((match.group(0), document.path) for match in ID_RE.finditer(document.body))

            for identifier, path in occurrences:
                if identifier not in definitions:
                    self.error(path, f"unknown identifier reference {identifier} in {initiative}")

    def check_work_packages(self) -> None:
        for document in self.documents:
            if str(document.metadata.get("artifact", "")).lower() != "delivery":
                continue
            matches = list(re.finditer(r"^##\s+(WP-\d{3})\b.*$", document.body, re.MULTILINE))
            for index, match in enumerate(matches):
                end = matches[index + 1].start() if index + 1 < len(matches) else len(document.body)
                section = document.body[match.end() : end]
                for field in WORK_PACKAGE_FIELDS:
                    pattern = re.compile(rf"^\*\*{re.escape(field)}:\*\*", re.MULTILINE)
                    if not pattern.search(section):
                        self.error(document.path, f"{match.group(1)} is missing field '{field}'")

    def check_superseded_decision_references(self) -> None:
        superseded: set[str] = set()
        for document in self.documents:
            if str(document.metadata.get("artifact", "")).lower() != "decisions":
                continue
            matches = list(re.finditer(r"^##\s+(ADR-\d{3})\b.*$", document.body, re.MULTILINE))
            for index, match in enumerate(matches):
                end = matches[index + 1].start() if index + 1 < len(matches) else len(document.body)
                section = document.body[match.end() : end]
                if re.search(r"^\*\*Status:\*\*\s+Superseded\b", section, re.MULTILINE):
                    superseded.add(match.group(1))

        if not superseded:
            return
        for document in self.documents:
            if str(document.metadata.get("artifact", "")).lower() != "delivery":
                continue
            for identifier in sorted(superseded):
                if re.search(rf"\b{re.escape(identifier)}\b", document.body):
                    self.error(document.path, f"active delivery references superseded {identifier}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[2],
        help="Repository root (defaults to this script's repository)",
    )
    args = parser.parse_args(argv)

    errors = DocumentationValidator(args.root).validate()
    if errors:
        print(f"Documentation validation failed with {len(errors)} error(s):")
        for error in errors:
            print(f"- {error}")
        return 1

    print("Documentation validation passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
