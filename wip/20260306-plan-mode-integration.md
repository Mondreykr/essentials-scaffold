# Plan Mode Integration Design

Design document for integrating Claude Code's native plan mode into the
scaffold workflow, replacing `/scaffold:prep` and `/scaffold:execute` while
keeping all other scaffold commands intact.

## Current Workflow

```
  /scaffold:status
        |
        v
  /scaffold:plan -----> .scaffold/plans/YYYYMMDD-NN-*.md   (contract doc)
        |
        v
  /scaffold:prep        (optional — appends Prep Detail to plan doc)
        |
        v
      /clear
        |
        v
  /scaffold:execute     (reads plan doc, works through tasks sequentially)
        |
        v
  /scaffold:checkpoint  (reads plan doc for deferred items/decisions, updates all state)
```

Key properties:
- Plan doc is the bridge artifact between plan and execute
- `/clear` between plan and execute is intentional (forces self-contained doc)
- Checkpoint reads the plan doc post-execution — never the conversation
- Execute does NOT update scaffold files — checkpoint does

## Proposed Workflow

```
  /scaffold:status
        |
        v
  /scaffold:plan -----> .scaffold/plans/YYYYMMDD-NN-*.md   (contract doc)
        |                       |
        v                       |  (user enters plan mode manually)
      done                      |
                                v
                     Claude plan mode reads contract doc
                     Parallel subagents research codebase
                     Writes its own execution plan file
                                |
                                v
                     User approves plan
                     "Yes, clear context and auto-accept edits"
                                |
                                v
                     Claude executes from its plan file
                     TodoWrite checklist tracks progress
                     Auto-accept edits (pre-approved)
                                |
                                v
                  /scaffold:checkpoint   (unchanged — reads scaffold plan doc)
```

## What Changes

### Retired Commands

| Command             | Replaced By                          |
|---------------------|--------------------------------------|
| `/scaffold:prep`    | Plan mode's parallel subagent research |
| `/scaffold:execute` | Plan mode's post-clear execution     |

### Modified Commands

| Command              | Change                                                |
|----------------------|-------------------------------------------------------|
| `/scaffold:plan`     | Plan doc template gets AI/human task separation        |
| `/scaffold:pause`    | `continue-here.md` notes "native plan mode" context   |
| `/scaffold:resume`   | Routes to "re-enter plan mode" not "run execute"      |
| `/scaffold:setup`    | Command Reference table updated                       |

### Unchanged Commands

| Command                   | Why It's Fine                                        |
|---------------------------|------------------------------------------------------|
| `/scaffold:checkpoint`    | Already designed for post-/clear; reads plan doc     |
| `/scaffold:status`        | Reads state.md — decoupled from execution method     |
| `/scaffold:quick`         | Independent of main plan/execute cycle               |
| `/scaffold:quick-execute` | Independent of main plan/execute cycle               |
| `/scaffold:graduate`      | Archives commands — mechanical update to list only   |
| `/scaffold:cleanup`       | Format migration — unaffected                        |
| `/scaffold:update`        | Pulls latest commands — set changes but logic same   |

## Plan Doc Format Change

The scaffold plan doc needs a clear boundary between what Claude's plan mode
should execute and what is human context / post-execution routing.

### Current Structure

```markdown
## Session Goal
## Context Pointers
## Key Decisions
## Tasks                    <-- mix of AI and human concerns
  ### Task: ...
## Deferred Items           <-- routing info for checkpoint
## Decisions for decisions.md
## Execution Notes          <-- mix of AI instructions and human reminders
## Checkpoint Reminder
## Prep Detail              <-- appended by /scaffold:prep (going away)
```

### Proposed Structure

```markdown
## Session Goal
## Context Pointers
## Key Decisions

## Tasks
  ### Task: ...             <-- AI-executable tasks only
  ### Task: ...

## Execution Constraints    <-- rules for AI during execution
  - Verify each task before marking complete
  - If verification fails: stop, don't auto-fix
  - If task is bigger than expected: stop, re-scope

---

## Post-Execution (do not execute — checkpoint reads this)

### Deferred Items
  | Item | Route | Why deferred |

### Decisions for decisions.md
  [entries]

### Human Actions Required
  - [things the Director must do, e.g. deploy DLL]

### Checkpoint Reminder
  When complete, run /scaffold:checkpoint.
```

The `---` horizontal rule and "do not execute" label create a clear boundary.
Plan mode reads above the line. Checkpoint reads below the line.

## Why This Works (Audit Summary)

### Checkpoint handoff: CLEAN

Checkpoint's "Check for Plan File" step reads `.scaffold/plans/` for deferred
items, decisions, and investigation outputs. The scaffold plan doc is written
by `/scaffold:plan` and never modified by execution. Whether execution happens
via `/scaffold:execute` or Claude's native mode, the plan doc is sitting there
for checkpoint to read.

Checkpoint already handles the post-/clear case: "The conversation may not
contain them" — that's why it reads the plan doc in the first place.

### State.md pointer: CLEAN

`/scaffold:plan` sets state.md's Next Action to point at the plan doc.
Checkpoint clears it. This cycle is the same regardless of execution method.

The phrasing changes from:
> "Run `/scaffold:prep` then `/scaffold:execute`. Plan: `.scaffold/plans/...`"

To:
> "Enter plan mode. Point at `.scaffold/plans/...` for task scope."

### Pause/resume: MINOR FRICTION

If the user pauses mid-native-execution, `continue-here.md` needs to note
that execution was via plan mode so resume routes correctly. Resume would say
"re-enter plan mode for remaining tasks" instead of "run /scaffold:execute."

### Quick tasks: NO IMPACT

Quick tasks are fully independent — own plan/summary lifecycle, don't touch
state.md's Next Action, don't reference the main plan doc.

### Investigation tasks: LIKELY FINE

Claude's plan mode can produce markdown artifacts (investigation docs) — it's
not limited to code changes. The task's `Output to:` field in the plan doc
tells it where to write. Checkpoint verifies the file exists.

## What Plan Mode Gives Us

1. **Parallel subagent research** — Multiple Haiku instances exploring codebase
   simultaneously during planning. Replaces single-threaded prep.

2. **TodoWrite execution tracking** — Live checklist in terminal showing
   progress. Scaffold execute had no equivalent visibility.

3. **Clear context as first-class operation** — Plan file designed to survive
   the clear. Anthropic specifically found this improves plan adherence.

4. **Auto-accept edits** — Permissions pre-approved at plan approval time.
   No pause for confirmation on every file edit during execution.

## Risks

1. **Plan mode ignoring the boundary** — Claude might try to execute items
   below the `---` line. Mitigated by clear labeling + horizontal rule, but
   not guaranteed. Needs testing.

2. **Investigation tasks** — Plan mode is tuned for code changes. Investigation
   tasks that produce markdown docs *should* work but are untested in this flow.

3. **Pause mid-native-execution** — Slightly awkward resume path. Low impact
   since pause is rarely used mid-execution.

4. **Loss of scaffold execute's guardrails** — Scaffold execute had explicit
   "stop if scope creeps" and "suggest checkpoint between tasks" rules. These
   would need to live in the plan doc's Execution Constraints section (which
   plan mode reads) rather than in a command definition.

## Branch Plan

- Branch: `feat/plan-mode-integration` (on essentials-scaffold repo)
- Changes scoped to: `scaffold/` command files
- Testing: copy modified commands to `~/.claude/commands/scaffold/`, test
  against pdm-validation project
- Rollback: revert to master branch commands
