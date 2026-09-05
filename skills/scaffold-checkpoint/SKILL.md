---
name: scaffold-checkpoint
description: Close out a work session in a scaffold project — verify what was done, update the .scaffold/ truth and execution docs, run the light structural + coherence sweep, fix what it finds, and commit. Leaves no known-wrong state: every finding is fixed, ruled on and applied, or routed to a section on disk — never just mentioned. Use whenever the user wants to checkpoint, save progress, wrap up or pause a session, record what was done, reconcile or tidy the scaffold docs after hand-edits, or close out a milestone — even if they only say "save", "commit my work", "let's stop here", or "wrap up". Runs the light always-on sweep; for the deep independent review use /scaffold-audit.
---

# scaffold-checkpoint

Close a work session cleanly: verify what was actually done, update the `.scaffold/` truth + execution docs, run the light structural + coherence sweep, **repair what you find**, and commit.

**Your actual job — hold this over every step below.** You are the only moment in this system where the diff, the docs and the human are present at the same time. After the commit all three disperse: the diff goes to git, the human leaves, and the next session starts cold and pays full price to re-derive what is sitting in front of you for free right now. So your job is **not recording** — recording is the means. Your job is to **leave no known-wrong state in the tree.** The rule that follows: **anything you can dispose of, dispose of now**, because it will never be cheaper. Reporting a problem and committing anyway is the one outcome this skill does not permit.

**Precondition.** The four `.scaffold/` truth docs (`project.md`,
`architecture.md`, `roadmap.md`, `state.md`) exist. If any is missing, stop: "Scaffold
files missing or incomplete — run /scaffold-setup first."

**Version guard.** If any `.scaffold/` doc carries `schema_version: 1`, a `type:
milestone-plan` / `type: phase-brief`, or a milestone folder holds a `plan.md` (the current
name is `milestone.md`), the repo predates the current format — stop: "Old scaffold format
(pre-rename) — run /scaffold-cleanup to migrate first; the current skills will misread it."

**Boundary — the one place this skill states it.** You write `.scaffold/` and commit. You do NOT: **build** — implement a scope item, add capability, or touch a surface this session didn't already touch (`scaffold-go` builds); make strategic decisions or rewrite plans (`scaffold-plan` does — you write the concrete re-plan instruction into `## Next`); write an ADR without approval (propose, present, STOP); graduate or retire knowledge silently (surface the set, wait); write into `milestones/archived/` — a closed milestone is a record and nothing edits it, so a live rule found there is restated in `architecture.md` or `knowledge/`, never amended in place; or guess at an outcome (evidence or the user's confirmation, always).

**The repair licence.** Within that, **you may repair project code**, bounded by exactly one test:

> **Does this need a plan?** If yes it is `plan`/`go` work — route it, don't fix it. If no, fix it now.

That covers the residue of the session whose diff you are already holding: a rename, a stale comment, a duplicate line, a `.gitignore` entry, a one-line guard, a leftover debug print, a dead import. (That is the one example list — everywhere else in this skill points here.) There is **no line-count limit** — the judgment is yours. Three hard edges:

1. A repair is **never new capability.**
2. It **never touches a surface this session did not already touch** — that is unreviewed code you are not scoped to. On a sweep-only run there is no session diff, so the licence is void: a code fix you'd like to make routes instead.
3. **Any repair re-runs verification** (Step 4's build/lint/tests) before Step 8, even when Step 4 was skipped because no code had changed. A repair made after a phase was ticked **invalidates the tick** until that re-run is green — you removed a "dead" import, and the rule that an earlier green result is not evidence applies hardest to your own edits.

Every repair lands in the Step 8 diff Adam approves before the commit — that review is the brake, which is what lets the licence be judgment-based rather than a line count. If he rejects one, revert it in the working tree before committing and say so in the ledger.

**Active milestone.** Resolve it from `state.md`'s `## Next` (the active-cursor
authority) before doing anything else. Folder order ("highest `NN`") is only a fallback
hint when Next is silent.

**Frontmatter.** Every `.scaffold/` doc carries `type` / `schema_version` / `updated`
YAML frontmatter; whenever you write a doc, set `updated:` to today and ensure `type`
and `schema_version` are present.

**Nothing to save?** When there's no session work to record — after hand-edits, after an
`integrate`, or just to tidy a drifted tree — skip Steps 1–6 and run **only** the sweep
(Step 7), then review (Step 8) and commit (Step 9) whatever it changed. If the sweep
finds nothing, say so and do not commit an empty change. There is no flag — detect the no-work case.

---

## Step 1: Assess session state

Read `state.md`, `roadmap.md`, `glossary.md` (if present — 6c needs its current contents), and the active milestone's `milestone.md`
(resolved from `## Next`). If `## Next` references a phase plan, read it for
verification and routing. Determine the checkpoint kind:

- **A. Full close-out** — the active phase plan's work is complete, or it was a
  freeform session with no active plan. Proceed through all steps.
- **B. Mid-session** — a plan is active and its work is incomplete. Go to Step 2.
- **C. No active plan** — freeform session. Skip the phase-checklist tick (5a); update
  truth docs from conversation context, then sweep.

## Step 2: Mid-session handling

*Skip unless case B.* Ask:
> "Incomplete phase work. What would you like to do?
> - **Pause** — save current state, continue next session
> - **Partial save** — record what's done, keep the phase active
> - **Abandon** — done with this phase for now"

Wait for the response.

- **Pause:** ask "Anything to note for next time? (context, gotchas, where you left off
  — or 'no')." Then fold it into `state.md` Active focus (one paragraph) and set Next to
  the concrete resume action preserving the milestone + plan reference. A precondition on
  resuming (e.g. "reseed the dev DB first") rides in `## Next`; a durable run/env condition
  goes to `architecture.md` — there is no `## Notes` section. Skip Steps 3–6; go to Step 7.
- **Partial save:** do NOT tick the phase. Update Active focus to reflect progress;
  preserve milestone + plan in Next. Skip Step 3; go to Step 5.
- **Abandon:** do NOT tick the phase. Clear the plan reference in Next and replace it with the new direction stated concretely — the same standard route 3 sets: a cold session must be able to act on the line. Bare `"Run /scaffold-plan"` is acceptable only when there genuinely is no direction yet, and then say that is why. Update Active focus with what
  was abandoned and why. Go to Step 5.
  This is also the home for a plan `scaffold-go` reported NOT SATISFIABLE (a stated
  contradiction, nothing further built). Don't ask the three-way question in that case —
  the phase can't be resumed as written, so abandon is the only answer; record the
  contradiction as the "why," and clearing Next is what stops a resuming session
  re-deriving it. If the contradiction leaves a real obstacle or an undecided call behind,
  that goes to `## Blockers` or `## Open Questions` in Step 5b as normal.

## Step 3: USER task check

*Skip on pause/partial.* Scan the active plan's `## Scope` and the milestone's `## Phases`
for unchecked human-owned (`[USER]`) items. For each, one at a time: present what was expected; if
criteria name file paths, report Found/Missing; ask "Did you complete this? What
happened?"; then route — **Pass** (note for the tick), **Issue** (ask blocker vs follow-up: a blocker → `## Blockers`; a follow-up → `## Deferred` through 5a's gate, or fixed now — never a transcript note), **Not done** (leave the item unticked, the phase can't be ticked, and put what is outstanding into `## Next` or `## Blockers` so a cold session knows).
**GATE: resolve each USER task before the next.**

## Step 4: Verify AI work

*Skip if no code changed.* Before updating any scaffold doc, verify claims:
1. **Run build/lint/tests** if they exist. On failure, report — do NOT tick a phase complete on failing verification. The user decides fix-now or save-as-is; if it's save-as-is, the failure goes to `## Blockers` with what failed, because a broken build recorded only in the transcript is the exact loss this skill exists to prevent.
2. **Evidence-based updates, and the evidence must be FRESH.** A `[x]`, or removing a
   blocker, requires evidence produced **in this exchange** — a run you just made, output
   you just read, behaviour just observed, or the user's confirmation just given. A green
   result from earlier in the session is not evidence: the run was real and the code has
   moved since, and re-running is the only thing that closes that gap. "It should work" is
   not evidence.
3. **Tests passing is not evidence the scope was built** — it is evidence the tests pass.
   A phase can be green and short. If a plan was active, whether its `## Scope` was
   delivered is answered by reading the scope against the diff; that is
   `scaffold-go`'s scope check, and if `go` did not run, **dispatch a fresh read-only
   subagent to do it** rather than answering from this session's memory of the work.
4. **If verification isn't possible**, say so: "Completed X — not yet verified (no
   tests)."

## Step 5: Update truth + execution docs

Route every change by where it belongs — a place for everything; touch only what this
session changed. The shape each doc must keep:

- **5a `milestones/NN-slug/milestone.md`** — tick the phase checklist for any phase completed
  this session: `- [x] NN-slug (YYYY-MM-DD)`. The checkbox + date IS the "done?" signal
  (no status enum). Keep annotations terse — a date, not prose; verbose narrative goes to
  git, never accreting here. **Groom `## Deferred`** (add the section only if something
  actually clears the bar below):

  - **Removal is yours and is ungated** — remove any `## Deferred` item this session
    actually shipped (you have the diff — that's your evidence). Items are removed, never
    ticked `- [x]`.
  - `scaffold-go` disposes of its own scope-check findings; you dispose of what's left. `go` builds a *missing* item and reverts an *unasked* one on the user's nod, then re-runs the check — so when `go` ran, the class that reaches you is **different** (built another way than the plan named), which is a ruling to get (route 2) and then act on. When `go` did NOT run and you dispatched the check yourself (Step 4.3), you hold all three: a *missing* item means the phase isn't done — don't tick it, and route the build; an *unasked* leftover is a code repair under the licence. Either way it gets a disposition (Step 7b) — a scope-check finding is never merely reported.
  - **Addition is a bar, and you do not write it yourself.** This is the section that rots fastest, because at checkpoint time every loose end of the session is in front of you and parking is the cheapest disposition for all of them. It is not the correct one. For each candidate, apply the **admission bar** — it's admitted only if it **needs a decision**, is **materially out of scope**, or is **real work that can't ride along safely**. Clears none → fix it in place now, under the repair licence at the top of this skill (you're already holding the diff, and every item on that licence's example list costs less than the sentence describing it) **or drop it.** *If the fix is smaller than the line describing it, the line is the more expensive artifact.* "I noticed it and don't want to lose it" is not a gate.
  - **Then propose, don't append.** Surviving candidates go to Adam as a short list, each
    with the gate that admits it — "`## Deferred` candidates: 1. <item> (needs a decision:
    …)" — and **only approved ones are written.** Same hard gate as an ADR, same reason.
    Nothing is added silently.

  If a *plan* shifted (phases reordered/scope changed), that's `scaffold-plan`'s job — note
  and route.
- **5b `state.md` (always)** — exactly four sections (Active focus / Next / Blockers /
  Open Questions), no others:
  - **Active focus** — one paragraph, rewritten to reflect this session's outcome.
    Forward-looking, ELI5 (plain words, short sentences); no bullets, code blocks, or
    quoted prompts.
  - **Next** — the concrete next action + the active cursor (milestone + phase plan by
    path).
  - **Blockers** / **Open Questions** — always present; literal `None.` when empty. When
    one resolves, remove the line and route the resolution to its home (a decision, the
    roadmap, a commit, a knowledge doc) — state never accumulates resolved items.
  - **No `## Notes` section** — `state.md` has only the four headings above. Transient
    operational state routes to its real home: a resume precondition → `## Next`; a durable
    run/env condition → `architecture.md`; a blocker → `## Blockers`. If a `## Notes` (or
    any catch-all) section exists from an older tree, drain it this checkpoint — re-home
    each line, then delete the section.
- **5c `knowledge/*.md` (PRIMARY OWNER)** — checkpoint owns the knowledge band: keep it
  coherent, reconcile, and graduate at close (Step 6b). Write here only if the build
  changed how a durable *cross-cutting* invariant works — one with no single code home.
  State it in the contract's form: the invariant + why + a pointer to where the code
  enforces it (and the test/constraint that guards it, if any). Stay brief — point at
  code, don't restate it; a localized value/constant belongs in code, not here. Living
  truth, maintained in place, never a log. During a predetermined milestone the spec's
  `references/` are the living rulebook; emergent milestones accrue rules here directly.
- **5d `architecture.md` (PRIMARY OWNER)** — you see the diff, so you keep technical
  truth current. Update *in place* when *how it's built* changed (tenancy, auth, stack,
  data-access, deployment, conventions, durable run/env). It **indexes the
  architecturally-significant ADRs**: each statement references the `decisions/NNNN-slug`
  that established it (`[[NNNN-…]]`) — the references *are* the index, no separate index
  file. **Coupling rule:** if you ratify/supersede an architectural ADR in Step 6, update
  its referencing statement here in the *same* turn. (Tiebreak: a fact that changes only
  when the *business rule* changes belongs in `knowledge/`, not here.)
- **5e `project.md`** — only if scope/identity evolved. Identity + scope boundaries only
  (including "what we're NOT building"); state durable constraints as plain truth — **no
  checkboxes.** A verifiable invariant routes to where it's tested (a phase plan's
  `## Acceptance`, the milestone done-contract, or a `knowledge/` doc), not here.
- **5f `roadmap.md`** — add a surfaced future-work one-liner to `## Backlog` as a terse
  `- [ ]` **only if it clears the same admission bar as 5a** (needs a decision / materially
  out of scope / can't ride along safely — so `## Backlog` can't be the escape hatch for
  what failed admission to `## Deferred`) **and it's not tied to the active milestone**
  (work tied to the active milestone — its scope/code — goes to `milestone.md`
  `## Deferred`, not here; the test is tied-ness, not altitude). **Remove any `## Backlog` item this session shipped** (removed,
  never ticked `- [x]`). `## Milestones` lines use the fixed tokens `[done] | [active] | [planned]`; the
  status flip to `[done]` happens in Step 6b.

## Step 6: Decisions + milestone close

### 6a. Propose an ADR (Adam-gated — present draft, STOP)

`decisions/` is the curated log of rare, architecturally-significant choices you'd want
the *why* of in a year — not routine guardrails or build-records. **Write-gate (hard):
no ADR is created, superseded, or pruned without Adam's explicit approval; checkpoint
may only propose.** If the session produced a decision that clears the bar:
1. Draft the full ADR — `**Status:**` line + Context / Decision / Why / Alternatives
   considered / Consequences — filename `decisions/NNNN-slug.md` (next sequential,
   zero-padded to 4 digits, distinct from the 2-digit milestone/phase `NN`).
2. **Present the complete draft and STOP.** Write nothing until Adam approves.
3. On approval: write it; if architectural, apply the coupling rule (5d) in the same
   turn.
4. **Supersession:** flip the prior ADR's `Status:` line (`Superseded by [[NNNN-…]]`) and
   write a NEW file — never edit the ruling; update the `architecture.md` back-reference
   in the same turn.

A research record that yielded a ruling stays in `investigations/`; only the ruling is
proposed here.

### 6b. Milestone-close motion

*Only when the active milestone is genuinely done — its done-contract is met.* For a
**predetermined** milestone, a fully-ticked `milestone.md` + met done-contract is the close
signal. For an **emergent** milestone, all-phases-ticked is the normal steady state, NOT
a close signal — close only when Adam explicitly says the chunk is done. When the
condition holds, confirm: "Milestone `NN-slug` — done-contract met. Close it?" On
confirmation:
1. **Graduate durable rules into `knowledge/` — and this is the LAST time the question can
   ever be asked.** Once step 4 moves the folder, nothing reads it for rules again: audit
   does not walk `archived/`, and no skill may edit it. So this is not "lift what you
   notice" — **read the retiring milestone's spec `references/` (and any accrued emergent
   rules) in full and account for EVERY rule in them**, one of three ways: it graduates, it
   has a code home that enforces it (name the file), or it died with the milestone. Write
   each graduating rule in the contract's form: invariant + why + a pointer to where the
   code enforces it. A rule nobody accounts for here is a rule that has just been sealed.
   First triage each candidate: a single-code-home value (constant/enum) → leave it in
   code, graduate nothing; an invariant a single test/constraint could enforce → prefer
   writing that, graduate nothing; only a genuinely homeless cross-cutting invariant
   graduates. **Reconcile against existing knowledge docs** (retire/supersede contradicted
   ones). **Surface the graduation + retire set for Adam's confirmation; don't curate
   silently.** After graduating, tell the user: *"graduated N rules into `knowledge/` — run
   `/scaffold-audit` to verify them against the code."*
2. **Resolve the `## Deferred` list (backstop).** No milestone closes with un-handled
   deferred items: for each, confirm shipped (remove it), promote it (surface for
   `scaffold-plan` to re-home into the next milestone's `milestone.md` `## Deferred` or
   `roadmap.md` `## Backlog`), or drop it with Adam's nod. The list retires with the
   folder — it must not graveyard.
3. **Archive the folder FIRST — move it whole, rename nothing.** Before the roadmap
   flip, not after: a flip that lands without its move leaves a `[done]` line pointing at
   a path that does not exist and a folder that still looks live, and a checkpoint can be
   interrupted between two steps.
   `git mv .scaffold/milestones/NN-slug .scaffold/milestones/archived/NN-slug` (create
   `archived/` if absent). **Verify the destination does not already exist first** — a
   plain `mv` onto an existing directory does not error, it nests (`archived/NN-slug/NN-slug/`);
   `git mv` errors, which is why it is the default. Use plain `mv` only if the repo is not
   under git, and then check first.
   The move IS the marker: every path inside then reads `…/milestones/archived/NN-slug/…`,
   so a grep hit, a listing and a read all carry the word. Nothing is renamed — `NN-slug`
   is the same folder it always was.
   Then stamp **`milestone.md` only**, adding one frontmatter key below `updated:`:
   `archived: YYYY-MM-DD`. The spec and the phase plans move untouched — the path
   already says what they are, and stamping each buys nothing.
   **Everything under `archived/` is now read-only.** It records what was built; it does
   not state what the code does now. A rule still live at close has already graduated to
   `knowledge/` (step 1) or belongs in `architecture.md` — it is never maintained in the
   archive.
4. **Flip the roadmap line** to `[done]` in `roadmap.md`'s `## Milestones`, and repoint
   its path at `milestones/archived/NN-slug/`.
5. **Repoint `state.md`'s `## Next` — it points into the folder you just moved.** Step 5b
   wrote the active cursor as a milestone + phase-plan path, and that path is now inside
   `archived/`. **`## Next` must never resolve inside `archived/`**: it is the authority
   for what is *active*, and a cursor aimed at a closed milestone makes `scaffold-status`
   report it as active and `scaffold-go` execute a phase plan out of the archive. Repoint
   it at the next milestone, or — the normal case at a close — write that no phase is
   active and `/scaffold-plan` is the next move. Do this HERE, not in Step 7: the sweep's
   mechanical repair for a dangling back-reference is to follow the file to its new path,
   which is exactly the wrong answer for this one.
6. **Report the move: name the old path and the new one**, in the close output and again
   in the Step 8 review. Anything outside `.scaffold/` that referenced the old path — a
   project `CLAUDE.md`, a code comment, a README link — has just broken, and scaffold
   neither owns nor sweeps those files. Printing both paths is what lets the one human
   present grep his own repo for them.
7. A pointer'd/external spec is **not cracked open** — only its enduring rules graduate.
   The pointer file moves with the folder and goes read-only; **the external document it
   points at does not** — it lives outside `.scaffold/`, keeps its own lifecycle, and is
   governed by whoever owns it.

**Reopening a closed milestone (Adam's call, never a skill's).** A close can turn out to
have been premature — work resumes on a chunk already marked done. There is a reverse
gear and it is these steps run backwards: `git mv` the folder back to
`.scaffold/milestones/NN-slug/`, delete the `archived:` key from its `milestone.md`, flip
the roadmap line from `[done]` to `[active]` and repoint its path, and set `## Next`.
Offer it whenever the alternative is a duplicate milestone with a copied spec — two specs
for one feature is the drift the archive exists to prevent, not a way around it. **Never
reopen on your own judgment, and never edit in place instead** — an edit inside
`archived/` is invisible to every check the system has.

### 6c. Propose a glossary term — collisions only (Adam-gated)

**Do not ask about terms.** There is no "any glossary entries today?" prompt. This step stays silent unless the session produced a collision.

**The trigger — a collision you observed this session:** the same concept called more than one thing (the schema says `recon_entry`, the UI says "match", the plan says "reconciliation row"), or one word carrying two meanings in different places. The bar's other two gates rarely fire at checkpoint; don't go hunting for them (`contracts/glossary.md` has the full bar).

When a collision showed up:
1. **Draft the entry** — the canonical term, a one-or-two-line definition precise enough that two readers can't take it differently, and an `**Also called:**` line retiring the rivals and naming where each appears.
2. **Present it and STOP.** Nothing is written without Adam's explicit approval — the same hard gate `decisions/` carries.
3. On approval, insert it **alphabetically** into `.scaffold/glossary.md` and stamp `updated:`. If it's the first term, delete the placeholder line `setup` left.

**Editing a definition is gated too** — propose old and new side by side and wait. **Removal is ungated.**

**Flag, don't fix:** if this session used a term in a way that contradicts its entry, say so and let Adam rule — the code may have moved past the definition, or the session may have been wrong.

## Step 7: Structural + coherence sweep (EVERY checkpoint)

Runs on every checkpoint, and is the *whole* job when there's no work to save. Sweep
**all living docs**, not just the touched ones.

Structural (the deep per-rule grade is `/scaffold-audit`'s). Check each living doc is
well-formed at the *stable, Law-level* shape. The detailed per-contract format rules live
in exactly one drift-guarded place — audit's bundled contract copies — so **don't
re-enumerate them here; route them to audit.** Check only:
1. Required sections present, correctly named, and in order (per the shapes in Step 5).
2. Frontmatter present and valid (`type` / `schema_version` / `updated`).
3. No Law violations — an append-log / dated entries in a living-truth doc (Law 1); a
   `## Notes` / any catch-all / open-ended section (the one-home rule); or a checkbox in
   `project.md` (Law 2 — a truth doc never carries work-tracking). Fix these on sight. The
   genuinely driftable per-contract details (e.g. investigation date format, status-token set, `## Backlog`↔`## Deferred` item shape) are audit's deep pass — flag for `/scaffold-audit`, don't grade them here. *That flag is a complete disposition:* audit re-derives these from disk on demand, so nothing is lost by leaving them.

**Coherence** — read across `project.md`, `architecture.md`, `roadmap.md`, `state.md`,
`knowledge/*.md`, the active `milestone.md` + plans, and `decisions/`:
1. **Cross-reference integrity (architecture ↔ decisions)** — every cited ADR exists and
   isn't silently superseded; every architecturally-significant ADR is reflected by a
   current statement. No dangling/stale back-references (the coupling rule, audited).
2. **Law 1** — no living-truth doc has grown an append-log; fold current truth back into
   place, history belongs in git.
3. **Law 2** — no work-tracking in truth docs; no durable truth, deferred work, or to-do
   list stranded where it doesn't belong (durable run/env → `architecture.md`; deferred
   work → `milestone.md` `## Deferred` / `roadmap.md` `## Backlog`; an undecided question →
   `## Open Questions`); no strategy that belongs in cortex; no project docs drifted into
   `docs/`.
4. **Duplication** — the same fact in two living docs; collapse to the single owner per
   the routing tiebreak.
5. **Plan-vs-decision staleness** — any unexecuted plan premised on a changed or
   un-ratified decision, including a *finalized* plan whose `## Targets`/approach now
   conflicts with a later decision (the finalize→execute gap `go`'s freshness check doesn't
   cover). **Route it (7b route 3)** — into `## Next` if the re-finalize is the next action, otherwise `## Blockers`. Do NOT rewrite the plan here.
6. **Active-cursor sanity** — `state.md`'s `## Next` points at a milestone + plan that
   exist; the named phase is consistent with `milestone.md`'s checklist.
7. **Stale dates** — any living doc whose `updated:` is over a week old while its content
   clearly moved.
8. **Deferred/Backlog grooming nudge** *(re-derivable from disk — reporting it is exit enough)* — staleness removal (is an item already built or moot?) needs the code, so it's `audit`'s job, not this sweep's — but a discretionary check nobody's reminded to run isn't a safety net. So the always-on sweep *surfaces the signal*: if the active milestone's `## Deferred` (or `roadmap.md` `## Backlog`) has grown past **~8 items**, or clearly hasn't been groomed in a long while, flag it — "`## Deferred` is at N items; run `/scaffold-audit` to do the deep already-built/stale check, then `/scaffold-plan` to act on the flags." Checkpoint nudges; audit determines. **Read a long list as an admission failure first**: with the bar applied (Step 5a) a list this long shouldn't exist, so the question isn't only "what's stale?" but "what was admitted that should have been fixed in place?" Say that in the flag when the list is mostly small fixes.

### Disposing of what you find (Step 7b — the part that isn't optional)

**A finding that would be LOST gets one of four exits.** That is the whole test, and it is computable: ask *could a later run re-derive this from disk?* A per-contract format detail could — `/scaffold-audit` re-grades the entire tree on demand — so reporting it in Step 8 is exit enough. A finding that exists only because **this** session saw the diff, ran the tests, or held the conversation cannot be re-derived by anything, and dies at the session boundary unless you dispose of it here. Those get one of the four below, and you say which in Step 8.

In scope: the sweep's own findings, plus anything `go`'s scope check left you, plus anything `/scaffold-audit` produced **in this conversation** (audit writes nothing, so a run from an earlier session left no trace you can read — don't claim to dispose of what you cannot see).

1. **Fixed.** The default, and it covers more than the mechanical cases. *Mechanical:* a broken back-reference path, a stray dated entry folded back into truth, a shipped `## Backlog` / `## Deferred` item removed, a leftover `## Notes` section drained and deleted, a missing or refreshable frontmatter field. **Also fixed**, because a published routing rule is not a judgment call and you own the docs involved:
   - a duplicated fact across `architecture.md` and `knowledge/` — collapse to the single owner by the routing tiebreak (a fact that changes only when the *business rule* changes → `knowledge/`; otherwise `architecture.md`). That tiebreak decides *that pair only*: a duplication spanning any other two docs has no published rule, so it is route 2;
   - **content sitting in the wrong truth doc** — re-home it by that same tiebreak;
   - **a requirement checkbox in `project.md`** — the `[ ]` syntax is the anti-pattern but the *content* is a real requirement, so **never delete the content.** You may re-home it to a `knowledge/` doc, or restate it in `project.md` as plain truth if it's a scope boundary — those are yours. You may **not** put it in a phase plan's `## Acceptance` or a milestone done-contract: editing a finalized plan changes what `go` will build with no freshness check to catch it, and authoring a done-contract is `plan`'s. If that is where it belongs, it is route 3.
   - **project-code residue** — under the repair licence at the top of this skill.
2. **Ruled on by Adam, then acted on — in this session.** For a genuine two-way contradiction (two docs assert opposite things and the tiebreak cannot pick) or an ADR that looks wrong: put the two readings in one short question, get the ruling, **and apply it now.** Asking is a step on the way to fixing, never a substitute for it.
3. **Routed to a home on disk.** An undecided call → `## Open Questions`. A real obstacle → `## Blockers`. Work clearing the admission bar → `## Deferred` / `## Backlog` — **through 5a's proposal gate, never appended on your own judgment**, and if this is a sweep-only run where 5a was skipped, run the bar and the gate here before writing a line.

   Work that genuinely needs authoring — a plan needing a real rewrite, a finalized plan whose approach now conflicts with a later decision — is the one case that can reach `## Next`, under a hard constraint: **`## Next` holds exactly one action and one cursor.** It is the section the whole state machine computes from; a second phase-plan path in it makes `scaffold-status` report an ambiguous active phase and gives `scaffold-go` a choice it must not have. So:
   - if the re-plan **is** the next action, `## Next` becomes it, concretely — "Re-finalize `milestones/03-x/phases/04-y.md` with `/scaffold-plan --final` — its `## Targets` predate [[0007-…]]" — phrased so a cold session can act on it without this conversation;
   - if it is **not** the next action (something else is, or a second one already claimed the slot), it goes to `## Blockers` as a named obstacle, one line each.

   You still never rewrite the plan yourself.
4. **Dropped** — stated out loud in Step 8, not silently.

"Run `/scaffold-plan`" spoken into the transcript is not a disposition. The transcript is the exact thing this system exists to stop depending on: a finding whose only record is chat is lost the moment the session ends. If you can neither fix it nor name a section on disk that takes it, that is the signal to ask Adam (route 2) — not to narrate it and commit.

The inline sweep *samples*; for the deep, independent grading — hard conformance over the
whole tree and docs vs. actual code — run `/scaffold-audit`.

## Step 8: Review before committing

- Re-read every file you changed; flag any remaining contradiction.
- `git diff` for the full change set — **not just `.scaffold/`**, since repairs may have landed in project files.
- Show, per file, what changed — and **call out separately**: any proposed ADR (and Adam's decision), any knowledge graduation/retire at close, any doc fixes, and every project-code repair, listed one by one with its one-line justification. This review is the brake on the repair licence: a repair you don't show is a repair that wasn't approved.
- **Print the disposition ledger** — every finding that passed through this checkpoint, wherever it came from (the sweep, `go`'s scope check, an audit run in this conversation, Steps 3–5), and which exit it took: fixed / ruled + applied / routed to `<section>` / dropped / re-derivable-from-disk-and-reported. Any line reading as none of those isn't done — dispose of it before asking for approval. Keep this list **as you go**, from Step 3 onward; reconstructing it from memory at Step 8 is the dependency this skill exists to break.
- Ask: "Checkpoint changes ready. Anything to adjust?" Wait for confirmation; commit only
  after approval.

## Step 9: Commit

If git is initialized: stage `.scaffold/` **plus any project files you repaired**, then `git commit -m "checkpoint: [plan summary]"` (use `reconcile: [summary]` when this was a sweep-only run). When repairs are included, name them in the message body.

**Watch what staging a repaired file actually stages.** `go` never commits, so at checkpoint time the session's feature work is usually uncommitted — and a one-word repair in a file holding 400 uncommitted lines stages all 400 under a `checkpoint:` subject. Either stage the repair alone (`git add -p`), or commit the file whole and **say so in the message body**: a `checkpoint:` commit that silently carries the phase's implementation makes the history unreadable and turns a later revert into a feature deletion.

If the commit fails, show the error and stop.

**There are no "loose threads for next session."** Anything still live was disposed of in Step 7b and is already on disk — so report *where each one landed* (`## Next`, `## Blockers`, `## Open Questions`, `## Deferred`, `## Backlog`), not what it is. Then **route to next** based on the resulting state:
- Phase paused/partial: "Next session `/scaffold-status` picks up, or `/scaffold-go` to
  resume now."
- Phase done, more remain: "Next phase: [plan path]. `/scaffold-status` then
  `/scaffold-go`, or `/scaffold-plan` to recalibrate."
- Milestone closed: "Milestone `NN-slug` done — moved to `.scaffold/milestones/archived/NN-slug/`. Anything outside `.scaffold/` pointing at the old path needs repointing by hand. `/scaffold-plan` for the next."
- USER tasks pending: "Complete your tasks, then checkpoint again." (What's outstanding is already on disk from Step 3 — name where.)
- Blockers present: "Resolve [blocker], then `/scaffold-plan`."
- Otherwise: "Run `/scaffold-plan`, start working, or done for now."
