# Agent Guidelines for Gobierto

This document provides comprehensive guidelines for AI agents working on the Gobierto project.

## Project Overview

Gobierto is a multi-tenant open-government platform built in Ruby on Rails. It provides public administrations and other organizations with tools for transparency, citizen participation, and accountability: budget visualization, people and agendas, statistical indicators, government plans, civic participation processes, open-data publication, and a CMS.

The codebase is modular by domain. Each major capability lives under its own namespace (e.g. `gobierto_admin`, `gobierto_budgets`, `gobierto_people`, `gobierto_plans`, `gobierto_data`, `gobierto_indicators`, `gobierto_cms`, `gobierto_calendars`, `gobierto_common`, `gobierto_core`, `gobierto_dashboards`, `gobierto_attachments`, `gobierto_investments`, `gobierto_observatory`, `user`) inside `app/controllers/`, `app/models/`, `app/services/`, `app/views/`, `test/`, etc.

### Git

The main branch is `master`. The repository lives at `PopulateTools/gobierto` on GitHub. CI runs on CircleCI.

### Key Technologies

- **Backend**: Ruby on Rails 6.1.7.7, Ruby 3.3.4, PostgreSQL, Redis, Sidekiq.
- **Frontend**: Vue 2.5, esbuild (`jsbundling-rails`), SASS, PureCSS, Turbolinks 5, jQuery, FullCalendar, Leaflet, Mapbox-GL, D3.
- **Multi-tenancy**: every site is a `Site` record; everything is scoped through `current_site`. There is no global "organization" concept.
- **Authentication**: custom, based on `bcrypt` and `Authentication::Authenticable`. The application controller applies `authenticate_user_in_site` before_action globally.
- **Authorization**: hand-rolled policies under `app/policies/gobierto_admin/`, base class `GobiertoAdmin::BasePolicy`.
- **Notifications**: in-app notifications via `User::Notification` model + `User::NotificationMailer` + `User::NotificationDigest` service. There is no `noticed` gem.
- **Testing**: Minitest with `use_transactional_tests = true` (no DatabaseCleaner). Capybara + Selenium for integration tests, VCR for HTTP fixtures, Mocha + Spy for mocking, Timecop for time, WebMock for HTTP guards.
- **JS testing**: Jest 27 + Babel.
- **Linting**: RuboCop, ESLint with `eslint-plugin-vue`, Stylelint with `stylelint-config-standard-scss`. Husky + lint-staged enforce checks on commit.
- **Monitoring**: Appsignal (Ruby + JS).
- **Deploy**: staging via `script/staging_deploy.sh` (webhook); production via `script/production_deploy.sh`.

### Architecture Patterns

- **Modular by domain**: code is grouped under module namespaces (`GobiertoBudgets::*`, `GobiertoPeople::*`, etc.). Stay inside the module that owns the feature.
- **Service objects**: business logic in `app/services/<module>/<thing>.rb`. Calling convention is `Service.new(args).call`. Use `attr_reader` for state.
- **Background jobs**: Sidekiq, jobs in `app/jobs/`. Wrap heavy work behind a service called from `perform`.
- **Decorators / Presenters / Forms / Queries / Repositories**: dedicated layers under `app/decorators/`, `app/presenters/`, `app/forms/`, `app/queries/`, `app/repositories/`.
- **Cells**: `app/cells/` is present but not the default. Prefer plain ERB partials and helpers.
- **Pub/Sub**: cross-module reactions via `app/pub_sub/`.
- **Vue components**: front-end components live in `app/javascript/<module>/`. They are mounted on DOM elements rather than driving SPA navigation.

### Application Domain Context

- A **Site** is the multi-tenant unit. Users, admins, budgets, people, plans, pages, datasets, etc. all belong to a site.
- **Admins** (`GobiertoAdmin::Admin`) manage one or more sites and have module-level permissions checked through `BasePolicy#can_manage_module?`.
- **Users** are end-users; authentication is done with `has_secure_password` plus site scoping.
- The platform is **multi-language** (Spanish, Catalan, Galician, Basque, English). Translations live in `config/locales/`. Many models use `json_translate` for per-locale attributes. Routes are translated via `route_translator`.

When you need to understand how a specific module works, start by reading its directory under `app/controllers/<module>/`, `app/models/<module>/`, `app/services/<module>/`, and `test/integration/<module>/`.

## Coding Guidelines

For detailed coding standards and best practices, consult the rules in `.agents/rules/`:

- `rails.mdc` — Ruby/Rails conventions, modular architecture, service objects.
- `tests.mdc` — Minitest, transactional fixtures, Capybara, VCR, factories.
- `javascript.mdc` — Vue 2 components, esbuild, ESLint.
- `javascript-tests.mdc` — Jest setup and conventions.
- `views.mdc` — ERB partials, helpers, assets, Turbolinks-friendly markup.
- `i18n.mdc` — internationalization with `i18n-tasks`.
- `gems.mdc` — adding dependencies.
- `security.mdc` — site scoping, policies, params, logging.
- `mailers.mdc` — mailer conventions.
- `frozen_string_literal.mdc` — required magic comment.
- `rubocop.mdc` — running RuboCop on changed lines only.

### Critical Requirements

- **RuboCop compliance**: run `bundle exec rubocop <file>` on files you change. Fix violations before committing.
- **Frozen string literals**: every `.rb` file must start with `# frozen_string_literal: true`.
- **Service objects**: prefer service objects for non-trivial business logic. Keep controllers thin.
- **Strong parameters**: define `permitted_params` helpers in controllers; never pass raw `params` to model methods.
- **Test coverage**: write Minitest tests for new functionality. Every new service class gets a test in `test/services/<module>/`. Controllers get coverage in `test/controllers/<module>/` (HTTP-level) and/or `test/integration/<module>/` (browser-level).
- **i18n**: every user-facing string lives in `config/locales/*.yml`. Run `i18n-tasks normalize` before committing.

## Best Practices

### When Starting a Task

1. Identify which module owns the feature; stay inside it.
2. Check `.agents/rules/` for relevant conventions.
3. Look for similar implementations in the same module; mirror the existing patterns.
4. Read the module's existing services/decorators/queries before adding new ones.

### Common Patterns

- **Service objects**: `Service.new(args).call`. Declare `attr_reader` for inputs in `initialize`. Single-responsibility — split a service when it grows beyond its action.
- **Background jobs**: subclass `ApplicationJob`, define `perform`. Delegate the body to a service.
- **Policies**: extend `GobiertoAdmin::BasePolicy`. Inputs come in as `attributes: { current_admin:, current_site: }`. Use `can_manage_module?(:module_name)` to gate module-level admin access.
- **Concerns**: shared behavior in `app/models/concerns/` or `app/controllers/concerns/`.
- **Vue components**: mount on a DOM element via `data-` attributes; keep state local; talk to Rails via JSON endpoints.

### When Adding New Controllers

- Place the controller under the module that owns the feature: `app/controllers/<module>/`.
- Inherit from the module's base controller (e.g. `GobiertoAdmin::AdminController`, `GobiertoBudgets::ApplicationController`) — these already wire up site scoping and authentication.
- Add a controller test under `test/controllers/<module>/` covering at least the main actions and access control.
- If the controller exposes site-admin functionality, add a policy check using the relevant policy class.

### When Adding New Permissions

- Permissions are admin-scoped. Look at the existing permission concern for the module (e.g. `GobiertoAdmin::ModuleHelper`) and follow its pattern.
- If you add a new admin-level capability, update the matching policy under `app/policies/gobierto_admin/` so it gates controller access correctly.
- Add tests that exercise both allowed and forbidden paths.

### When Adding Migrations

- Add a regular Rails migration in `db/migrate/`.
- Run `bin/rails db:migrate` and commit `db/schema.rb`.
- For data backfills, prefer a one-off script captured in the PR description (see "When Creating Pull Requests"). Keep the migration itself small and reversible.

### When Adding Mailers

- Mailers live under `app/mailers/<module>/`, views under `app/views/<module>/<mailer>/`.
- Inherit from `ApplicationMailer`.
- For user notifications triggered by activity, prefer creating a `User::Notification` and letting `User::NotificationDigest` deliver it. Direct `deliver_later` is fine for transactional emails (verification, invitations).
- Provide locale-specific views (`*.es.html.erb`, `*.ca.html.erb`, etc.) when the wording differs by language; otherwise use `t(".key")` lookups in a single template.

### When Adding Environment Variables

- Document the variable in `.env.example` with a brief comment.
- If the variable is read in `config/application.yml` or `config/secrets.yml`, mention it in the PR description (the PR template asks about this).
- Ansible roles may need updates for production. Flag this in the PR.

### When Creating Pull Requests

- **Language**: write PR titles and descriptions in English. Capitalize the title.
- **Template**: fill in `.github/PULL_REQUEST_TEMPLATE.md` — the "What does this PR do?", "How should this be manually tested?", and configuration-impact checkboxes.
- **One-time scripts**: if the PR requires a one-off backfill or data migration, paste the exact command in the PR description rather than checking in a rake task.
- **Manual testing**: include the path or staging URL where the change can be exercised. For UI-visible changes, deploy to staging first via `script/staging_deploy.sh` and link the resulting URL.

### What to Avoid

- Ignoring RuboCop violations.
- Fat controllers — push logic into services or queries.
- Cross-module references that bypass the module boundary; use the module's public interface (services, presenters) instead.
- Hardcoded site-specific values; read from `current_site` configuration.
- Committing secrets or API keys; sensitive values belong in env vars and Ansible.
- Tests that hit external services without VCR or WebMock guards.
- Storing user-supplied HTML without sanitization (`rails-html-sanitizer` is loaded — use it).

## Creating Plans and Evaluations

Plans, specs, and design docs go under **`docs/plans/`** with the file name format `YYYY-MM-DD-brief-description.md`. Each plan should include actionable tasks with acceptance criteria, effort estimates, and dependencies — written so it can be turned into one or more GitHub issues.

Use a plan when:

- Evaluating a significant codebase area (>500 LOC).
- Planning a major refactor or migration.
- Documenting an architectural decision.
- Analyzing a complex technical problem before writing code.

## Documentation Standards

- Keep documentation focused on **what** and **why**, not on implementation details that the code already shows.
- Reference code paths instead of duplicating examples.
- Avoid volatile information that will rot quickly (counts, deploy timestamps, ad-hoc URLs).
- The user-facing manual lives at `docs/manual_admin.md`; update it when admin-visible behavior changes.
