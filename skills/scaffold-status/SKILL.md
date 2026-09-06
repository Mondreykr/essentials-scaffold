---
name: scaffold-status
description: Orient at the start of a scaffold session — read the .scaffold/ truth docs and the active milestone, derive current state from disk, and present where things stand plus what you can do next. Read-only; writes nothing. Use whenever you want a briefing, to resume after a gap, to pick up where you left off, or to see what's active, blocked, or next — even if the user only says "status", "where were we", "what's next", or "catch me up".
---

# scaffold-status

Brief the session: read the living truth, locate the active milestone and phase off
disk, surface open threads and history, and end with options — not directives. State is
**derived from what the docs say**, never from a status keyword.

**Precondition.** The four `.scaffold/` truth docs (`project.md`, `architecture.md`, `roadmap.md`, `state.md`) exist — a scaffold project always has all four. If any is missing, stop: "Scaffold files missing or incomplete — run
/scaffold-setup first (or /scaffold-cleanup if this is an older layout)."

**Version guard.** If any `.scaffold/` doc carries `schema_version: 1`, a `type:
milestone-plan` / `type: phase-brief`, or a milestone folder holds a `plan.md` (the current
name is `milestone.md`), the repo predates the current format — stop: "Old scaffold format
(pre-rename) — run /scaffold-cleanup to migrate first; the current skills will misread it."

**Boundary.** Read-only. Status presents and orients: it writes and mutates nothing, decides nothing, and runs no other skill — it tells you what's available. If everything is early or empty, say so plainly and ask what the user wants to work on.

---

## Step 1: Read the living truth

Read these in order — always-current truth, never a log:

1. `.scaffold/project.md`
2. `.scaffold/architecture.md`
3. `.scaffold/state.md`
4. `.scaffold/roadmap.md`
5. `.scaffold/glossary.md` — read in full; never report, count, or list its terms. Absent or empty is not a finding.

A doc's `type` is its frontmatter `type:` (authoritative); filename/location is only a
fallback. Do **not** read `decisions/` files unless `state.md`, `roadmap.md`, or a plan
points at a specific ADR whose *why* you need. Do **not** read `knowledge/` files in
full — list them (Step 3).

## Step 2: Locate the active milestone + phase

`state.md`'s `## Next` is the single authority for what's active — both the milestone
and the current phase plan. Folder order is NOT the authority.

1. Read `## Next`. It points at the active milestone and phase plan (e.g. `milestones/01-rebuild/phases/09-categories.md`).
   **A `## Next` that resolves inside `milestones/archived/` is never active.** A closed milestone is closed by definition, so briefing it as the live phase — and offering `/scaffold-go` on a plan inside a frozen record — is the specific failure the archive rule exists to prevent. Treat it as a **broken close**: name the path, report that there is no active phase, and route to `/scaffold-checkpoint` to repoint the cursor. Do not follow the folder or infer a live equivalent.
2. Read that milestone's `milestone.md` and the phase plan `## Next` names.
3. **Fallback only if `## Next` is silent or stale:** the highest-`NN` milestone folder is a *hint*, not the authority — a later-numbered milestone can be pre-created while an earlier one still runs. Look only at the direct children of `milestones/`, excluding `archived/`; a recursive read picks closed milestones out of the archive and can rank one above the live work. If you fall back, say so, and flag that `## Next` should be set.

**No git? Say so, don't guess.** The freshness computation below runs `git` commands; in a repo without it there is no sha to check. Report the plan as *final, freshness unverifiable (no git)* rather than erroring or calling it fresh.

Phase done-ness is read from the `milestone.md` checklist — each phase is a checkbox; a
checked box (with a date) means done. No status enum; count checked vs unchecked to see
how far the milestone has progressed.

## Step 3: Surface history filenames (cheap — list, do not read)

- **`knowledge/`** — if it has files, list filenames with a one-line description each.
  These are the durable rulebook for retired milestones. (During an active predetermined
  milestone the spec's `references/` are the live rulebook — `knowledge/` may legitimately
  be empty.)
- **`investigations/`** — if it has files, list the filenames so a resuming session knows
  what research exists. **Do not read them** — listing is enough.
- **`decisions/`** — list `NNNN-slug.md` filenames only if `state.md`, `roadmap.md`, or
  the active plan points at one whose context matters.

Ignore `.gitkeep` placeholders in any directory — they are not content.

## Step 4: Derive signals from disk

State is derived from what the documents say, not from status keywords. Compute:

- **Phase in flight?** The active `milestone.md` has an unchecked phase and `## Next` points at
  its plan.
- **Plan state?** For the active plan, read its `## Targets`: **none → draft** (finalize
  before `go`); present with an `as of <sha>` stamp that still holds → final & fresh
  (ready to `go`); **stamp doesn't hold → stale** (re-finalize). This tells a resuming
  session whether it can execute or must finalize first.

  **The stamp holds** when the sha is an ancestor of HEAD *and* every changed path since
  is either a `## Targets` path entry or under `.scaffold/`. Two cheap git commands:
  `git merge-base --is-ancestor <sha> HEAD`, then `git diff --name-only <sha> --`. The
  question is "did anything move that this plan didn't declare?", **not** "has the repo
  moved?" — a checkpoint commit moves HEAD on every multi-session phase and is not
  staleness. Untracked files don't count.
- **Milestone complete?** Every phase in the active `milestone.md` is checked. For a
  **predetermined** milestone (has `spec/` + pre-written plans) this means it's at its
  done-contract → close + graduate (`/scaffold-checkpoint`) or start a new milestone
  (`/scaffold-plan`). For an **emergent** milestone (no spec), all-phases-checked is the
  *normal* steady state between `plan` calls, **not** a close signal — the next move is
  author the next phase (`/scaffold-plan`); close only if the chunk is genuinely done.
- **What's coming?** From the active `milestone.md`'s `## Phases` (already open — no extra reads), up to three unticked entries by title: any unticked entry sitting *before* the active one first, marked **stranded** (the cursor passed it, so it is the likelier duplicate or stale one), then the rest in list order after the active one. If no active phase resolves, take the first three unticked entries and say the cursor is lost. If Step 2 found no live milestone, skip it.
- **Blocked?** `state.md`'s `## Blockers` has content other than "None."
- **Open questions?** `state.md`'s `## Open Questions` has content other than "None."
- **Deferred work parked?** The active milestone's `milestone.md` has a non-empty `## Deferred` list — **report the count and stop there.** Admission is barred, so the list is short by construction; whether *this* one has grown too long is `checkpoint`'s sweep to judge (it owns that threshold) and `/scaffold-audit`'s to investigate. Reporting the number on the session-entry path is what lets a resuming user see it even if the last session ended without a checkpoint; inventing a second threshold here would just drift from checkpoint's. (A precondition on resuming,
  e.g. "reseed the dev DB first," lives in `## Next` and is surfaced with it — there is no
  `## Notes` section.)

Signals are not mutually exclusive (you can be blocked AND mid-phase) — surface all that
apply. They drive routing in Step 6.

## Step 5: Present the briefing

Keep it short — a briefing, not a report:

1. **Project** — what this is, in one sentence (from `project.md`).
2. **Milestone + phase** — which milestone is active (per `## Next`), which phase plan is
   current **and its state (draft / final & fresh / stale)**, and how many phases in its `milestone.md` are checked vs remaining.
3. **Coming up** — up to three unexecuted phases by title, one line each, stranded ones
   first (skip if the active phase is the only unticked entry, or there is nothing to list).
   Name them only — do not open those plans or adjudicate an overlap; that is `plan`'s
   neighbour check at finalize.
4. **Active focus** — the one-paragraph synopsis from `state.md`.
5. **Open threads** — Blockers and Open Questions (skip if both "None."). Note the active
   milestone's `## Deferred` count if non-empty.
6. **Knowledge** — `knowledge/` filenames + one-liners (Step 3). Skip if empty.
7. **Investigations** — `investigations/` filenames (Step 3). Skip if empty.
8. **Next action** — route per Step 6.
9. **Health check** — flag contradictions across docs:
   - `## Next` points at a phase plan or milestone folder that doesn't exist.
   - `## Next` is silent while a milestone has unchecked phases (active cursor lost).
   - A `milestone.md` phase is checked but `roadmap.md` still shows the milestone planned, or every phase is checked but the roadmap line isn't flipped to done.
   - **A broken close** — a `roadmap.md` `[done]` line pointing at a live `milestones/NN-slug/` path, or an `[active]`/`[planned]` line pointing into `archived/`. One string comparison per milestone line, and it catches a close that was interrupted between the folder move and the roadmap flip.
   - `project.md` scope boundaries contradict what the roadmap/active milestone builds.
   - An `architecture.md` statement references a decision (`decisions/NNNN-…`) that's
     missing.
   - If consistent, say so.

   (Plan-vs-decision staleness is NOT checked here — `status` deliberately doesn't read
   `decisions/` or downstream plans. That detection is `checkpoint`'s coherence sweep and
   `plan`'s pivot sweep.)
10. **Staleness** — report each living-truth doc's `updated:` age in days. Whether an age counts as stale is `checkpoint`'s sweep to decide (it owns that threshold, and it can see whether the content moved); you read no code, so you cannot.

## Step 6: Route to next step

Suggest, don't mandate. Surface multiple options if multiple signals apply.

**Phase in flight** — route on the plan's state:
> - **final & fresh:** "Active: [milestone] / [phase plan] — final & fresh (validated
>   `as of <sha>`; [nothing has moved since / N files moved since, all declared targets or
>   `.scaffold/`]), [N] of [M] phases done. Run `/scaffold-go` to execute it, or
>   `/scaffold-plan` to recalibrate."
> - **draft:** "Active: [milestone] / [phase plan] — still a **draft**. Run
>   `/scaffold-plan --final` to validate it against the current code before `go`, or work
>   freeform."
> - **stale:** "Active: [milestone] / [phase plan] — **stale**: validated `as of <sha>`,
>   and [these moved outside its declared targets: `<file>`, `<file>` / that sha is not in
>   this branch's history]. Re-finalize with `/scaffold-plan --final` before `go`."

**Milestone complete (all phases checked):**
> "[Milestone] is fully checked. If this chunk is genuinely done, run
> `/scaffold-checkpoint` to close it (graduate durable rules to `knowledge/`, flip the
> roadmap line). If it's an emergent milestone still accruing work, run `/scaffold-plan`
> to author the next phase — all-checked isn't a close signal on its own."

**Blocked:**
> "Blocked: [content of Blockers]. If resolved, continue or `/scaffold-plan` to discuss
> direction."

**Active cursor lost (`## Next` silent or dangling):**
> "`state.md ## Next` doesn't point at a live phase. I fell back to [milestone] by folder
> order. Run `/scaffold-plan` to set the active phase."

**Otherwise (early/empty):**
> "Active focus: [synopsis]. Next: [content of Next]. Continue working, or `/scaffold-plan`
> to figure out what's next."

---
