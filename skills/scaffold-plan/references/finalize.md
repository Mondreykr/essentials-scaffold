# Finalize pass (`--final`)

Turn a draft into an execution-ready **final** plan by validating it against the code as it is now. Run it on the plan `state.md` `## Next` points at, or the one the user names. Steps 1–6 edit the plan in place; `## Targets` and `state.md` are written only at step 7, on confirmation, so an abandoned pass leaves a draft on disk. On a *re*-finalize, delete the existing `## Targets` at step 1. If any step surfaces that the plan rests on an unratified decision, resolve the ADR gate (Phase 3) first.

1. **Research the current code.** Read the files and patterns `## Scope` implies; identify the concrete files, interfaces and dependencies the phase will touch. You still write only the plan.

2. **Tighten `## Scope` / `## Approach`** against what the code actually is; make `## Acceptance` an outcome the user can observe, never "tests pass".

3. **Neighbour check.** List `milestones/NN-slug/phases/` and read `milestone.md` `## Phases`. Siblings are every other plan whose entry is unticked or missing (note a missing entry for `checkpoint` to add). Read each sibling's `## Objective`, `## Scope` and `## Approach` only — no code, no other milestone.

   Per scope item of this plan, one test: **if that sibling executed first, exactly as written, would this item still need doing in full?** Yes → no finding, even when both touch the same file. No, or only partly → a hit, admitted only if you can name the one artifact (file, table, test, document, dataset) both would leave in the same end state. The only other hit is an **unresolved forward pointer**: prose in either plan naming an unexecuted sibling without saying who owns the work. Never a finding: both plans citing the same rule doc; this plan building on a sibling's output; a sequencing preference; a pointer that names an owner. A sibling too vague to answer → put the question to the user at step 6.

   **Every hit resolves by an edit before finalize, surfaced at step 6.** Legal moves: narrow this item to the remainder and say so in `## Approach`; take the whole item here and drop it from a *draft* sibling; drop it here when the sibling leaves it wholly done; or write the owner into this plan's `## Approach` ("`08-splits` item 6 owns adding it; this phase assumes it exists"). A whole hit goes to whichever phase executes first (default: the lower number); after any drop, check the losing plan still stands on its own. Never drop an item a sibling only partly covers (the remainder is then built zero times); never resolve a pointer by deleting it. The seam sentence lands in this plan, so the check has one writer. **A finalized sibling (carrying `## Targets`) is never edited in place** — its stamp would lie about what `go` builds. A hit resolvable only by changing one → hard-stop: this plan stays a draft, name the sibling and item, rerun from step 1 once that sibling is re-finalized.

   Zero hits is normal. If the hits together say the cut is wrong, propose a re-cut at step 6.

4. **Stranger test.** Could a competent builder who has never seen this project execute this plan from the plan alone? Every "no" marks an unwritten rule the plan leans on. Name it in `## Approach`, or point to where it is written; if it lives in `knowledge/` or `decisions/`, the fix is a `## Governed by` entry plus a line in `## Approach` on how it applies — never a pasted copy.

5. **Write `## Governed by`.** List every file in `.scaffold/knowledge/` and `.scaffold/decisions/` with its opening rule line — choose from the listing, never from memory. One test per candidate: **if you built this phase in violation of this document's rule, would the phase be wrong?** Yes → list it, naming the rule (not the topic) in a few words; if you cannot name the rule, it does not belong. A `decisions/` file is a candidate only while `Status:` is `Accepted`: a `Superseded` one is replaced by its successor if that binds; a `Proposed` one that would bind stops finalize until the ADR gate resolves it. Keep the list tight — `go` reads every entry in full.

   Repo-relative paths, one per line, after `## Acceptance`:

   ```markdown
   ## Governed by
   - `.scaffold/knowledge/tenancy.md` — every query filters by `org_id`
   - `.scaffold/decisions/0007-single-writer.md` — one writer per aggregate
   ```

   If nothing binds, write no section and put this fixed line in `## Approach` (the check is a grep):

   > Governed by: none — no `knowledge/` or `decisions/` document constrains this phase.

   Exactly one of the two forms. On a re-finalize, replace the section and delete whichever form no longer applies — a bare heading is malformed.

6. **Confirm in dialogue.** Present the approach in plain terms ("here's how I'll do it: …"), including each neighbour-check resolution and any question it raised — the user does not read the plan or the code. **Wait for confirmation.** This is the approval seam; `go` executes without re-approving.

7. **On confirmation**, apply what the dialogue changed, then write `## Targets` last in the file, after `## Governed by`: one entry per file or interface the phase touches, under the line `_as of <sha>_` from `git rev-parse --short HEAD`. Every file entry is a repo-relative path (a trailing `/` covers everything beneath) — `go`'s freshness check matches changed paths against this list, so a file named only in prose reads as undeclared drift. An interface entry is fine and ignored by that check; if it lives in a file the phase touches, give the file its own entry. **Be complete, not minimal**: a touched file left out stops `go` on resume. Committing the plan or checkpointing mid-phase does not invalidate the stamp. Then set `state.md` Active focus + `## Next` so a resuming session knows the plan is final & fresh.
