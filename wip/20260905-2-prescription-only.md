# Prescription only — cut pass 1 back to what is necessary

**Written:** 2026-09-05 · macOS · branch `master` · after `f209c3d`
**For:** Adam's objective, stated after reviewing pass 1: **reduce the size hard — prescription only, only what is necessary.** He does not have a method in mind and is not prescribing one. This file captures the objective, the evidence, and the questions planning has to answer. **It deliberately does not pre-make the design rulings** — that is `/scaffold-plan`'s job from here.

## Where things stand

**What landed.** `f209c3d` shipped the plan-set coherence change: `## Governed by`, the finalize neighbour check, auto-finalize-when-next-up, the plan-set invariant, and `status` naming upcoming phases. The behaviour is right and Adam is not asking to undo it.

**The complaint, quantified.** Five items cost **+547 lines / ~10,100 added words** across nine files. Per file: `ARCHITECTURE.md` +2,601 words, `skills/scaffold-plan` +2,783, `contracts/phase-plan.md` +1,429, `scaffold-audit` +1,122, `scaffold-go` +874, `scaffold-status` +613, `scaffold-checkpoint` +391, `scaffold-integrate` +228, `scaffold-cleanup` +58. `scaffold-plan/SKILL.md` grew 3,767 → 6,300 words (**+67%**), `contracts/phase-plan.md` 1,578 → 2,957 (**+87%**).

**The benchmark that settles whether that is disproportionate.** `## Governed by` is the declared twin of `## Targets`, and `## Targets` is the *more* intricate mechanism — it carries a deterministic freshness gate, git ancestry, a path comparison and three reasoned exemptions. What `## Targets` costs, as shipped before this change:

| | `## Targets` (pre-change) | `## Governed by` + neighbour check (now) |
|---|---|---|
| `scaffold-plan` finalize step(s) | **261 words** | **2,047 words** |
| `contracts/phase-plan.md` prose section | 394 words (whole draft/final state machine) | 455 words (`Governed by` section alone, before its rules and anti-patterns) |

**~8× the skill text for the simpler half of the pair.** That is the number that makes this a defect rather than a preference.

### The diagnosis — the loop that produced it

**Step C's sweep is a text-generating machine with no counter-pressure, and it is still in place.** Four rounds, three lenses, **82 findings, every one fixed between rounds** under the disposition rule *"findings are fixed, never merely reported."* Two of the three lenses (ambiguity hunter, stranger test) hunt for *"what does this instruction fail to say?"* — a question whose only satisfying answer is **more words**. Nothing in the loop was empowered to answer a finding with *"that case needs no rule"*, *"delete this instead"*, or *"this is already covered"*. There was **no deletion lens, no size budget, and no altitude rule** — so every edge case surfaced became its own clause, and (see below) every clause brought its own justification. The finding rate never decayed (24 → 19 → 22 → 17) precisely because each round's new text was the next round's hunting ground.

### Three distinguishable kinds of waste — the reduction probably needs to treat them differently

1. **Triplicated rationale.** The *argument* for a rule is restated in `ARCHITECTURE.md`, in the contract, and again in each skill. Measured: the subtraction test's wording appears in **4 documents**; the "twin of `## Targets`" framing in **4**; "dies quietly" in **3**; "rubber-stamp" in **3**. `CLAUDE.md` already rules that `ARCHITECTURE.md` is *"the single coherent view that no individual skill holds"* — so a skill carrying the argument is arguably already a contract violation, not just verbosity. **A skill ships alone and therefore needs the *instruction* inline; it does not need the *case for* the instruction.**
2. **Enumerated edge cases in place of a rule.** The neighbour check now spells out ~8 branches (whole hit / partial hit / forward-pointer hit / unanswerable sibling / finalized sibling / draft sibling / >3 hits / hard-stop cleanup), each with its own legal moves and its own reason. Most arrived as a sweep finding of the form *"what if X?"*. The alternative — one rule covering the class plus the escape that already exists (*surface it and ask the user*) — was never considered, because no lens was allowed to propose subtraction.
3. **Behaviour that may itself be surplus.** This is the uncomfortable one and it is **not** an editing problem. Some of what was added is *design*, not prose: the >3-hits hard stop, the ownership tiebreaker, the mid-finalize `## Targets` cleanup, `status`'s fourth plan state ("read-set malformed"), `integrate`'s new read-set staleness pass. Each closed a real finding. **Whether each earns its place at all is a scope question, and it is the bigger lever than word-trimming.**

### The trap the reduction must not fall into

**The 82 findings were real, and a naive revert re-opens them.** Round 1 alone caught three blocking defects, including one that made the mandatory half of `## Governed by` enforced by nothing computable, and one where `audit` would have flagged the very seams `plan` was told to write. **The central design problem of this pass is separating text that CLOSES a defect from text that EXPLAINS one** — the first is load-bearing at any size, the second is the waste. Any plan that cannot articulate that test on a per-paragraph basis will either bloat again or silently ship regressions.

## Next

### The objective (Adam's words, binding)

**Reduce size hard. Prescription only. Only what is necessary.** Behaviour that was agreed is not being repudiated — but "necessary" is Adam's word and it explicitly reaches *scope*, not only prose.

### Open questions planning must answer — with the recommendation I would bet on, and why it is still open

- **Q1. Editorial only, or does behaviour get cut too?** *Recommend: both, and treat behaviour as the primary lever.* Trimming prose alone will not get `scaffold-plan` from 6,300 back toward 4,000, because the branch count is what makes it long. **Open** because cutting a branch means re-opening a finding on purpose, and only Adam can accept that trade.
- **Q2. Where does rationale live — one home, or none?** *Recommend: `ARCHITECTURE.md` only, exactly once; skills carry the bare imperative; contracts carry the gradeable rule and nothing else.* This follows from `CLAUDE.md` rather than inventing a new principle. **Open** on one real objection: a skill that states a rule with no reason is a rule an agent will "improve" by ignoring — how much *why* is load-bearing for compliance is an empirical question this repo has never tested.
- **Q3. What is the target, and is it a budget or a yardstick?** *Recommend the yardstick over an invented number:* **a new phase-plan section should cost roughly what its twin `## Targets` costs** — order 300 words in `scaffold-plan`, not 2,047. **Open** whether the neighbour check (a genuinely new *pass*, not a new section) gets its own separate allowance.
- **Q4. Edit down from `f209c3d`, or revert and re-author from the findings list?** *Recommend edit down.* The current text encodes 82 findings' worth of knowledge; re-authoring from scratch discards it and re-runs the risk. **Open** — a from-scratch rewrite against a fixed budget may produce a genuinely tighter result than iterative trimming, which tends to preserve structure.
- **Q5. What stops it regrowing?** *Recommend this be treated as a deliverable of this pass, not an afterthought.* The sweep that caused this is unchanged and will do it again on the next feature. Candidates: a **deletion lens** with equal standing (*"what here says the same thing twice, or states a case that needs no rule?"*), an explicit **size budget** the loop must report against, and an **altitude rule** in the fixer prompt (skills get imperatives, `ARCHITECTURE` gets arguments). **Open** on whether that belongs in this pass or is its own piece of work.

### Hard constraints on any plan that comes out of this

- **Never re-open a closed defect silently.** If a cut re-opens a finding, that is a decision to state out loud, not a side effect.
- **`ARCHITECTURE.md` + `contracts/` remain the source; skills are derived.** Trim the spec first, then propagate — the one-way direction still holds.
- **No catch-all sections**, still and always. A "notes" or "edge cases" bucket is not a legitimate way to shorten a skill.
- **`skills/scaffold-audit/references/` is generated** by `scripts/sync-contracts.sh`. Never hand-edit; re-run and `--check` at the end.
- **A skill must stay self-contained.** It ships alone into a user's repo with no access to this factory — so "delete it, `ARCHITECTURE` says it" is only valid for the *argument*, never for the *instruction*.

## Not verified

- **That the 3-way rationale duplication is actually the bulk of the waste.** It is measured by keyword recurrence across documents, not by classifying every added paragraph. **The split between kind-1 (rationale), kind-2 (enumerated cases) and kind-3 (surplus behaviour) has not been quantified** — doing that classification is probably the first real task, and it decides how much of the objective is reachable by editing alone.
- **That `## Targets` at 261 words is the right yardstick.** It is the closest comparable and it is the declared twin — but it was authored before the sweep loop existed, so it may simply be the *pre-bloat* baseline rather than a validated-correct size. Nobody has asked whether `## Targets` is itself under-specified.
- **Whether any of the round-4 fixes are wrong.** They were applied and never re-examined by a lens (the cap fired first); hand-checked only. A reduction pass will be reading all of this text closely and is the natural place to catch it — but it is not a substitute for the verification that never ran.
- **Whether cutting the enumerated branches degrades the neighbour check in practice.** No mechanical test exists (Adam ruled against building one, 2026-09-05); real use is still the only evidence, and there has been none yet.

## Pointers

- `f209c3d` — the commit under review. `git diff cab8997 f209c3d` is the whole surface.
- `wip/20260905-1-plan-set-coherence.md` — pass 1's own handoff **plus its appended outcome section**, which already records the growth and the un-converged sweep as unresolved. Start there; this file is its successor, not a replacement.
- `wip/artifacts/20260905-pass1-sweep-findings.json` — **all 82 findings with severity, round and disposition.** This is the artifact that makes "does this text close a defect?" answerable per paragraph. Copied out of the ephemeral task output and committed alongside this file.
- `CLAUDE.md` — the spec-is-source rule, and the "single coherent view" clause that Q2 leans on.
- `skills/scaffold-plan/SKILL.md` finalize steps 2–3 — the 2,047 words. The densest target and the best place to prove the method before applying it anywhere else.
- `git show cab8997:skills/scaffold-plan/SKILL.md` — the `## Targets` step at 261 words, for reading side by side.
- `scripts/sync-contracts.sh` — run + `--check` to close.

## Suggested skills

- **`/scaffold-plan`** — this is a scoping conversation before it is an editing job. Q1 and Q3 are decisions, not tasks.
- **`/pressure-test` on Q2** before committing to it. The named failure mode: a skill stripped to bare imperatives that an agent then "improves" by reasoning around, because nothing told it what the rule was protecting. That would trade bloat for silent non-compliance, which is worse.
- **Nothing adversarial on the trimming itself, and this is deliberate** — an adversarial reviewer pointed at prose asks *"what does this fail to say?"*, which is the exact question that produced the bloat. If a review lens is used at all here, it must be inverted before it is aimed at anything.

## Pass 2 — executed 2026-09-05 · outcome

**Done, uncommitted.** Edit-down from `f209c3d` (Q4: edit, not rewrite), spec first then skills, under three rulings made without Adam: **Q2** — rationale lives in `ARCHITECTURE.md` once; contracts carry the gradeable rule plus any verbatim string; skills carry the imperative with at most one clause of *why* where the rule is counter-intuitive. **Q3** — the `## Targets` yardstick: the `## Governed by` step in `scaffold-plan` is now 244 words against `## Targets` at 261; the neighbour check, a whole new pass, is 500. **Q5** — a `## Size discipline` section added to the factory `CLAUDE.md` (altitude rule, escape-before-branch, twin yardstick, deletion lens with equal standing, word counts reported per loop).

**Two structural changes did most of the work without prose.** (1) Finalize order is now research → tighten → neighbour check → stranger test → `## Governed by` → confirm → *then* `## Targets` + `state.md`. Stamping only on confirmation deletes the whole "hard stop must delete `## Targets`" / "abandoned pass" / "re-run the subtraction test after tightening" apparatus: there is never a stamp nobody confirmed. A re-finalize deletes the old stamp at step 1. (2) Enumerated branches (thin sibling, ownership, unanswerable comparison) collapsed to the existing escape — surface it at the confirmation seam and ask.

| file | `cab8997` | `f209c3d` | now | still added |
|---|---|---|---|---|
| `ARCHITECTURE.md` | 8,746 | 10,866 | 10,103 | +1,357 |
| `contracts/phase-plan.md` | 1,578 | 2,957 | 2,275 | +697 |
| `scaffold-plan` | 3,767 | 6,300 | 4,778 | +1,011 |
| `scaffold-go` | 2,851 | 3,623 | 3,183 | +332 |
| `scaffold-status` | 1,741 | 2,204 | 2,034 | +293 |
| `scaffold-audit` | 1,834 | 2,884 | 2,237 | +403 |
| `scaffold-checkpoint` | 5,837 | 6,208 | 5,976 | +139 |
| `scaffold-integrate` | 1,482 | 1,695 | 1,630 | +148 |
| `scaffold-cleanup` | 4,067 | 4,116 | 4,099 | +32 |

**8,950 added words → 4,412 (−51 %).** `ARCHITECTURE.md` keeps the largest share on purpose: it is the one home for the argument.

**Verification — inverted lens only.** One fresh agent checked each of the 82 findings for *closure* (closed / moot / re-opened), forbidden from hunting new findings. Result: 81 closed, 1 re-opened (the whole-hit ownership tiebreaker, which I had cut deliberately in favour of the confirmation seam — restored as one sentence rather than argue it), plus two spec-vs-skill disagreements (audit's derived grade in ARCH lacked "or n-a"; integrate's skill lacked "unexecuted") — both fixed. Per-finding table: `scratchpad/closure-table.md` of this session (ephemeral; not committed). `scripts/sync-contracts.sh --check` passes.

### Q1 — behaviour cuts, ruled by Adam 2026-09-05

Adam ruled on the four candidates: **cut** `status`'s fourth plan state (read-set malformed — `go` refuses the plan at load with the same routing one hop later) and **cut** the >3-hits hard stop (the agent now proposes a re-cut at the confirmation seam when the hits say the cut is wrong; the hit-counting rule went with it). **Keep** audit's pasted-rule signature (the one check that grades the read-set's thesis) and **keep** checkpoint's unlisted-plan check (checkpoint already owns the checklist). Findings deliberately re-opened by the two cuts: `status-calls-a-read-setless-plan-final-and-fresh`, `status-calls-a-plan-go-ready-without-checking-the-read-set`, `status-read-set-check-and-fourth-plan-state-exist-in-no-spec` (moot — the state no longer exists anywhere), `neighbour-more-than-three-hits-halt`, `more-than-three-hits-branch-contradicts-every-hit-resolves`, `neighbour-hit-count-unit-undefined` (moot — no branch to contradict, nothing to count). Final: `status` 1,876 (+135 over `cab8997`), `ARCHITECTURE.md` 10,002 (+1,256), `scaffold-plan` 4,749 (+982). **Total remaining: 4,220 of the 8,950 added words (−53 %).**

### Not verified

- The behaviour has still never run on a real project. Unchanged.
- Whether the compressed imperatives hold up without their rationale in a skill's hands (the Q2 objection). Untested; the size-discipline rule assumes yes.
- `CLAUDE.md` `## Active work` still says "None in flight" while two `wip/` handoffs exist — pre-existing, left alone.
