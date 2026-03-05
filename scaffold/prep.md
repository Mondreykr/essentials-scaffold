---
description: Research tactical detail for planned tasks
---

**Precondition:** Read `.scaffold/state.md`. Check the "Next Action" section for
a plan file pointer. If Next Action has no plan file pointer, or says
"Run /scaffold:plan", stop and say:
"No plan to prep. Run /scaffold:plan first."

---

## Step 1: Load Plan

Read the plan doc referenced in state.md's Next Action section.
Confirm with the user:

> "Plan: [filename]. [N] tasks to prep. Ready to research?"

If the user says no or wants to skip certain tasks, respect that.

---

## Step 2: Scan for Prior Research

Check if `.scaffold/investigations/` exists. If it does, scan filenames for
relevance to the planned tasks. Read any that look relevant — don't re-research
what's already been investigated. Note which investigation files informed which
tasks.

---

## Step 3: Research Each Task

For each task in the plan doc's Tasks section:
- Read the codebase to find exact file paths, function signatures, patterns
- Identify the right approach based on existing code conventions
- Determine concrete verification steps (commands to run, output to expect)
- For `type: investigate` tasks: confirm the output path specified in the plan doc

---

## Step 4: Write Prep Detail

Append a `## Prep Detail` section to the bottom of the plan doc. For each task,
write a matching subsection:

```
## Prep Detail

### [Task title -- matches task title from Tasks section exactly]
- **Key files:** exact paths with line references where relevant
- **Verify by:** concrete commands and expected output
- **Approach:** implementation notes -- what pattern to follow, what to watch out for

### [Task title]
...
```

**Do not modify any content above the Prep Detail section.** Plan's content
is immutable -- prep only appends.

---

## Step 5: Update State

Update `.scaffold/state.md`:
- Replace "Run `/scaffold:prep` then `/scaffold:execute`" with
  "Run `/scaffold:execute`" in Next Action (keep the plan file pointer unchanged)
- Update the `<!-- Last updated -->` date

---

## Step 6: Summary

> "Prep complete. [N] tasks detailed. Run `/clear` then `/scaffold:execute`."

---

## Boundaries

Prep does NOT:
- **Modify tasks** -- task scope and acceptance criteria are plan's domain
- **Add or remove tasks** -- if research reveals scope issues, note them but
  don't change the task list
- **Update roadmap or other scaffold files** -- only the plan doc and state.md
- **Make strategic decisions** -- if research reveals the approach won't work,
  stop and tell the user

If research reveals that a task is significantly more complex than planned,
or that the planned approach won't work: STOP, present findings, suggest
re-running `/scaffold:plan`.
