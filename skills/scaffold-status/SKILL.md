---
name: scaffold-status
description: Orient at the start of a scaffold session — read the .scaffold/ truth docs and the active milestone, derive current state from disk, and present where things stand plus what you can do next. Read-only; writes nothing. Use whenever you want a briefing, to resume after a gap, to pick up where you left off, or to see what's active, blocked, or next — even if the user only says "status", "where were we", "what's next", or "catch me up".
---

# scaffold-status

Brief the session: read the living truth, locate the active milestone and phase off disk, surface open threads, end with options — not directives. State is derived from what the docs say, never from a status keyword.

**Precondition.** `project.md`, `architecture.md`, `roadmap.md`, `state.md` exist under `.scaffold/`. If not, stop: "Scaffold files missing or incomplete — run /scaffold-setup first (or /scaffold-cleanup if this is an older layout)."

**Version guard.** Any doc with `schema_version: 1`, `type: milestone-plan` / `type: phase-brief`, or a milestone folder holding `plan.md` → stop: "Old scaffold format (pre-rename) — run /scaffold-cleanup to migrate first; the current skills will misread it."

**Boundary.** Read-only. Write nothing, decide nothing, run no other skill — say what is available. If everything is early or empty, say so and ask what the user wants to work on.

---

## Step 1: Read the living truth

In order: `project.md`, `architecture.md`, `state.md`, `roadmap.md`, then `glossary.md` in full — never report, count or list its terms; absent or empty is not a finding. A doc's type is its frontmatter `type:`; filename is a fallback. Do not read `decisions/` unless `state.md`, `roadmap.md` or a plan points at a specific ADR whose *why* you need. Do not read `knowledge/` files — list them (Step 3).

## Step 2: Locate the active milestone + phase

`state.md` `## Next` is the single authority for what's active — milestone and phase plan. Folder order is not.

1. Read `## Next` (e.g. `milestones/01-rebuild/phases/09-categories.md`). **A `## Next` resolving inside `milestones/archived/` is never active** — a broken close: name the path, report no active phase, route to `/scaffold-checkpoint` to repoint. Do not follow the folder or infer a live equivalent.
2. Read that `milestone.md` and the phase plan named.
3. **Fallback only if `## Next` is silent or dangling:** the highest-`NN` direct child of `milestones/` (excluding `archived/`, never recursive) is a hint. Say you fell back and flag that `## Next` should be set.

Phase done-ness is the `milestone.md` checklist: a ticked box with a date is done. Count ticked vs unticked.

## Step 3: List history filenames — list, do not read

- `knowledge/` — filenames with a one-line description each (may legitimately be empty during a predetermined milestone, whose spec `references/` are the live rulebook).
- `investigations/` — filenames only.
- `decisions/` — filenames only if `state.md`, `roadmap.md` or the active plan points at one that matters.

Ignore `.gitkeep`.

## Step 4: Derive signals from disk

- **Phase in flight?** The active `milestone.md` has an unticked phase and `## Next` points at its plan.
- **Plan state?** From the active plan's `## Targets`: none → **draft**; present and the stamp holds → **final & fresh**; stamp doesn't hold → **stale**. The stamp holds when `git merge-base --is-ancestor <sha> HEAD` succeeds *and* every path in `git diff --name-only <sha> --` is a `## Targets` path entry or under `.scaffold/` (a path touched only by `checkpoint:`/`reconcile:` commits is not staleness; untracked files don't count). No git → report *final, freshness unverifiable (no git)*.
- **Milestone complete?** Every phase ticked. A **predetermined** milestone (has `spec/`) is at its done-contract → close via `/scaffold-checkpoint` or start a new one via `/scaffold-plan`. An **emergent** one (no spec): all-ticked is the normal steady state between `plan` calls, not a close signal — next is `/scaffold-plan`.
- **What's coming?** From the open `milestone.md` `## Phases`, up to three unticked entries by title: any unticked entry *before* the active one first, marked **stranded**, then the rest in list order. No active phase → the first three unticked, and say the cursor is lost. No live milestone → skip.
- **Blocked?** `## Blockers` ≠ "None." **Open questions?** `## Open Questions` ≠ "None."
- **Deferred work parked?** The active `milestone.md` has a non-empty `## Deferred` — report the count only; the threshold is `checkpoint`'s. A resume precondition lives in `## Next` and is surfaced with it.

Signals are not exclusive — surface all that apply.

## Step 5: Present the briefing

Short — a briefing, not a report:

1. **Project** — one sentence from `project.md`.
2. **Milestone + phase** — active milestone (per `## Next`), current plan **and its state**, phases ticked vs remaining.
3. **Coming up** — up to three unexecuted phases by title, stranded first. Names only — do not open those plans or adjudicate overlap (that is `plan`'s neighbour check). Skip if nothing to list.
4. **Active focus** — the paragraph from `state.md`.
5. **Open threads** — Blockers and Open Questions (skip if both "None."); the `## Deferred` count if non-empty.
6. **Knowledge** — filenames + one-liners. Skip if empty.
7. **Investigations** — filenames. Skip if empty.
8. **Next action** — per Step 6.
9. **Health check** — flag contradictions, or say the docs are consistent:
   - `## Next` points at a plan or milestone folder that doesn't exist.
   - `## Next` is silent while a milestone has unticked phases.
   - A phase is ticked but `roadmap.md` still shows the milestone `[planned]`; or every phase is ticked but the line isn't `[done]`.
   - **A broken close** — a `[done]` line pointing at a live `milestones/NN-slug/`, or an `[active]` / `[planned]` line pointing into `archived/`.
   - `project.md` scope contradicts what the roadmap or active milestone builds.
   - `architecture.md` references a `decisions/NNNN-…` that is missing.

   Plan-vs-decision staleness is not checked here (`checkpoint`'s and `plan`'s sweeps).
10. **Staleness** — each living-truth doc's `updated:` age in days. Whether it counts as stale is `checkpoint`'s call.

## Step 6: Route

Suggest, don't mandate; surface every option that applies.

**Phase in flight**, by plan state:
> - **final & fresh:** "Active: [milestone] / [phase plan] — final & fresh (validated `as of <sha>`; [nothing has moved since / N files moved since, all declared targets or `.scaffold/`]), [N] of [M] phases done. Run `/scaffold-go` to execute it, or `/scaffold-plan` to recalibrate."
> - **draft:** "Active: [milestone] / [phase plan] — still a **draft**. Run `/scaffold-plan --final` to validate it against the current code before `go`, or work freeform."
> - **stale:** "Active: [milestone] / [phase plan] — **stale**: validated `as of <sha>`, and [these moved outside its declared targets: `<file>`, `<file>` / that sha is not in this branch's history]. Re-finalize with `/scaffold-plan --final` before `go`."

**Milestone complete:**
> "[Milestone] is fully checked. If this chunk is genuinely done, run `/scaffold-checkpoint` to close it (graduate durable rules to `knowledge/`, flip the roadmap line). If it's an emergent milestone still accruing work, run `/scaffold-plan` to author the next phase — all-checked isn't a close signal on its own."

**Blocked:** "Blocked: [content of Blockers]. If resolved, continue or `/scaffold-plan` to discuss direction."

**Cursor lost:** "`state.md ## Next` doesn't point at a live phase. I fell back to [milestone] by folder order. Run `/scaffold-plan` to set the active phase."

**Otherwise:** "Active focus: [synopsis]. Next: [content of Next]. Continue working, or `/scaffold-plan` to figure out what's next."
