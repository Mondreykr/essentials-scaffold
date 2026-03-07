# Plan Mode Integration Design

Design document for integrating Claude Code's native plan mode into the
scaffold workflow, replacing `/scaffold:prep` and `/scaffold:execute` with
`/scaffold:prime` while keeping all other scaffold commands intact.

## Current Workflow (Before)

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

## New Workflow (After)

```
  /scaffold:status
        |
        v
  /scaffold:plan -----> .scaffold/plans/YYYYMMDD-NN-*.md   (contract doc)
        |
        v
      done (optionally /clear for fresh context)
        |
        v
  User enters plan mode (shift-tab)
        |
        v
  /scaffold:prime       (reads plan doc + context files, presents scope)
        |
        v
  Claude plan mode      (parallel subagent research, writes execution plan)
        |
        v
  User approves plan    ("Yes, clear context and auto-accept edits")
        |
        v
  Claude executes       (TodoWrite checklist tracks progress, auto-accept edits)
        |
        v
  /scaffold:checkpoint  (unchanged — reads scaffold plan doc)
```

## Key Design Decisions

### Prime is entered inside plan mode
The user enters plan mode first (shift-tab), then runs `/scaffold:prime`.
Prime does NOT call EnterPlanMode — it assumes plan mode is already active
and checks for it as a precondition.

### Plan command sets state.md routing (not prime)
`/scaffold:plan` sets state.md's Next Action to reference `/scaffold:prime`.
Prime itself is read-only — it loads context and presents scope but does not
modify any scaffold files.

### Fixed preamble on AI Tasks section
The plan doc template includes a fixed preamble in the `## AI Tasks` section:

> These tasks define the scope of work for this session. Research the
> codebase to understand how to implement them. Confirm your approach
> with the user before executing. Do not expand scope beyond these tasks.

This replaces the old `## Execution Notes` section. The preamble travels
with the tasks into plan mode's context, providing guardrails without a
separate section that might be ignored.

### Visible section break between AI and User tasks
The plan doc template uses `## AI Tasks` and `## User Tasks` as separate
top-level sections, with `## User Tasks` omitted entirely when there are
no user tasks. Below a `---` horizontal rule, `## Session Record` contains
deferred items, decisions, and the checkpoint reminder — material that
checkpoint reads post-execution.

### Delete prep.md and execute.md (no stubs)
Both files are deleted outright. No deprecation stubs, no redirects. The
commands simply stop existing. Users who type `/scaffold:prep` or
`/scaffold:execute` will see "command not found" which is clear enough.

## What Changed

### New Commands

| Command | Role |
|---------|------|
| `/scaffold:prime` | Load plan context into Claude's plan mode |

### Deleted Commands

| Command | Replaced By |
|---------|-------------|
| `/scaffold:prep` | Plan mode's parallel subagent research |
| `/scaffold:execute` | Plan mode's post-clear execution |

### Modified Commands

| Command | Change |
|---------|--------|
| `/scaffold:plan` | AI Tasks/User Tasks split, fixed preamble, Session Record section, updated state.md phrasing |
| `/scaffold:setup` | Session Protocol and Command Reference tables updated |
| `/scaffold:pause` | `continue-here.md` template uses `mid-execution`, references prime |
| `/scaffold:resume` | Routes mid-execution to plan mode + prime |
| `/scaffold:status` | Next Action detection references prime instead of execute |
| `/scaffold:quick-execute` | Escape hatch text references prime |

### Unchanged Commands

| Command | Why |
|---------|-----|
| `/scaffold:checkpoint` | Reads plan doc post-execution — decoupled from execution method |
| `/scaffold:verify` | Reads User Tasks section — compatible with new template |
| `/scaffold:quick` | Independent of main plan/execute cycle |
| `/scaffold:quick-execute` | Logic unchanged, only escape hatch text updated |
| `/scaffold:graduate` | Archives commands — mechanical |
| `/scaffold:cleanup` | Format migration — unaffected |
| `/scaffold:update` | Pulls latest commands |

## What Plan Mode Gives Us

1. **Parallel subagent research** — Multiple Haiku instances exploring codebase
   simultaneously during planning. Replaces single-threaded prep.

2. **TodoWrite execution tracking** — Live checklist in terminal showing
   progress. Scaffold execute had no equivalent visibility.

3. **Clear context as first-class operation** — Plan file designed to survive
   the clear. Anthropic specifically found this improves plan adherence.

4. **Auto-accept edits** — Permissions pre-approved at plan approval time.
   No pause for confirmation on every file edit during execution.

## Compatibility Notes

### Checkpoint handoff: CLEAN
Checkpoint reads `## Session Record` > `### Deferred Items` and
`### Decisions for decisions.md` from the plan doc. These sections are
in the new template under the `---` separator. The plan doc is written by
`/scaffold:plan` and never modified by execution.

### Verify compatibility: CLEAN
Verify looks for `[USER]` markers in the plan doc's task sections. The new
`## User Tasks` section with `[USER]` markers is parseable by the same logic.

### State.md pointer: CLEAN
`/scaffold:plan` sets the pointer, checkpoint clears it. Cycle is identical.

### Pause/resume: CLEAN
`continue-here.md` uses `mid-execution` state (not `mid-execute`). Resume
routes to plan mode + prime instead of scaffold execute.
