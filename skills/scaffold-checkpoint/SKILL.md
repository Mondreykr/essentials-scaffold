---
name: scaffold-checkpoint
description: Close out a work session in a scaffold project — verify what was done, update the .scaffold/ truth and execution docs, run the light structural + coherence sweep, fix what it finds, and commit. Leaves no known-wrong state: every finding is fixed, ruled on and applied, or routed to a section on disk — never just mentioned. Use whenever the user wants to checkpoint, save progress, wrap up or pause a session, record what was done, reconcile or tidy the scaffold docs after hand-edits, or close out a milestone — even if they only say "save", "commit my work", "let's stop here", or "wrap up". Runs the light always-on sweep; for the deep independent review use /scaffold-audit.
---

# scaffold-checkpoint

Close the session cleanly: verify what was actually done, update the `.scaffold/` truth + execution docs, sweep, **repair what you find**, commit.

**The one rule over every step: leave no known-wrong state in the tree.** Anything you can dispose of, dispose of now — you hold the diff, the docs and the human at once, and the next session pays full price to re-derive any of it. Reporting a problem and committing anyway is the one outcome this skill does not permit.

**Precondition.** `project.md`, `architecture.md`, `roadmap.md`, `state.md` exist under `.scaffold/`. If not, stop: "Scaffold files missing or incomplete — run /scaffold-setup first."

**Version guard.** Any doc with `schema_version: 1`, `type: milestone-plan` / `type: phase-brief`, or a milestone folder holding `plan.md` → stop: "Old scaffold format (pre-rename) — run /scaffold-cleanup to migrate first; the current skills will misread it."

**Boundary.** You write `.scaffold/` and commit. You do NOT: build — implement a scope item or add capability (`scaffold-go` builds); rewrite plans or make strategic calls (`scaffold-plan` does — you write the re-plan instruction into `## Next`); write an ADR, glossary entry, `## Deferred` line or knowledge graduation without approval (propose, STOP); write into `milestones/archived/` (a live rule found there is restated in `architecture.md` or `knowledge/`); guess at an outcome (evidence or the user's confirmation, always).

**The repair licence.** Within that, you may repair project code, under one test: **does this need a plan?** Yes → `plan`/`go` work, route it. No → fix it now. That covers the session's residue: a rename, a stale comment, a duplicate line, a `.gitignore` entry, a one-line guard, a leftover debug print, a dead import. No line-count limit. Three edges: never new capability; never a surface this session did not touch (on a sweep-only run there is no session diff, so the licence is void — route instead); every repair re-runs Step 4 verification before Step 8, and a repair after a phase was ticked invalidates the tick until that re-run is green. Every repair is shown in Step 8; a rejected one is reverted before the commit and noted in the ledger.

**Active milestone** is whatever `state.md` `## Next` names. Folder order is a fallback only when Next is silent.

**Frontmatter.** Whenever you write a doc, set `updated:` to today and ensure `type` and `schema_version` are present.

**Nothing to save?** After hand-edits, an `integrate`, or to tidy: skip Steps 1–6, run the sweep (Step 7), then Steps 8–9 for whatever it changed. Nothing found → say so, no empty commit. Detect this case; there is no flag.

---

## Step 1: Assess session state

Read `state.md`, `roadmap.md`, `glossary.md` (if present), the active `milestone.md`, and the phase plan `## Next` names (if any). Then:

- **Full close-out** — the active plan's work is complete, or freeform with no plan. All steps (freeform skips the 5a tick).
- **Mid-session** — a plan is active and incomplete. Step 2.

## Step 2: Mid-session handling

Ask and wait:
> "Incomplete phase work. What would you like to do?
> - **Pause** — save current state, continue next session
> - **Partial save** — record what's done, keep the phase active
> - **Abandon** — done with this phase for now"

- **Pause:** ask "Anything to note for next time? (context, gotchas, where you left off — or 'no')." Fold it into `state.md` Active focus; set Next to the concrete resume action, keeping milestone + plan path and any resume precondition. Skip to Step 7.
- **Partial save:** do NOT tick the phase. Update Active focus; keep milestone + plan in Next. Go to Step 5.
- **Abandon:** do NOT tick the phase. Replace the plan reference in Next with the new direction, concrete enough for a cold session to act on (bare "Run /scaffold-plan" only when there is genuinely no direction yet — say so). Record what was abandoned and why in Active focus. Go to Step 5. A plan `scaffold-go` reported NOT SATISFIABLE is always abandon — skip the question, record the contradiction as the why, and route any obstacle or open call it leaves to `## Blockers` / `## Open Questions` in 5b.

## Step 3: USER task check

*Skip on pause/partial.* For each unchecked `[USER]` item in the plan's `## Scope` and the milestone's `## Phases`, one at a time: present what was expected (Found/Missing for named paths); ask "Did you complete this? What happened?"; route — **Pass** (note for the tick), **Issue** (blocker → `## Blockers`; follow-up → `## Deferred` via 5a's gate, or fix now), **Not done** (leave unticked, the phase cannot be ticked, put what is outstanding into `## Next` or `## Blockers`). Resolve each before the next.

## Step 4: Verify AI work

*Skip if no code changed.* Before writing any doc:
1. Run build/lint/tests if they exist. On failure, do NOT tick the phase; the user picks fix-now or save-as-is, and save-as-is puts the failure in `## Blockers`.
2. A `[x]` or a removed blocker needs evidence produced **in this exchange** — a run you just made, output you just read, the user's confirmation just given. A green result from earlier in the session is not evidence: the code has moved since. "It should work" is not evidence.
3. Tests passing is not evidence the scope was built. If a plan was active and `go` did not run its scope check, **dispatch a fresh read-only subagent** to read `## Scope` against the diff — never answer from memory.
4. If verification is impossible, say so: "Completed X — not yet verified (no tests)."

## Step 5: Update truth + execution docs

Touch only what this session changed.

- **5a `milestone.md`** — tick each phase completed this session: `- [x] NN-slug (YYYY-MM-DD)`. A date, not prose. Then groom `## Deferred` (the section is optional — omit it when empty):
  - **Remove** any item this session shipped (ungated; removed, never ticked).
  - **Dispose of scope-check findings** `go` left you, or Step 4.3 produced: a *missing* item → the phase is not done, don't tick, route the build; an *unasked* leftover → repair under the licence; *built another way than the plan named* → ask (7b route 2), then act.
  - **Add nothing yourself.** A candidate is admitted only if it **needs a decision**, is **materially out of scope**, or is **real work that can't ride along safely**. Clears none → fix it now under the licence or drop it; if the fix is smaller than the line describing it, the line is the more expensive artifact. Survivors go to the user as a short list, each with the gate it clears — "`## Deferred` candidates: 1. <item> (needs a decision: …)" — and **only approved ones are written.**
  - A plan that shifted (phases reordered, scope changed) is `scaffold-plan`'s — route. A missing `## Phases` entry for an existing plan file is yours (Step 7 structural 4).
- **5b `state.md` (always)** — rewrite Active focus for this session's outcome; set Next to the concrete next action + milestone and plan path; a resolved Blocker or Open Question is removed and its resolution routed to its home. A resume precondition rides in `## Next`; a durable run/env condition → `architecture.md`.
- **5c `knowledge/*.md`** — only if the build changed a durable **cross-cutting** invariant with no single code home. Point at the enforcing code, don't restate it; a constant stays in code. During a predetermined milestone the spec's `references/` are the rulebook.
- **5d `architecture.md`** — update *how it's built* in place when it changed. Ratify or supersede an ADR in Step 6 → update the statement citing it (`[[NNNN-…]]`) in the same turn. Tiebreak against `knowledge/`: a fact that changes only when the *business rule* changes belongs in `knowledge/`.
- **5e `project.md`** — only if identity or scope boundaries changed; a verifiable invariant routes to where it is tested, never here.
- **5f `roadmap.md`** — a `## Backlog` line only if it clears 5a's admission bar **and** is not tied to the active milestone (tied → `## Deferred`). Remove any `## Backlog` item this session shipped. The `[done]` flip happens at close.

## Step 6: Decisions + milestone close

### 6a. Propose an ADR (gated — present, STOP)

`decisions/` holds rare, architecturally-significant choices — not guardrails or build records. No ADR is created, superseded or pruned without approval. If the session produced one: draft it in full (`**Status:**` + Context / Decision / Why / Alternatives considered / Consequences) as `decisions/NNNN-slug.md` (next 4-digit number), **present it and STOP.** On approval write it and apply 5d's coupling rule. Superseding: flip the prior ADR's `Status:` line to `Superseded by [[NNNN-…]]`, write a new file, never edit the old ruling; fix the `architecture.md` back-reference in the same turn. A research record stays in `investigations/`; only the ruling is proposed.

### 6b. Milestone close

Close only when the done-contract is met: a **predetermined** milestone with `milestone.md` fully ticked, or an **emergent** one where the user explicitly says the chunk is done (all-ticked is its normal steady state, not a signal). Ask "Milestone `NN-slug` — done-contract met. Close it?" On yes, follow `references/milestone-close.md` in full. Reopening a closed milestone is also there; it is the user's call, never yours.

### 6c. Propose a glossary term — collisions only (gated)

**Do not ask about terms.** Stay silent unless the session showed a collision: one concept called more than one thing, or one word carrying two meanings. Then draft the entry (canonical term, a one-or-two-line definition, `**Also called:**` retiring the rivals and where each appears), **present it and STOP.** On approval insert alphabetically into `glossary.md`, stamp `updated:`, delete the setup placeholder if it is the first term. A definition change is gated the same way (show old and new side by side); removal is not. A session that used a term against its entry → flag it and let the user rule.

## Step 7: Structural + coherence sweep (every checkpoint)

Sweep **all living docs**, not just the touched ones.

**Structural** — the deep per-contract grade is `/scaffold-audit`'s; check only the stable shape:
1. Required sections present, named, in order.
2. Frontmatter present and valid (`type` / `schema_version` / `updated`).
3. No Law violations — an append-log in a living-truth doc; a `## Notes` or any catch-all section; a checkbox in `project.md`. Fix on sight (drain a catch-all line by line to each item's home, then delete it). Per-contract detail (date formats, token sets, item shape) → flag for audit; that flag is a complete disposition.
4. **Every plan file is listed** in its `milestone.md` `## Phases`, sorted by `NN-` prefix. Add a missing entry unticked when the phase is plainly unbuilt (no `## Targets`, or targets absent on disk); if its targets look built, ask (route 2) and write the ruled tick state.

**Coherence** — across `project.md`, `architecture.md`, `roadmap.md`, `state.md`, `knowledge/`, the active `milestone.md` + plans, `decisions/`:
1. Every cited ADR exists and is not silently superseded; every architecturally-significant ADR has a current statement in `architecture.md`.
2. **Law 1** — no living-truth doc has grown history; fold current truth back into place.
3. **Law 2** — no work-tracking in truth docs; nothing stranded (run/env → `architecture.md`; deferred work → `## Deferred` / `## Backlog`; an undecided call → `## Open Questions`); no strategy that belongs in an external knowledge base; no project docs in repo `docs/`.
4. **Duplication** — one fact in two living docs → collapse to the owner by the 5d tiebreak.
5. **Plan-vs-decision staleness** — any unexecuted plan premised on a changed or unratified decision, including a finalized one whose `## Targets`/approach now conflicts with a later ADR. Route it (7b route 3); never rewrite the plan. Overlap between two plans is `plan`'s and `audit`'s, not yours.
6. **Cursor sanity** — `## Next` points at a milestone and plan that exist, consistent with the `## Phases` ticks.
7. **Stale dates** — `updated:` over a week old while the content clearly moved.
8. **Grooming nudge** — `## Deferred` or `## Backlog` past ~8 items → flag "at N items; run `/scaffold-audit` for the already-built/stale check, then `/scaffold-plan`", and say if the list is mostly small fixes (an admission failure). Reporting this is exit enough.

### 7b. Dispose of every finding

**A finding that would be LOST gets one of four exits.** Test: *could a later run re-derive this from disk?* A per-contract format detail could (audit re-grades on demand) — reporting it in Step 8 is enough. A finding that exists only because **this** session saw the diff, ran the tests or held the conversation dies with the session — it gets one of these, and you say which in Step 8. In scope: the sweep's findings, what `go`'s scope check left, and anything `/scaffold-audit` produced **in this conversation**.

1. **Fixed** — the default. Mechanical: a broken back-reference, a dated entry folded back into truth, a shipped `## Backlog`/`## Deferred` item removed, a catch-all section drained, a frontmatter field. Also fixed, because the routing rule is published: a fact duplicated or mis-homed between `architecture.md` and `knowledge/` (the 5d tiebreak — that pair only; any other pair is route 2); a requirement checkbox in `project.md` (never delete the content — restate it as plain truth or re-home to `knowledge/`; never into a plan's `## Acceptance` or a done-contract, that is route 3); project-code residue under the licence.
2. **Ruled on, then acted on — this session.** A two-way contradiction the tiebreak cannot pick, or an ADR that looks wrong: put both readings in one short question, get the ruling, apply it now.
3. **Routed to a home on disk.** Undecided call → `## Open Questions`. Real obstacle → `## Blockers`. Work clearing the admission bar → `## Deferred` / `## Backlog` through 5a's gate (run the bar and gate here on a sweep-only run). Work needing authoring (a plan to rewrite or re-finalize) → `## Next` **only if it is the next action**, written concretely ("Re-finalize `<plan path>` with `/scaffold-plan --final` — its `## Targets` predate [[0007-…]]"); otherwise `## Blockers`, one line. **`## Next` holds exactly one action and one cursor** — a second plan path there gives `go` a choice it must not have.
4. **Dropped** — said out loud in Step 8.

If you can neither fix a finding nor name a section that takes it, ask (route 2) — never narrate it and commit.

## Step 8: Review before committing

- Re-read every file you changed.
- `git diff` the full change set, not just `.scaffold/`.
- Show per file what changed, calling out separately: any proposed ADR and the decision on it, any knowledge graduation/retire, and every project-code repair with a one-line justification.
- **Print the disposition ledger** — every finding from Step 3 onward and its exit: fixed / ruled + applied / routed to `<section>` / dropped / re-derivable-and-reported. Keep it as you go.
- Ask "Checkpoint changes ready. Anything to adjust?" Commit only after approval.

## Step 9: Commit

Stage `.scaffold/` plus any repaired project files; `git commit -m "checkpoint: [summary]"` (`reconcile: [summary]` for a sweep-only run). Name repairs in the body. **A repaired file may hold the session's uncommitted feature work** — stage the repair alone (`git add -p`) or commit the file whole and say so in the body. If the commit fails, show the error and stop.

Report *where each live finding landed* on disk (there are no "loose threads for next session"), then name the next move from the resulting state: a paused/partial phase → `/scaffold-status` or `/scaffold-go` to resume; a finished phase → the next plan path, or `/scaffold-plan` to recalibrate; a closed milestone → `/scaffold-plan`; pending USER tasks → complete them and checkpoint again; blockers → resolve them, then `/scaffold-plan`; otherwise → `/scaffold-plan`, start working, or done for now.
