---
name: pr-feedback
description: >
  Full PR feedback workflow: fetch comments, address issues, let the user review, then push.
  Use when the user says "fix PR comments", "address PR feedback", or invokes /pr-feedback.
  Also use when the user just wants to see PR comments without fixing anything.
---

# PR Feedback Workflow

## Step 1 — Fetch all PR comments

Run both commands in parallel to get general and inline review comments:

**General comments (issue-style):**

```bash
gh pr view --comments
```

**Inline / review comments:**

```bash
gh api repos/:owner/:repo/pulls/$(gh pr view --json number -q .number)/comments \
  --jq '.[] | "▸ \(.path):\(.line // .original_line)\n  @\(.user.login) · \(.created_at)\n  \(.body)\n"'
```

`gh` expands `:owner` and `:repo` from the current repository automatically.

## Step 2 — Understand the PR

Before addressing any feedback, review the branch changes to understand context:

- Run `git diff master...HEAD` to see all changes in the PR.
- Read modified files as needed to understand the intent behind each change.

This avoids blind fixes and ensures changes stay consistent with the PR's purpose.

## Step 3 — Summarize and plan

- List every actionable item from the comments (ignore resolved/outdated ones).
- Create a TODO list with one item per issue.
- If the user only asked to **see** the comments, stop here — don't fix anything.

## Step 4 — Address each issue

For **each** issue in the TODO list:

1. Make the code changes.
2. Run RuboCop on modified lines (per `.agents/rules/rubocop.mdc`).
3. Run the relevant Minitest file.
4. Create a **dedicated commit** for the fix:

```bash
git commit -m "$(cat <<'EOF'
<concise description of the fix> (agent)
EOF
)"
```

5. Mark the TODO complete before moving on.

The `(agent)` suffix signals to reviewers that the change was made by an AI agent.

## Step 5 — Pause for user review

After all issues are addressed, **stop and ask the user** before pushing:

> All feedback has been addressed. Want me to push and update the PR?

Do NOT push automatically. Wait for explicit confirmation.

## Step 6 — Push and update PR (only after user confirms)

```bash
git push
```

Then resolve the addressed review threads and request a re-review:

```bash
PR_NUMBER=$(gh pr view --json number -q .number)
OWNER=$(gh repo view --json owner -q .owner.login)
REPO=$(gh repo view --json name -q .name)

gh api graphql -f query='
  query($owner:String!,$repo:String!,$pr:Int!) {
    repository(owner:$owner,name:$repo) {
      pullRequest(number:$pr) {
        reviewThreads(first:100) {
          nodes { id isResolved }
        }
      }
    }
  }' -f owner="$OWNER" -f repo="$REPO" -F pr="$PR_NUMBER" \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | .id' \
  | while read -r THREAD_ID; do
    gh api graphql -f query="mutation { resolveReviewThread(input: {threadId: \"$THREAD_ID\"}) { thread { isResolved } } }"
  done

gh pr edit --add-reviewer <reviewer-logins>
```

Replace `<reviewer-logins>` with the logins collected in Step 1 (comma-separated if multiple).
