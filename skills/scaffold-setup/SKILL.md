---
name: scaffold-setup
description: Initialize Scaffold in a project — create the .scaffold/ truth docs (project, architecture, roadmap, state), the empty knowledge/decisions/investigations folders, and a seed milestone, all with conformant frontmatter. Handles fresh projects and existing codebases (auto-explores to seed architecture from real code). Use whenever the user wants to set up scaffold, initialize it, start using it here, or bootstrap context persistence — even if they only say "set up scaffold" or "init scaffold". For an older scaffold layout, route to /scaffold-cleanup instead.
---

# scaffold-setup

Create the `.scaffold/` structure, conformant from birth. The other skills maintain it.

**Boundary.** Never: author phase plans or a milestone plan beyond the seed (`plan`); write project code (`go`); curate decisions into ADRs (`cleanup` migrates a legacy file; otherwise surface a ruling via `plan`/`checkpoint`, Adam-gated); overwrite an existing scaffold.

**Version guard.** Any doc with `schema_version: 1`, `type: milestone-plan` / `type: phase-brief`, or a milestone folder holding `plan.md` → stop: "Old scaffold format (pre-rename) — run /scaffold-cleanup to migrate first; the current skills will misread it."

---

## Step 1: Preflight

- **Git.** Not initialized → warn, don't block: "No git repo. Scaffold works without it, but git gives you undo for checkpoint. Consider `git init` first."
- **Existing scaffold.** If any truth doc (`project.md`, `architecture.md`, `roadmap.md`, `state.md`) exists, never overwrite:
  - **Fully conformant** — all four present, `decisions/` and `investigations/` folders, a `milestones/` container, no `plans/`, no `plan.md` inside a milestone, no `type: milestone-plan` / `phase-brief`, every doc stamped `schema_version: 2` (the value, not just the key) → stop: "Already set up — run /scaffold-status." No `glossary.md` → add "…and run /scaffold-cleanup — `glossary.md` is missing."
  - **Anything else** → stop: "Found an existing scaffold that isn't fully current. Run /scaffold-cleanup — it inventories whatever's there and migrates any prior or partial state (and no-ops if it turns out current). Setup is for fresh projects only." Don't judge which legacy shape it is.
- A root `CLAUDE.md` is not scaffold's concern. `README.md`, `TODO.md`, `ARCHITECTURE.md`, `NOTES.md`, … are context sources for Step 2.

## Step 2: Scope analysis — existing code only

1. **Detect the stack** from manifests (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `requirements.txt`, `Gemfile`, `pom.xml`, `build.gradle`, `composer.json`, …): frameworks, database, deployment, major deps.
2. **Scan context-bearing files** (`TODO.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, `.cursor/rules`, …). Report each: filename, which scaffold doc it maps to, one-line summary, archived or left in place. A `DECISIONS.md` is not curated here — note it and surface its rulings via `/scaffold-plan`.
3. **Incorporate and archive by default.** Pull content into the right doc. With git: move originals to `.scaffold/archive/`. No git: copy, leave originals, say so. `README.md` always stays in place. Present the scan and proceed; respect any objection to a specific file.

## Step 3: Create the structure

`.gitkeep` in each empty directory:

```
.scaffold/
  project.md   architecture.md   roadmap.md   state.md   glossary.md
  knowledge/   decisions/   investigations/   backlog/
  milestones/01-<slug>/milestone.md
  milestones/01-<slug>/phases/
```

**Seed slug:** default `01-main`; if the user knows the first chunk, ask and use `01-<that>`. The slug is a sticky namespace (rename in Step 5).

**Frontmatter** on every doc: `type` / `schema_version: 2` / `updated: <today>`. Existing project: fill from Step 2 findings after confirmation. New project: placeholder prose as-is.

### project.md

```markdown
---
type: project
schema_version: 2
updated: [today]
---

# [Product]

## What it is
[Plain statement of the product and the problem it solves. Vague is fine early.]

## Who it's for
[The user(s) / audience. "Just me" is a valid answer.]

## Why
[The motivating need.]

## Scope
[What's in scope.]

## Not building
[Explicit non-goals — the anti-drift boundary. What this is NOT.]
```

No checkboxes — a verifiable invariant lives where it is tested.

### architecture.md

```markdown
---
type: architecture
schema_version: 2
updated: [today]
---

# Architecture

## Stack
[Languages, frameworks, key libraries. Empty is fine early.]

## Tenancy / isolation
[Multi-tenant model, if any.]

## Auth
[How users are authenticated/authorized, if applicable.]

## Data access
[Database, ORM, data-access patterns.]

## Deployment
[Where and how it's deployed.]

## Conventions
[Cross-cutting patterns worth stating once: naming, file organization, error handling.]

## Run / env
[How to run the app locally + durable run/env facts.]
```

Tiebreak vs `knowledge/`: a fact that changes on re-platform → here; one that changes only when the business rule changes → `knowledge/`.

### roadmap.md

```markdown
---
type: roadmap
schema_version: 2
updated: [today]
---

# Roadmap

## Milestones
- [active] 01-<slug> — [one line: what this chunk delivers] → milestones/01-<slug>/

## Backlog
- [ ] <slug> — [one line] → backlog/<slug>.md
```

Status token exactly one of `[done] | [active] | [planned]`. Backlog holds work not tied to the active milestone: one `- [ ]` index line each, never ticked, each pointing at its `backlog/<slug>.md` (sections `## What` / `## Trigger` / `## Shape` / `## Not doing`, `type: backlog`, `Unknown.` where not yet known). Program altitude only: a milestone's phases live in its `milestone.md`, never here.

### state.md

```markdown
---
type: state
schema_version: 2
updated: [today]
---

# State

## Active focus
[One paragraph. Synopsis + forward-look. ELI5 — plain words, short sentences, no jargon, no status-report officialese. No bullets, code blocks, or quoted prompts.]

## Next
Milestone `01-<slug>`. [The concrete action when you resume. Names the active milestone and the current phase plan by path once one exists.]

## Blockers
None.

## Open Questions
None.
```

These four headings are the whole document — no `## Notes`. Literal `None.` when empty. A resume precondition rides in `## Next`; a durable run/env fact goes to `architecture.md`; a blocker to `## Blockers`.

### glossary.md

```markdown
---
type: glossary
schema_version: 2
updated: [today]
---

# Glossary

[No terms yet. A word earns a line only when it must mean exactly one thing here. Delete this line when the first term lands.]
```

**Always created, always empty.** Never propose terms, even on a codebase with obvious vocabulary.

### milestones/01-<slug>/milestone.md

Seed with a single Phase 1 — no spec, no pre-written plans:

```markdown
---
type: milestone
schema_version: 2
updated: [today]
---

# Milestone 01 — <slug>

## Objectives
[What this chunk of work delivers. One or two sentences.]

## Phases
- [ ] 01-<slug> — [one line: what this phase does]

## Done-contract
[The acceptance condition(s) for the milestone, evaluated as a set.]
```

`## Deferred` is omitted while empty; `plan`/`checkpoint` add it. No `spec/`, no `phases/*.md` yet.

## Step 4: Existing-codebase deep analysis — automatic

After creating the files, launch an **Explore** subagent ("very thorough") to map structure and entry points, architectural patterns (routing, state, data flow, API layer), conventions (naming, organization, test location), and undocumented dependencies (build tools, CI assumptions, env requirements). Feed back:

- stack, patterns, conventions, data access → `architecture.md`
- module structure / what-it-is → `project.md` `## What it is`
- known issues or code TODOs → **not `state.md`**. Run the admission bar: an item that needs a decision, is materially out of scope, or is real work that can't ride along safely, and isn't tied to the seed milestone → one `roadmap.md` `## Backlog` index line plus its `backlog/<slug>.md`, Adam-gated. Everything else → dropped.

## Step 5: Renaming the seed milestone

Do it early, before plans accrue:

1. `git mv .scaffold/milestones/01-main .scaffold/milestones/01-<newslug>`
2. Update the line in `roadmap.md`.
3. Update the path in `state.md` `## Next`.
4. Grep `.scaffold/` for `01-main`; fix the rest.

## Step 6: Commit + summary

With git: `git add .scaffold/ && git add -u && git commit -m "init: scaffold"`. Summarize what was set up, what was incorporated and from where, what was archived, and what to fill in or verify — especially the seed slug (rename now if the work has a real name). Then: "Run /scaffold-status to orient, or /scaffold-plan to scope the first milestone."
