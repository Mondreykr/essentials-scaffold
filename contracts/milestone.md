---
schema_version: 2
---

# Contract — `milestones/NN-slug/milestone.md`

**Purpose.** One milestone's phase plan: the phase checklist (the disk-derivable
"is it done?" signal), the objectives, the done-contract, and the deferred-work list
(ground-level work surfaced inside this milestone but not scheduled into a phase).

**Band.** Execution — temporal; retires in place with its milestone.

**Owner(s).** Seeded by `scaffold-setup`, authored/updated by `scaffold-plan` (incl.
grooming `## Deferred` — promote an item into a phase or leave it), ticked by
`scaffold-checkpoint` (which also *proposes* deferred items surfaced that session — additions
are Adam-gated — and removes ones shipped), built from an old roadmap body by
`scaffold-cleanup`. Read by `scaffold-status`, `scaffold-go`; `## Deferred` reality-checked
by `scaffold-audit` (flags items already built or stale, and items that never cleared the
admission bar).

## Required frontmatter

```yaml
---
type: milestone
schema_version: 2
updated: YYYY-MM-DD
---
```

## Required structure

```markdown
# Milestone NN — <slug>

## Objectives
[What this milestone achieves.]

## Phases
- [ ] NN-slug — one-liner
- [x] NN-slug — one-liner (YYYY-MM-DD)

## Done-contract
[What "this milestone is complete" means.]

## Deferred
[OPTIONAL — omit when empty. Ground-level work surfaced inside this milestone but not
scheduled into a phase: a bug, a cleanup, deferred debt, a review residual, a doc/spec
reconciliation. One line each. **Admission is a bar, not a default** — see Rules: an item
earns a line only by needing a decision, being materially out of scope, or being real work
that can't ride along safely. Anything else is fixed in place or dropped, and additions are
Adam-gated.]
- [ ] <deferred item, one line>
```

## Rules

- The phase checklist is the authority for "phase done?" — a checked box + a date,
  not a status enum.
- Keep completion annotations **terse** (a date, not prose) so the file stays a
  bounded checklist, never an append-log (Law 1). Verbose narrative → git.
- Phase numbers reset per milestone; the slug namespaces them. `NN` admits
  interstitials (`09.1`); migration never renumbers.
- A wholly human-owned phase may carry a `[USER]` tag on its `## Phases` line;
  `scaffold-checkpoint` verifies it with the user before ticking. (Item-level `[USER]`
  deliverables live in the phase plan's `## Scope`.)
- **`## Deferred` admission — the bar. Applied BEFORE the routing test below.** Routing
  answers *which list*; admission answers *whether it gets a line at all*, and it is the
  gate that keeps this section from becoming the dumping ground every to-do list decays
  into. Parking is the exception, never the default disposition for anything inconvenient.
  An item is admitted only if it clears **at least one** gate:
  1. **It needs a decision** — a human call must land before anything can be built.
  2. **It is materially out of scope** — real work this milestone's phases don't cover and
     can't absorb.
  3. **It is real work that can't ride along safely** — the session that surfaced it could
     not make the change safely: it touches code that session isn't testing, it needs a
     coordinated multi-file sweep, or it needs verification that session can't run.

  Clears none → **fix it in place now, or drop it.** The sharp form: *if the fix is smaller
  than the line describing it, the line is the more expensive artifact* — do the fix. A
  rename, a stale comment, a one-character guard, a duplicated line, a `.gitignore` entry:
  fixed, not parked. "I noticed it and didn't want to lose it" is not a gate — git and the
  code are where a noticed-and-fixed thing lives.
- **Additions are Adam-gated.** A skill never appends to `## Deferred` on its own judgment.
  It **proposes** each candidate with the gate that admits it, and Adam approves — the same
  hard gate `decisions/` carries, for the same reason: cheap-to-add, expensive-to-carry.
  *Removal is not gated* — a shipped, done, or dismissed item leaves freely. The friction
  belongs on the way in, not on the way out.
- **`## Deferred` membership — the one computable test.** Applied *after* admission, on
  what survived it. Ask: *is this work tied to the
  active milestone — its scope, its code, or its goal?* **Tied → it belongs here** (it's
  moot or owned elsewhere once this milestone closes): a bug, cleanup, debt, residual, or
  doc/spec-reconciliation task surfaced inside the milestone and not yet scheduled into a
  phase. **Not tied (or no milestone is active) → NOT here** → `roadmap.md` `## Backlog`.
  Scheduled work is a phase plan, not a `## Deferred` line. A spec-reconciliation task
  ("update SPEC §X to match the code") is tied work and lives here; if the milestone's
  spec maintains its own backlog you may route it there instead, but `## Deferred` is
  always a valid, computable home — never leave it homeless.
- **One line each, `- [ ]`, never ticked.** One *terse* line — a pointer, not a summary,
  and never a multi-sentence paragraph on one physical line. Items leave by removal —
  promoted into a phase (by `scaffold-plan`), shipped (by `scaffold-checkpoint`), or
  **dismissed** (Adam's call, any time) — never checked `- [x]`. Detail lives in git / the
  eventual plan, not in the line.
- **Retires with the milestone.** At close, every remaining `## Deferred` item is
  resolved, promoted, or dropped — it never graveyards in a retired milestone. A
  bar-cleared list is short by construction: a long one means the **bar isn't being
  applied**, not merely that grooming is overdue. Read length as a signal about admission,
  and fix it there.

## Anti-patterns

- Per-phase narrative accreting in the file (append-log; Law 1).
- A status enum substituting for the checkbox + date signal.
- Renumbering interstitial phases on migration.
- A program-altitude feature in `## Deferred` (belongs in `roadmap.md` `## Backlog`).
- A multi-line / paragraph `## Deferred` item, or a `- [x]` checked deferred item.
- **A parked item the parking session could have fixed in place** — a rename, a stale
  comment, a one-line guard, a redundant entry. The bar's signature failure: the line costs
  more than the fix.
- **A `## Deferred` line added without Adam's approval** (additions are gated).
- An item restating something already carried by `state.md` `## Next` or a phase plan —
  that's duplication with extra steps; the item is the other doc's, not this list's.
- A `## Deferred` list used as a scratchpad for observations, worries, or "worth thinking
  about" notes. Deferred holds *work*. An undecided question is `state.md`
  `## Open Questions`; an argument or analysis is an `investigations/` doc.
