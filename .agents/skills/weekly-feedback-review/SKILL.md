---
name: weekly-feedback-review
description: >
  Reviews merged PR feedback from the last 7 days and updates agent guidelines (AGENTS.md, .agents/rules/*.mdc)
  when recurring patterns clearly motivate a change. Creates a PR with the changes or opens-and-closes
  a tracking issue if nothing warrants an update. Invoked by the weekly automated workflow; not for ad-hoc use.
---

Your task: review merged PR feedback from the last 7 days and improve the agent guidelines if the evidence supports it.

## Step 1 — Collect PR feedback

Run the bundled script:

```bash
python3 .agents/skills/weekly-feedback-review/scripts/collect_pr_feedback.py
```

If the script prints `NO_PRS`, skip to Step 4b.

Parse the JSON output to understand which PRs had human feedback and what the reviewers said.

## Step 2 — Read the current guidelines

Read all of these files:
- `AGENTS.md`
- `.agents/rules/*.mdc` (all files matching the glob)

## Step 3 — Analyze

Do the PR comments reveal patterns where the guidelines are:

- Missing a rule that would have prevented a recurring mistake?
- Unclear or ambiguous, causing repeated confusion?
- Outdated relative to something that changed?

Only consider changes clearly motivated by the feedback. Ignore one-off issues and anything already covered. Be conservative: if in doubt, don't change.

## Step 4a — If changes are warranted

1. Edit the files directly (`AGENTS.md` and/or `.agents/rules/*.mdc`).
2. Set git identity:
   ```bash
   git config user.name "github-actions[bot]"
   git config user.email "github-actions[bot]@users.noreply.github.com"
   ```
3. Create branch: `guidelines/weekly-review-<YYYY-MM-DD>`.
4. Stage and commit:
   ```bash
   git add AGENTS.md .agents/rules/
   git commit -m "docs: weekly guidelines update from PR feedback (<YYYY-MM-DD>)"
   ```
5. Push: `git push -u origin <branch>`.
6. Open a PR to master with:
   - Title: `[<YYYY-MM-DD>] Guidelines update from PR feedback`
   - Body with:
     - List of PRs reviewed (number, title, author).
     - For each change: the exact comment(s) that motivated it and why it prevents future issues.
     - Footer: `_Review the diffs before merging._`

## Step 4b — If no changes are needed (or no PRs were merged)

Create a GitHub issue to notify the team, then close it immediately:

```bash
gh label create "weekly-review" --color "0075ca" \
  --description "Automated weekly guidelines review" 2>/dev/null || true

NUMBER=$(gh issue create \
  --title "[<YYYY-MM-DD>] Weekly PR review — no guidelines changes" \
  --body "<markdown summary: PRs reviewed, feedback found, why no changes were warranted>" \
  --label "weekly-review")
gh issue close "$NUMBER"
```
