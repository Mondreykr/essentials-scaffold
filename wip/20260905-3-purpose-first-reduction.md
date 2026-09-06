# Purpose-first reduction — strip every skill to what its job requires

**Written:** 2026-09-05 · macOS · branch `master` · after `a689fe1`
**For:** a repo-wide reduction of all nine `/scaffold-[skill]` skills. Adam's shape, in his words: *"you need to understand the fundamental PURPOSE and then evaluate the content against that and strip accordingly. It's NOT that complicated of a system."* This file plans that pass. It is a planning brief, not a set of edits — the first session on it should challenge the per-skill purpose statements below before cutting anything.

## Where things stand

**Pass 2 (`a689fe1`) proved the method on one feature and exposed the real problem.** The pass-1 text came down 53 % (8,950 → 4,220 added words) with 81 of 82 sweep findings still closed, using an altitude rule (argument in `ARCHITECTURE.md`, gradeable rule in the contract, imperative in the skill) and one structural reorder that made ~600 words of cleanup rules unnecessary. But pass 1 turned out to be 8 % of the skill text. The product is the problem:

| Skill | Words | Lines | ~Tokens loaded per invocation |
|---|---|---|---|
| `scaffold-checkpoint` | 5,976 | 388 | 9,300 |
| `scaffold-plan` | 4,749 | 373 | 7,450 |
| `scaffold-cleanup` | 4,099 | 437 | 6,900 |
| `scaffold-go` | 3,183 | 227 | 4,900 |
| `scaffold-audit` | 2,237 | 165 | 3,600 (+ 7,523 words of bundled contracts, read by its graders) |
| `scaffold-setup` | 1,997 | 295 | 3,400 |
| `scaffold-status` | 1,876 | 167 | 3,000 |
| `scaffold-integrate` | 1,630 | 175 | 2,700 |
| `scaffold-update` | 675 | 72 | 1,200 |
| **Total** | **26,422** | | **~42,000** |

Tokens are estimated as characters ÷ 4 (±15 %). A typical well-built skill is 500–1,500 words. `checkpoint` is 4–12× that, and it runs every session.

**Why it got this big — and why "trim the prose" is the wrong frame.** Every skill was authored by the same loop that bloated pass 1: adversarial lenses asking *"what does this fail to say?"*, every finding fixed with more words, no deletion lens, no budget. Nobody has ever run a subtraction pass over the pre-pass-1 text. Pass 2 found three kinds of waste and there is no reason the older text is different: **rationale restated in the skill** (the argument belongs in `ARCHITECTURE.md`, which `CLAUDE.md` already names as *"the single coherent view that no individual skill holds"*), **enumerated edge cases in place of one rule plus the existing escape** (surface it at the confirmation seam and ask), and **behaviour that is surplus to the skill's job**. The third is the big lever and the one only Adam can rule on.

**The system genuinely is not complicated.** Its own spec says so: *"a deterministic state machine whose data is the document structure itself"* — skills read sections off disk, compute state, write to one home. `ARCHITECTURE.md` → *AI Instruction Strategy* already carries the principle this pass enforces: **"Don't tell Claude what it already knows"** — *if a behavior is already covered by Claude's defaults, by a hook, or by a skill's own body, no scaffold document restates it.* And it names `integrate` as the model — *"a thin skill that holds a clean boundary is worth more than folding its job into an authoring skill … the thinness reads as intentional."* That principle has never been applied to the other eight.

**What `skill-creator` adds, and what it doesn't.** Its guidance is structural, not a word budget: SKILL.md under 500 lines (every scaffold skill already passes — the problem is words per line, not lines); **progressive disclosure** — metadata always in context, SKILL.md body when triggered, `references/` only when a path needs them; imperative form; examples over explanation. The useful import is the third tier: a rare path does not belong in the body. `cleanup`'s six migration playbooks (roadmap split, `plans/` move, v1 rename, `architecture.md` stand-up, decisions curation, archive) run once per old repo and never again — that is `references/` material by skill-creator's own rule, and it is roughly half of `cleanup`. `checkpoint`'s milestone-close motion (6b, ~80 lines) fires once per milestone, not once per session. `skill-creator` is guidance here, not the tool: its eval/benchmark machinery measures triggering and task pass-rate, and nothing in this repo runs a scaffold skill end-to-end mechanically (Adam ruled against building that, 2026-09-05).

## Next

### The method — Adam's shape, made operational

For each skill, in this order:

1. **State the purpose in one sentence**, from `ARCHITECTURE.md` → *Skills* (each skill's **Role** line is the seed). Adam confirms or corrects it before anything is cut. Draft statements, to be challenged:
   - `status` — read the docs, say where things stand, offer the next moves; write nothing.
   - `plan` — persist an agreed direction into its one home; finalize a plan against the code.
   - `go` — execute a final & fresh plan's scope, one item at a time, and nothing else.
   - `checkpoint` — close the session: record what happened in the docs, tick what was done, catch drift, commit.
   - `audit` — grade every live doc against its exact contract and against the code; read-only.
   - `integrate` — place an external doc in its one home and lift operational facts; never author.
   - `setup` — create a conformant `.scaffold/` for a fresh or existing repo.
   - `cleanup` — bring any old layout to the current standard, one confirmed step at a time.
   - `update` — pull the latest skills and remove stale installs.
2. **Classify every paragraph against that sentence** with one question: *if this paragraph were deleted, would the agent do something different in a case that actually occurs?* No → delete. Yes, but the paragraph is the *reason* → move to `ARCHITECTURE.md` (once) and leave the imperative. Yes, but the case is rare → `references/`. Yes, and the case is routine → keep, as an imperative, one clause of *why* only where the rule is counter-intuitive enough that an agent would otherwise reason around it (`CLAUDE.md` → *Size discipline*).
3. **Set the budget from the classification, not in advance.** The kept-routine count *is* the target. If it lands above ~1,500 words for a big skill, that is a signal to look for a structural change (pass 2's reorder pattern) before accepting the number.
4. **Propagate one-way.** Anything moved to `ARCHITECTURE.md` is written there first, then cut from the skill. Contracts are untouched unless a rule is found to live only in a skill.
5. **Verify by closure, never by gap-hunting.** One fresh agent per skill, given the *pre-cut* skill and the *post-cut* skill, answering one question per pre-cut paragraph: *is the behaviour this paragraph prescribed still prescribed, moved, or dropped — and if dropped, was that a listed decision?* It is forbidden from proposing additions. This is the inverted lens pass 2 used; the adversarial *"what does this fail to say?"* lens is what built the bloat and must not be pointed at the result.

### Order

`checkpoint` first — biggest, runs every session, and its Step 7 sweep plus 6b close motion are the likeliest homes of all three waste kinds. If it halves without dropping a routine behaviour, the method is proven; then `cleanup` (progressive disclosure will do most of it), `plan`, `go`, then the small five in one pass.

### Open questions — with the recommendation I'd bet on

- **Q1. Is the purpose sentence the skill's Role line, or does Adam want to re-cut roles?** *Recommend: Role lines as written; this pass strips, it does not redesign.* Open because "not that complicated" may mean Adam sees a skill doing two jobs.
- **Q2. Does `references/` count as a win?** Moving 2,000 words of `cleanup` into `references/` shrinks what loads per invocation but not the artifact. *Recommend: yes — the cost that matters is context at the moment a skill fires, and the words only load on the path that needs them.* Open because it also means the artifact gains files, and Scaffold has never shipped a skill with a `references/` folder besides `audit`.
- **Q3. What happens to `ARCHITECTURE.md`?** It is 10,002 words and does not ship, but every argument stripped from a skill lands there. *Recommend: accept growth there during this pass, and run one deduplication pass over it at the end* — it already restates its own Execution-model bullets inside the per-skill sections.
- **Q4. Which behaviours are surplus?** Cannot be answered before step 2 runs on a skill. It is the question this pass exists to put in front of Adam, one skill at a time, with word counts attached.

### Hard constraints

- **A skill stays self-contained.** It ships alone; "delete it, `ARCHITECTURE.md` says it" is valid for the *argument*, never for the *instruction*.
- **No catch-all sections.** Not in skills, not in `references/`.
- **Every dropped behaviour is a named decision in the outcome section**, never a side effect. Pass 2's outcome section in `wip/20260905-2-prescription-only.md` is the template.
- **`skills/scaffold-audit/references/` is generated** — `scripts/sync-contracts.sh --check` at the end.
- **Spec first, one-way.** Nothing moves into a skill that the spec does not already state.

## Not verified

- **That the three waste kinds hold for the pre-pass-1 text.** Inferred from the same authoring loop having built it; not measured. Step 2 on `checkpoint` is the measurement.
- **That ~1,500 words is the right order for a big skill.** It is skill-creator's implied scale and pass 2's yardstick extrapolated, not derived from any skill's actual routine-behaviour count.
- **Whether bare imperatives hold under real use.** The Q2 objection from pass 2 is still untested: a skill stripped of every *why* may be a skill an agent "improves" by reasoning around. Nothing here tests it; real use is the only evidence and there has been none.
- **Token estimates.** Characters ÷ 4; not measured with a tokenizer.

## Pointers

- `CLAUDE.md` → *Size discipline* — the altitude rule, escape-before-branch, twin yardstick, deletion lens; written in pass 2, applies to this pass.
- `ARCHITECTURE.md` → *AI Instruction Strategy* (line ~677) — *"Don't tell Claude what it already knows"* and the `integrate`-is-the-model paragraph; the principle this pass enforces.
- `ARCHITECTURE.md` → *Skills* (line ~320) — the Role lines, seed of the purpose sentences.
- `wip/20260905-2-prescription-only.md` — pass 2's method, rulings and outcome section; the template for this pass's per-skill outcome.
- `~/.claude/plugins/cache/claude-plugins-official/skill-creator/*/skills/skill-creator/SKILL.md` → *Skill Writing Guide* — progressive disclosure, <500 lines, imperative form.
- `git show cab8997:skills/scaffold-integrate/SKILL.md` — the thinnest skill, the spec's own model of intentional thinness.

## Suggested skills

- **`/skill-creator:skill-creator`** — as guidance only, for the progressive-disclosure split (what moves to `references/`) and the writing patterns. Not for its evals.
- **`/pressure-test` on the per-skill purpose sentences** before any cut — the one place adversarial review belongs, because a wrong purpose sentence makes every downstream deletion wrong.
- **Nothing adversarial on the stripped text.** Verification is the closure agent in step 5. A gap-hunting lens on the result re-runs the loop that built the problem.

## Session 1 — executed 2026-09-06 · `checkpoint` · outcome

**Done, uncommitted.** Purpose sentence used as drafted above (Q1: Role line as written — Adam has not yet confirmed or re-cut it). Every paragraph classified with the step-2 question; nothing needed adding to `ARCHITECTURE.md` — every argument stripped from the skill was already there (the *why it exists* paragraph, the repair licence, the losability test, the milestone lifecycle, the `## Next` authority rule in `contracts/state.md`). Q2 answered yes: the 6b close motion + reopen procedure moved to `skills/scaffold-checkpoint/references/milestone-close.md`, loaded only on a confirmed close.

| | words | ≈ tokens loaded per invocation |
|---|---|---|
| `SKILL.md` before | 5,976 | 9,300 |
| `SKILL.md` after | 2,747 | 4,300 |
| `references/milestone-close.md` (once per milestone) | 519 | 820 |

**−53 % on the body; 131 lines.** Per section: preamble 731 → 420, Step 5 1,004 → 456, Step 7 sweep 712 → 361, 7b disposition 778 → ~430, 6b 936 → ~70 + 519 in the reference, Step 9 277 → 108.

**The waste-kind measurement (was "Not verified" above).** Of the ~3,160 words removed: roughly 500 is rare-path text moved out (6b), roughly 2,500 is rationale and repetition (the disposition principle alone was stated four times; the `## Notes` rule three times; every gate restated in the boundary paragraph and again at its step), and **surplus behaviour is close to zero** — see the drops below. For `checkpoint` the third waste kind is not the lever; the first two are. That likely does not generalize to `plan` and `go`, whose pass-1 branches were the surplus kind.

**Verification — closure agent, inverted lens.** 117 behaviours walked from the pre-cut text: 93 kept, 10 moved (all constraints and verbatim strings intact in the reference), 11 weakened, 3 dropped. Nine of the weakened/dropped were unintended and restored at a cost of ~100 words (the ledger note on a rejected repair, the `## Deferred` proposal string and the section-optional clause, "citations are the index", "pruned" in the ADR gate, old/new side by side for a glossary edit, `/scaffold-plan --final`, the cortex and `docs/` Law-2 checks, the route-to-next branches). Table: `scratchpad/closure-checkpoint.md` of this session (ephemeral). `scripts/sync-contracts.sh --check` passes.

**Dropped, as decisions:**
- The grooming nudge's second trigger, "clearly hasn't been groomed in a long while" — no computable test; the ~8-item threshold stays.
- The verbatim milestone-closed message in Step 9 — the reference's step 6 already requires printing old and new paths and the reason.
- The A/B/C checkpoint-kind enumeration collapsed to two; case C's only behaviour (skip the 5a tick) is stated inline.

**Step 5 shape paraphrase — ruled by Adam 2026-09-06: dropped.** 5b–5f described each doc's required shape (four sections, one paragraph, `None.` when empty, the ADR-citation index, the status tokens). His reading: a vague shape is an FYI that does nothing concrete. The shape is enforced by the file on disk and graded by the Step 7 sweep and audit; the skill now carries routing only (what goes where, the `knowledge/`↔`architecture.md` tiebreak, the admission bar, the coupling rule). Body 2,818 → 2,747 words.

**Not verified.** Whether the bare imperatives hold in a real checkpoint run — unchanged, no real use yet. The purpose sentence itself — Adam has not ruled on Q1.

**Next:** `cleanup` (progressive disclosure: the six one-time migration playbooks → `references/`), then `plan`, `go`, then the small five in one pass. Same method, same closure check. **Adam's Step 5 ruling generalizes:** a paraphrase of a document's shape is an FYI, not an instruction — cut it from every skill that edits an existing doc; the shape is on disk and audit grades it. (`setup` creates docs from nothing and is the exception.)
