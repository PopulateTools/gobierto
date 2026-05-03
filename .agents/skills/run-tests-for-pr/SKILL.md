---
name: run-tests-for-pr
description: >
  Determine which tests to run for the current PR. Use when the user wants to know what tests cover their changes,
  or asks "what tests should I run" before opening a PR.
---

Decide what to run before opening a PR for the current branch.

## Step 1 — Inspect the diff

```bash
git status
git diff master...HEAD --stat
```

Verify there are no uncommitted or untracked Ruby/JS files that should be part of the PR. If there are, surface them and stop.

## Step 2 — Map files to test files

For each changed file:

- `app/services/<module>/<thing>.rb` → `test/services/<module>/<thing>_test.rb`
- `app/controllers/<module>/<thing>_controller.rb` → `test/controllers/<module>/<thing>_controller_test.rb` and/or `test/integration/<module>/<thing>_test.rb`
- `app/models/<module>/<thing>.rb` → `test/models/<module>/<thing>_test.rb`
- `app/jobs/<module>/<thing>_job.rb` → `test/jobs/<module>/<thing>_job_test.rb`
- `app/javascript/<module>/<thing>.js` → `test/javascript/<module>/<thing>.test.js`
- `config/locales/*.yml` → `test/misc/i18n_test.rb`

If a touched file has no test file, surface that — the change probably needs one.

## Step 3 — Run

```bash
bin/rails test <list_of_test_files>
```

If front-end files changed:

```bash
npm run test
```

If locale files changed:

```bash
bundle exec i18n-tasks normalize
bin/rails test test/misc/i18n_test.rb
```

## Step 4 — Surface results

Report which tests ran, which passed, which failed. Don't open the PR until everything is green.
