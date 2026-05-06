---
name: create-pr
description: >
  Write and publish a PR for the current branch as a draft, in English.
  Use when the user says "create PR", "open PR", "submit PR", or wants to publish their branch for review.
---

Write and publish a PR for the current branch as a **draft**, in **English**.

## Before creating the PR

- Run `bundle exec i18n-tasks normalize` if any locale file changed.
- Run `bin/rails test` on the affected test files.
- Run `bundle exec rubocop <changed_files>` and `npm run eslint` / `npm run stylelint` if Ruby or JS/CSS changed.
- Re-read `@AGENTS.md` "Best Practices" sections to make sure the relevant conventions are honored (site scoping, modular layout, service patterns, strong params, tests).

## PR content

- Use the template at `.github/PULL_REQUEST_TEMPLATE.md` — fill the existing sections, don't invent new ones.
- Title: capitalized, in English, under ~70 characters. Use the body for details.
- "What does this PR do?": one short paragraph framed around user-visible outcome (or developer-visible outcome for refactors).
- "How should this be manually tested?": concrete steps. If the change has UI, include the path to visit. If the branch has been deployed to staging (check with `git branch --contains HEAD staging`), include the staging URL — otherwise note that a staging deploy is needed first.
- Tick the "Does this PR change any configuration file?" boxes if you added/changed env vars, `config/application.yml`, or `config/secrets.yml` — Ansible may need updates.
- Tick the "Does this PR require updating the documentation?" boxes if site config, templates, or modules changed.

## Publish

```bash
gh pr create --draft --base master --title "<title>" --body-file /tmp/pr-body.md
```

Use `--body-file` (write the body to `/tmp/pr-body.md` first) rather than `--body "..."` — heredocs and backticks get mangled when passed inline.

After creating the PR, surface the URL to the user.
