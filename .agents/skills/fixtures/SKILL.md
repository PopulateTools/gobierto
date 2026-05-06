---
name: fixtures
description: >
  Guide for using test fixtures correctly. Use when writing or modifying tests that reference fixture data,
  to avoid inventing names and to keep references consistent with files in test/fixtures/.
---

# Test fixtures

Fixtures are loaded with `fixtures :all` in `test/test_helper.rb`. They live under `test/fixtures/` and are organized by module (`gobierto_admin/`, `gobierto_budgets/`, `gobierto_people/`, etc.) plus shared top-level files (`sites.yml`, `activities.yml`, `gobierto_module_settings.yml`, ...).

## Rules

- Use the **exact fixture name** that exists in the YAML — don't invent labels.
- Reference fixtures via the standard Rails helpers: `sites(:madrid)`, `users(:user1)`, `gobierto_admin_admins(:steve)`. The helper name matches the fixture file (without extension).
- If a fixture you need doesn't exist, propose adding it before fabricating data inline. Bring it up with the user — fixtures are shared state and other tests may depend on them.
- For per-test variations on top of a fixture (e.g. a budget for a specific year), use a factory in `test/factories/` rather than mutating the fixture row.

## Where to look

- `test/fixtures/sites.yml` — the canonical multi-tenant baseline.
- `test/fixtures/<module>/<thing>.yml` — module-specific records.

If you can't find a fixture you expect to exist, search:

```bash
rg "<label>:" test/fixtures/
```

before assuming it's missing.
