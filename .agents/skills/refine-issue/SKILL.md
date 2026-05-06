---
name: refine-issue
description: >
  Refine or create a GitHub issue with codebase context, a proposed plan, acceptance criteria,
  and likely files to change. Preserves the original human request verbatim inside a collapsible
  <details> block. Three modes: CI (auto-publish edit when $GITHUB_ACTIONS is set),
  interactive-edit (refine an existing issue with preview+confirm), and interactive-create
  (compose a new issue from a free-form description with preview+confirm).
  Use when the user says "refine issue #N", "research and plan issue", "create an issue for ...",
  or when invoked by an automated refine-issue workflow.
---

Your task: produce a well-researched issue body — either by rewriting an existing issue or by composing a new one — so a human reviewer can decide whether to launch the implementation workflow.

**Language**: write all generated content (title, plan, AC, comments) in **English**, matching the project convention (`@AGENTS.md`). Titles start with a capital letter. The original request inside `<details>` stays in whatever language the user wrote it — never translate it.

## Detect mode

- **CI** — `$GITHUB_ACTIONS` is set; the prompt references an existing issue. Publish directly.
- **Interactive-edit** — `$GITHUB_ACTIONS` unset, prompt references an issue. Preview + confirm before publishing.
- **Interactive-create** — `$GITHUB_ACTIONS` unset, prompt has a free-form description with no `#N`. Compose a new issue.

If input is ambiguous, ask before assuming.

## Step 1 — Read the original request

**Edit modes**:

```bash
gh issue view <N> --json number,title,body,labels,author,url
```

If the body has the marker `<!-- refined-by-ia -->`, the issue was already refined. CI: post a brief comment, remove `to-refine-by-ia` (`|| true`), stop. Interactive-edit: ask the user whether to re-refine.

**Create mode**: take the request from the user's prompt verbatim. No marker check.

Identify the user-facing problem, any constraints or "must include" details, and what's explicitly out of scope.

## Step 2 — Resolve open product questions

Before researching code, check whether the **what** is clear.

**Gaps** — questions with one obviously right answer once asked: who the feature is for, when it triggers, expected behavior in edge cases, scope boundaries.

**Direction choices** — questions with 2–3 legitimate answers and real tradeoffs: e.g. site-admin-only vs exposed to end users, async vs sync, modal vs dedicated page, broadcast vs digest.

If the *what* is obvious, skip this step.

Otherwise:

- **Interactive**: ask the user directly. For gaps, ask the question. For direction choices, present 2–3 options with one-line summary + pros/cons + your recommendation.
- **CI**: pick reasonable defaults aligned with existing product behavior. Document them in an "Open product questions" section. For direction choices, pick the most defensible option (favor consistency with how the platform already handles similar things) and document discarded options under "Alternatives considered" prefixed `Product:`.

## Step 3 — Research the codebase

Find:
- Existing code relevant to the request (models, services, controllers under the right `gobierto_*` module).
- Similar features already implemented — patterns to reuse, not reinvent.
- Tests covering the area.
- Project guidelines that apply (`@AGENTS.md`, `@.agents/rules/`).

Use `Grep`, `Glob`, `Read`. Cite specific `file_path:line` references in the plan.

## Step 4 — Assess technical direction

Are there 2–3 viable approaches with non-trivial tradeoffs (extend existing module vs new module; sync vs background job; reuse pattern vs new abstraction)?

If not obvious:

- **Interactive**: present options with one-line summary + pros/cons + recommendation. Wait for the user.
- **CI**: pick the most defensible option and document discarded ones under "Alternatives considered" prefixed `Technical:`.

## Step 5 — Compose the body and pick a title

Write the body to `/tmp/refined-issue-<N>.md` (or `/tmp/refined-issue-new.md`). Don't pass multi-line markdown via `--body "..."`.

```markdown
<!-- refined-by-ia -->

<details>
<summary>Original request</summary>

<original body verbatim — or "(no original description)" if empty>

</details>

## Context from codebase

- Bullets with `file_path:line_number` references
- Existing patterns to reuse
- AGENTS.md / .agents/rules constraints that apply

## Open product questions

(Only if Step 2 surfaced non-trivial questions and you picked defaults.)
- **<question>**: chosen default — <one-line reason>

## Proposed plan

1. Step-by-step approach
2. Each step small and independently verifiable
3. Note dependencies (e.g. "after migration runs")

## Acceptance criteria

- [ ] Specific, testable criterion
- [ ] Edge cases covered
- [ ] Tests added/updated for new behavior
- [ ] Documentation updated if user-visible

## Files likely to change

- `path/to/file.rb` — what changes here and why

## Alternatives considered

(Only if Step 2 or Step 4 surfaced multiple options. Prefix with `Product:` or `Technical:`.)
- **Product: <approach>**: discarded because <reason>.
- **Technical: <approach>**: discarded because <reason>.
```

Skip a section that has nothing useful (except `<details>`, which is mandatory).

**Title (create mode only)**: use what the user gave; otherwise propose 2–3 short, specific options. Never invent silently. If not English, propose an English version and confirm.

## Step 6 — Confirm, publish, post-publish

**Confirm (interactive only)**: print the draft path + a one-paragraph summary. Ask explicitly to publish or iterate.

**Publish**:

```bash
# Edit modes
gh issue edit <N> --body-file /tmp/refined-issue-<N>.md

# Create mode — capture the URL and report it back
gh issue create --title "<title>" --body-file /tmp/refined-issue-new.md
```

**Post-publish (CI only)**:

```bash
gh issue edit <N> --remove-label "to-refine-by-ia" || true

gh label create "awaiting-human-review" --color "fbca04" \
  --description "Refined by IA, waiting for human approval" 2>/dev/null || true
gh issue edit <N> --add-label "awaiting-human-review"

gh issue comment <N> --body "Issue refined automatically. Original request preserved in the collapsible block. Review the plan and acceptance criteria above; if it looks right, replace the \`awaiting-human-review\` label with \`to-implement-by-ia\` to launch implementation."
```

In interactive modes, skip the label dance and the comment.

## Gotchas

- **Never lose the original request.** Always wrap it verbatim inside `<details>`.
- **Use `--body-file`, not `--body "..."`** for multi-line markdown.
- **Don't commit, branch, or open PRs.** This skill only writes to issues.
- **Never re-refine in CI** — check the marker first.
- **Never add `to-implement-by-ia` yourself.** Human gate only.
- **Never publish or create without explicit confirmation in interactive modes.**
- **Never invent a title.**
- **Generated content goes in English; the original stays as-is.**
