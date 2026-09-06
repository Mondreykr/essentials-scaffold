# Plan-set coherence — pass 1, hands-off

**Written:** 2026-09-05 · macOS · branch `master`
**For:** Execute **pass 1 unattended** — author the spec change, propagate it, run the sweep loop until clean, commit to `master`. Every decision is pre-made below; nothing waits on Adam. Passes 2 and 3 are documented at the end and are **not** in scope.

## Where things stand

**The trigger.** In clarifi, `/scaffold-status` then `/scaffold-plan --final` ran on phase 14.8.1. Both skills' reading lists were followed exactly, and the finalize still proposed work that phase 14.8.2 already owned in its own `## Scope`. Two other proposals came close to pre-empting 14.11 and 15. Adam caught all of it from memory. Nothing was stale, nothing had pivoted, the freshness stamp held — the two plans were written on the same day (the 14.8 split, 2026-09-04) with the overlap baked in from the start.

**The diagnosis.** All three of Scaffold's plan defenses are triggered by a change and face outward from it, asking *"what did this just invalidate?"* A defect present at authoring time triggers none of them. The near-miss is `plan`'s pivot sweep: a phase insertion *is* its trigger, but it hunts for plans whose scope now **conflicts** — and conflict is loud (two plans can't both be right) while this was **duplication**, which is silent (both plans are correct; you just build it twice). Underneath: Scaffold's two Laws govern *placement* of facts and state **no invariant over the relationships between execution documents**.

**The second finding, same disease.** Phase plans carry pasted copies of rules that live in `knowledge/` — clarifi's 14.8.1 has a bullet titled *"Stranger's rules this plan leans on"* restating integer cents, rounding, the trade identity. That paste exists because reading a knowledge doc is a *suggestion* (`plan`'s triage: "any knowledge/ doc relevant to the direction") rather than a guarantee. **Documents inflate because reading is unreliable.**

**Adam's correction that shaped the design:** a plan is paper — it cannot read, only point. Scaffold already learned this once: the phase-plan contract says a file named only in prose is invisible to the freshness check, which is why `## Targets` is a path list. Rule pointers today are prose `[[wikilinks]]` and are equally inert.

## Next

### Pre-made rulings — do not stop to ask

- **R1.** `## Governed by` is **optional in the contract, mandatory at finalize.** The finalize pass produces one or states in `## Approach` why the phase has none. Optional-and-nobody-authors-it is how the idea dies quietly.
- **R2.** It is **not verified** that the pivot sweep actually ran on the 14.8 split (see `## Not verified`). **Build the neighbour check as designed regardless.** If it later emerges the sweep never ran, that is a separate finding about *when* sweeps fire, not a reason to change this work.
- **R3.** The neighbour check's reach is **unexecuted sibling plans in the same milestone**, no wider. Cross-milestone overlap becomes possible only after pass 3 and is out of scope here.
- **R4.** The neighbour check carries its **own admission bar**: report only an overlap that would change what gets built — the same deliverable claimed twice, or an explicit cross-reference already sitting in either plan's prose. Two phases touching one file for different reasons reports nothing. Without this it reports five soft overlaps every run and gets rubber-stamped — Scaffold's own words about its freshness gate: *a gate you pass without reading is not a gate.*
- **R5. Bounded exit.** If a sweep finding is still contested after the round cap, **stop and write it into this file as unresolved.** Do not force a pass. Same pattern as `go`'s unsatisfiable exit — a legitimate terminal result.
- **R6.** Scope is **pass 1 only**. Do not start pass 2 or 3.

### The work

1. **`## Governed by`** — new optional phase-plan section, the twin of `## Targets`. `## Targets` = what the phase *writes*; this = what it must have *read*. A list of `knowledge/` and `decisions/` paths whose rules constrain the phase, each a repo-relative path so it is checkable. Per R1, finalize authors it. `go` reads what it names before executing. State the consequence in the contract: a plan that points reliably stops carrying its own copy of the rules.
2. **The neighbour check at finalize.** Before committing to a scope, read `## Objective` + `## Scope` of every unexecuted sibling plan in the milestone; per scope item, answer *does another plan already claim this?* Every hit **resolves** — this plan owns it, the sibling owns it, or both touch it and the seam is written into `## Approach`. Surfaces at finalize's existing approval seam. Admission bar per R4.
3. **Auto-finalize when next up.** If the plan being authored is the one the cursor will point at, offer to finalize in the same act. Boundary: only that one — siblings stay drafts, because finalizing them stamps against code that will move before they run.
4. **The invariant, into `ARCHITECTURE.md`:** *within a milestone, no two unexecuted phase plans claim the same deliverable; where two genuinely touch the same work, each names the seam.* Place it with the Execution model's staleness bullets — it is the third staleness obligation.
5. **`status`, small:** when reporting the active phase, also name the next two or three unexecuted phases by title. Three lines; `milestone.md` is already open. This is what would have let Adam push back without relying on memory. Rides along here, not its own pass.

### Execution shape — inline first, workflow second

**Step A — author, INLINE and SERIAL. Not a workflow.** Write `ARCHITECTURE.md` and `contracts/phase-plan.md` (and `contracts/roadmap.md` only if item 5 touches it) by hand, in one voice. `CLAUDE.md` here is binding: **the spec is the source and skills are derived from it** — never open a `SKILL.md` first. `ARCHITECTURE.md` is specifically the document that holds the single coherent view no individual skill has; it is the last thing to write by committee.

**Step B — propagate, WORKFLOW, parallel.** One agent per skill file that actually changes — expect `scaffold-plan`, `scaffold-go`, `scaffold-status`, `scaffold-audit`; confirm the set before fanning out. Different files, so no collision and no worktree isolation needed. Each agent gets the finished contract text and edits exactly one file.

**Step C — sweep, WORKFLOW, loop-until-dry.** This is the entire quality gate (see `## Not verified`), so it runs to a rule rather than to a feeling. Repeat until **two consecutive rounds return nothing new**, capped at **four rounds**, then R5. Each round runs three *distinct lenses* in parallel — diversity, not redundancy:
   - **Ambiguity hunter**, refute-first, on the new instruction text only. Prompt it toward *"what does this instruction fail to say?"* rather than *"is it well written"* — **the failure being fixed was an instruction followed correctly and still incomplete.** This is the highest-value lens; weight it accordingly.
   - **Cross-skill consistency** — do all nine skills now say the same thing about `## Governed by`, the neighbour check, and the invariant.
   - **Stranger test on the skills themselves** — could an agent follow the new steps with no knowledge of this conversation.

   Findings are **fixed between rounds, never merely reported** — Scaffold's own disposition rule applied to itself. Keep the whole workflow inside the ~15-agent guideline; if the round cap and the lens count would exceed it, cut rounds before cutting lenses.

**Step D — close.** Run `scripts/sync-contracts.sh` (contracts changed, so the audit skill's verbatim copies must be regenerated), then `scripts/sync-contracts.sh --check` to confirm. Commit to `master` — one commit, named for the pass. No branch, no worktree, no diff review: **the repo is the source, and the skills Adam actually runs live in `~/.claude/skills/` and are untouched until he installs deliberately.** That separation is the safety boundary.

**Before starting:** open permissions enough that the run does not stall on prompts (`/update-config` or `settings.json`). A hands-off session that stops for a permission dialog is not hands-off.

## Not verified

- **That the pivot sweep actually ran when 14.8 was split on 2026-09-04.** Inferred from its trigger condition, never observed. If it never ran, the diagnosis becomes "skill not invoked" rather than "skill hunts for the wrong defect", and the follow-up work is about *when* sweeps fire. Ruled non-blocking by R2. Confirm by finding that session's transcript or asking Adam.
- **Nothing mechanically proves this change works.** Adam ruled against building an acceptance test (2026-09-05): Scaffold has always been developed this way — aggressive verification sweeps and adversarial review, with real use as the later test, and today's failure is that loop working. Recorded so a future reader knows it was a decision rather than an omission. The consequence is that **step C's sweep loop is the only gate**, which is why it is specified as a loop with an exit condition rather than left to judgement.
- **The size findings are clarifi's alone** and may not generalise: phase plans 57.5k words (~60% of its scaffold), the active plan 4.9k (larger than its `architecture.md`), `roadmap.md` 2.2k with backlog items running ~700 words. `architecture.md` at 4k was judged *not* the dumping ground Adam suspected, with one section shaped wrong — `## Working environment — why the machine rules exist`, which is a decision record's job.
- **Whether any scaffold-managed project other than clarifi exists.** Determines the real cost of the pass-3 migration.
- **`contracts/roadmap.md`'s exact backlog wording.** The "one terse line" rule was read in `ARCHITECTURE.md` and `plan/SKILL.md`; the contract file itself was not opened.

## Pointers

- `CLAUDE.md` — the spec-is-source rule that governs step A.
- `ARCHITECTURE.md` — Design Principles, the Two Laws, Execution model (staleness bullets — item 4 lands here), `/scaffold-status` and `/scaffold-plan` entries, State Determination.
- `contracts/phase-plan.md` — where `## Governed by` lands; the prose-vs-path lesson is already written there under `## Targets`.
- `skills/scaffold-plan/SKILL.md` — Phase 1 triage reading list, the Finalize pass, Phase 6 pivot sweep (the near-miss).
- `skills/scaffold-status/SKILL.md` — Steps 1–3; item 5 lands here.
- `skills/scaffold-go/SKILL.md` — must read what `## Governed by` names.
- `skills/scaffold-audit/SKILL.md` + `references/` — grading the new section; `references/` is regenerated by `sync-contracts.sh`, never hand-edited.
- `scripts/sync-contracts.sh` — step D.
- **clarifi, READ-ONLY, as the worked example:** `.scaffold/milestones/01-rebuild/phases/14.8.1-oracle-protocol.md` (line ~35 holds the R8 ruling Adam derived by hand — the answer the neighbour check should reach on its own; `## Approach` holds the "Stranger's rules" paste) and `14.8.2-split-model-provenance.md` item 6. Pre-finalize state at `0dce5a8`, post at `89b5481`. **That repo has live uncommitted work — do not touch it.**

## Suggested skills

- **`workflow-authoring`** — load before writing the step B/C script. Relevant patterns: *loop-until-dry*, *perspective-diverse verify*, *no silent caps* (if the round cap bites, `log()` it — silent truncation reads as "covered everything").
- **`/pressure-test`** on R4's admission bar before building item 2. The named failure mode is a check that reports five soft overlaps every run and gets rubber-stamped.
- **Nothing for step A.** Spec authoring is hand work.

---

## Not in scope — passes 2 and 3

Recorded so the design isn't lost. **Neither is hands-off**: each hits a decision only Adam can make.

**Pass 2 — scouts.** Small read-only agents that *index* rather than read-for-you, dispatched by `plan` at authoring and finalize, feeding the neighbour check and `## Governed by`. Lane, strictly: returns an inventory — path, doc type, its own titles and headings as written on disk, and the objective ground for inclusion. **No summary, no relevance claim, no ranking, no filtering.** Adam's rule: a quote is a magnet — it anchors the orchestrator and is interpretation smuggled in as evidence. Test: *if the report is useful without opening anything, the scout has overstepped.* **It never writes** — `plan` writes `## Governed by`. Ship as a dedicated agent definition, not an inline prompt, so read-only is a property of its tools rather than a sentence it was asked to obey. **Haiku, on principle not price** — the job has the thinking deliberately removed; wanting a bigger model is the alarm that the lane has drifted. Fan out one per corpus with the search space **explicitly named** (small-model recall is fine on a named haystack, poor when it must guess one). **Open decision:** Scaffold has never shipped anything outside `skills/` — install instructions and `/scaffold-update` both change.

**Pass 3 — the backlog body.** Adam's ruling: a new document type, flexibility over minimalism. **Every backlog item gets a file**, not just detailed ones — partial coverage forces every skill to judge which items have files, and that judgement is what a disk-driven system cannot make. `roadmap.md ## Backlog` becomes a pure index, one line per item pointing at its file, fixing its size by construction. Fields: what it is · **the trigger** (what makes this real — clarifi's tax-ACB item has *"trigger is demand, not a date"*, and nothing in Scaffold houses that) · shape (rough scope, known traps) · **not doing** (explicit no-gos). **The failure mode to design against:** if rules end up living here, the dumping ground has moved rather than gone — a backlog file holds *shape*, while durable rules still route to `knowledge/` and real choices to `decisions/`, and the file **points**. **Open decision / blast radius:** new contract, `roadmap.md` contract change, routing in `plan`, grading in `audit`, reading in `status`, and a migration in `/scaffold-cleanup`, because every existing project's roadmap becomes non-conformant on landing.

---

## Pass 1 — executed 2026-09-05 · outcome

**Done:** all five items shipped. Step A authored by hand (`ARCHITECTURE.md`, `contracts/phase-plan.md`); step B propagated by workflow to 6 skills; step C ran the sweep loop; step D synced contracts and committed.

**Step C did NOT reach the clean exit — R5 applies.** Four rounds ran, three lenses each, 82 findings, every one fixed or ruled between rounds. The loop hit the **four-round cap with zero consecutive clean rounds**; the required exit was two. Per-round new findings: 24 → 19 → 22 → 17. **Round 4's 17 findings were fixed but never re-verified**, because the cap fired first.

### Unresolved — carried forward, not forced to a pass

1. **The finding rate never converged.** It did not decay across rounds (24/19/22/17). The loop's premise was that fixes converge; the evidence is that each round's *new text* supplies the next round's findings. A fifth round would have found more. This is the honest state: the change is well-scrutinised, not proven quiet. **Whether the rate is a defect in the change or a property of adversarial review on fresh prose is itself unresolved** — nothing in this run distinguishes them.
2. **Round 4's fixes are unverified by any lens.** They include four spec-vs-skill contradiction repairs (`ARCHITECTURE` vs `go`'s contradiction exit; `status`'s read-set check absent from the spec; `checkpoint`'s one-enforcer roster; `integrate`'s reach). Spot-checked by hand after the run and each reads consistent — a hand check, not a lens.
3. **The docs grew a lot for a change whose thesis is that documents inflate.** `skills/scaffold-plan/SKILL.md` 3 767 → 6 300 words (+67 %), `contracts/phase-plan.md` 1 578 → 2 957 (+87 %), `ARCHITECTURE.md` 8 746 → 10 866 (+24 %). Every addition was findings-driven under the disposition rule, so no line is unjustified individually — but nobody asked whether the *set* is proportionate. **A trimming pass was deliberately not run**: it would be new, unreviewed edits made after the quality gate had closed. Adam's call.
4. **Two items from the original `## Not verified` remain untouched** — whether the pivot sweep actually ran on the 14.8 split (ruled non-blocking by R2), and whether any scaffold-managed project besides clarifi exists.
5. **Nothing mechanically proves the change works.** Unchanged from the pre-ruling: real use is the test.
