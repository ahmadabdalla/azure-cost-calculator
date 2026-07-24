# Documentation Operating Model

This guide standardizes how project knowledge is owned and connected. It does
not require every initiative to use the same files or headings.

## Principles

1. Every normative fact has one authoritative home.
2. Documents have orthogonal responsibilities: requirements describe required
   behaviour, decisions explain choices, and delivery artifacts describe work.
3. Views link to authoritative knowledge instead of copying it.
4. Historical evidence explains how the project arrived at its current state
   but cannot override active requirements or decisions.
5. Volatile facts carry an `as of` date and a primary source.
6. Assumptions, accepted decisions, and open questions are visibly distinct.
7. Plain-text, version-controlled documents and small automated checks are the
   default.
8. Documentation updates are part of delivery and acceptance criteria.

## Artifact types and ownership

| Artifact type                                                                       | Category                   | Owns                                                                                                                     | Must not own                                           |
| ----------------------------------------------------------------------------------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------ |
| Initiative entry point                                                              | View                       | Navigation metadata, current position, artifact inventory, ownership map, active questions                               | Detailed requirements, rationale, or task instructions |
| Brief or requirements contract                                                      | Authoritative              | Purpose, scope, behavioural requirements, quality gates, security requirements, API or data contracts when kept together | Technology rationale or delivery sequencing            |
| Decision record or register                                                         | Authoritative              | A selected option, status, context, rationale, tradeoffs, and reversal conditions                                        | Product behaviour or task status                       |
| Delivery plan and work packages                                                     | Authoritative              | Assignable work, dependencies, sequence, acceptance criteria, and completion evidence                                    | Restated requirements or technology rationale          |
| API or data contract                                                                | Authoritative, optional    | Versioned schemas, compatibility rules, examples, and error semantics                                                    | Product rationale or implementation schedule           |
| Threat or security contract                                                         | Authoritative, optional    | Threats, trust boundaries, required controls, residual risks, and review cadence                                         | General product requirements already owned elsewhere   |
| Cost record                                                                         | Authoritative, optional    | Dated assumptions, sourced prices, usage model, estimates, and sensitivity                                               | Undated prices or business requirements                |
| Operations guide                                                                    | Authoritative              | Current deployment, rollback, recovery, maintenance, incident, and troubleshooting procedures                            | Proposed behaviour or historical experiments           |
| Evidence register or result set                                                     | Authoritative for evidence | Dated external verification, experiment method, raw results, and conclusions                                             | Unsourced requirements or silent design changes        |
| Architecture overview, implementation brief, status report, diagram, handoff prompt | View                       | Audience-specific presentation and links                                                                                 | Independent normative facts                            |
| Interview output, research notes, experiment log, superseded plan                   | Historical evidence        | Decision history and provenance                                                                                          | Active authority                                       |

An artifact may own several closely related knowledge domains. The same domain
must not be listed in the `authority` metadata of two active artifacts for the
same initiative.

## Allowed dependencies

```text
historical evidence ──> decisions ──┐
external evidence ────> decisions ──┼──> work packages ──> delivery evidence
requirements ───────────────────────┘
        │
        ├──> operations, threat, API/data, and cost artifacts when needed
        └──> audience views
```

- Decisions cite requirements and evidence.
- Work packages cite requirements and accepted decisions.
- Operations, threat, API/data, and cost artifacts cite the requirements or
  decisions they implement.
- Views cite authoritative artifacts.
- Historical artifacts may be cited as provenance but are never a dependency
  for discovering current normative behaviour.

## Initiative profiles

Profiles are prompts for selecting useful artifacts, not compliance bundles.
Do not create an empty file merely because a row lists it.

| Profile               | Minimum useful artifacts                                                               | Add when risk warrants                                                         |
| --------------------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| Research spike        | Entry point or issue, questions, evidence/results                                      | Decision record if the result is adopted                                       |
| Proof of concept      | Entry point, requirements/success gates, decisions, work packages, evaluation evidence | Threat, cost, API/data, and operations artifacts                               |
| Product feature       | Brief, implementation issue or work package                                            | Decision record for a meaningful tradeoff; API/data contract for compatibility |
| Infrastructure change | Brief or requirement references, decision, work package, operations update             | Threat, recovery, and cost records                                             |
| Production service    | Entry point, requirements, decisions, delivery, operations                             | Threat, recovery, API/data, cost, SLO, and evidence artifacts                  |
| Operational change    | Operations update and bounded work item                                                | Decision record if policy or architecture changes                              |

A very small, reversible change may live entirely in an issue or pull request if
its scope, acceptance criteria, and decision context are discoverable there.

## Placement and naming

- Substantial initiatives live at `specs/<initiative-slug>/`.
- `specs/<initiative-slug>/README.md` is the entry point.
- Use lower-case kebab-case file names, such as `requirements.md`,
  `decisions.md`, `work-packages.md`, and `evidence.md`.
- One short register may contain several related decisions or work packages.
  Split records into `decisions/ADR-*.md` or `work-packages/WP-*.md` when
  ownership, review cadence, or concurrent editing makes the register awkward.
- Maintainer operations guides remain under `docs/ops/`.
- Repository-wide templates live under `docs/templates/initiative/`.
- Raw or generated historical material may remain near the initiative or under
  `history/`; it must be marked non-normative either way.

## Metadata contract

Initiative Markdown files use simple YAML front matter:

```yaml
---
initiative: example-initiative
artifact: requirements
status: proposed
owner: repository maintainer
authority: [requirements, api-contract]
---
```

`initiative`, `artifact`, `status`, `owner`, and `authority` are required.
Views and historical artifacts use `authority: []`.

Entry-point lifecycle statuses are `proposed`, `active`, `blocked`, `complete`,
`cancelled`, or `superseded`. Individual artifacts may additionally be `draft`,
`accepted`, or `historical`. A superseded or historical artifact is
non-normative and must link to its replacement when one exists.

## Initiative entry point

Every substantial initiative has one obvious entry point. It contains only:

- purpose;
- lifecycle status;
- owner;
- reading order;
- artifact inventory;
- authority and ownership matrix;
- active open questions; and
- current delivery position.

The entry point is a view. It links to the owners of knowledge rather than
summarizing their detailed content.

## Traceability

Use identifiers where they enable navigation or assignment:

- `REQ-*` for normative requirements;
- `ADR-*` for technical or architectural decisions;
- `WP-*` for independently assignable work packages;
- `OPEN-*` for unresolved questions; and
- `EVID-*` for dated evidence.

Definitions use an H2 heading beginning with the identifier. References use the
identifier and a link when crossing files. Do not identify ordinary explanatory
paragraphs.

Delivery work references requirements and decisions instead of restating them.
Changing product behaviour should therefore touch its requirement owner and
affected references, not technology rationale. Changing technology should touch
its decision owner and affected work, not product behaviour.

## Work-package delivery contract

Every independently assignable work package contains:

- stable ID and title;
- status;
- objective;
- authoritative requirement references;
- applicable decision references;
- dependencies and blockers;
- in-scope and explicit out-of-scope work;
- expected files or outputs;
- acceptance criteria;
- validation commands;
- operational or documentation updates;
- assumptions the assignee may make;
- decisions requiring approval; and
- completion evidence.

The completion-evidence field starts as `Pending` and is replaced with links to
tests, commits, benchmark outputs, or review records when the package closes.
An assignee may implement a package without reopening referenced decisions, but
must stop when an approval-required decision is encountered.

## Split, combine, and retire

Combine artifacts when they share one owner, lifecycle, audience, and review
cadence. A small feature can use a single brief plus an issue.

Split an artifact when:

- two knowledge categories change for different reasons;
- a section needs a different approver or lifecycle;
- independent agents need bounded files to edit concurrently;
- a contract needs versioning independent of the initiative; or
- the document is difficult to navigate without a table of contents.

When work finishes, keep current operational and contract artifacts normative.
Mark plans, interview outputs, superseded decisions, and one-off experiment
notes `historical`; add a replacement link where applicable. Historical
artifacts are retained for provenance and are excluded from authority.

## Agent handoff

A handoff names the initiative entry point and a work-package ID, for example:

> Implement `WP-003` from `specs/mcp-poc/README.md`.

The assignee reads the entry point, the named work package, and its referenced
requirements and decisions. The handoff may add situational context, but it
must not redefine scope or acceptance criteria. If it conflicts with an
authoritative artifact, the artifact wins and the conflict is reported.

## Governance

Run:

```bash
python3 tests/docs/validate_documentation.py
```

The validator checks local links, initiative metadata, authority uniqueness,
identifier definitions and references, unresolved placeholders, Markdown
heading structure, work-package fields, historical authority, and references
to superseded decisions. See
[Documentation Validation](ops/documentation-validation.md) for maintenance and
troubleshooting.

The validator is intentionally small and dependency-free. Human review still
owns clarity, whether an initiative needs a new artifact, whether two statements
are semantically duplicate, and whether evidence justifies a decision.
