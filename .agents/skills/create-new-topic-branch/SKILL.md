---
name: create-new-topic-branch
description: Create a new topic branch for a feature or task. Use when starting work on a new feature, bug, or task that needs its own branch — or when the user says "new branch", "topic branch", "start a feature".
---

Create a new topic branch from `master`.

## Branch name

Use the prefix `ferblape/` followed by a short, kebab-case description of the change (≤30 chars total). Be concrete: name the *thing* you're working on, not the issue number alone.

Examples:
- `ferblape/budget-export-csv`
- `ferblape/people-agenda-sort`
- `ferblape/fix-cms-pagination`

If the user gives a feature name, use it. If not, derive it from the conversation. If there's no clear context, ask.

## Pre-flight checks

Before creating the branch, verify:

- You are on `master` (or the user explicitly wants to branch from somewhere else).
- The working tree is clean — no uncommitted changes, no untracked files that should be committed.
- Master is up to date: `git pull origin master`.

## Create

```bash
git checkout -b ferblape/<short-description>
```

If checks fail, stop and surface the problem. Do not stash or discard work without asking.
