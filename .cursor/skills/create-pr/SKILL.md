---
name: create-pr
description: Write and publish a PR for the current branch
disable-model-invocation: true
---
Write and publish a PR for the current @branch

- Check the code diff of the current branch with the master branch
- Review uncommitted changes and add them to the PR if necessary
- Run `i18n-tasks normalize`
- Use the CLI `gh pr create` to create the PR
- Use the PR template: .github/PULL_REQUEST_TEMPLATE.md
- Review @AGENTS.md "When Adding..." sections to ensure all required updates are done (MODULE_EVENTS, permissions, migrations, etc.)
- Write brief and concise PR description, focusing on key things users should know about the changes.
- Publish the PR to the remote repository as draft, in English
