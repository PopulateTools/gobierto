---
name: review-and-reflect
description: >
  Review and reflect on PR changes before sending for review. Use when implementation is done
  and the user wants a final check before creating a PR, or says "review changes",
  "review and reflect", or "is this ready for review".
---

This PR is almost ready to send for review.

Before doing it:

1. **Review changes** against `master` to understand what has been changed:
   ```bash
   git log --oneline master..HEAD
   git diff master...HEAD
   ```

2. **Reflect on the implementation**: Is there anything you wish you'd done differently? Any way you'd have stored the data differently? Are there places to refactor or revisit before pushing?

3. **Check tests**: Find tests related to the changes and run them to make sure they pass (follow the rules in `@.agents/rules/tests.mdc`):
   ```bash
   bin/rails test <relevant_test_files>
   ```

4. **Code review**: Review the code and make improvement suggestions, as a senior developer would. Use `@AGENTS.md` and `@.agents/rules/` as reference for coding standards and project conventions. Pay particular attention to:
   - Site scoping (every multi-tenant query through `current_site`).
   - Module boundaries (don't reach across `gobierto_*` modules unnecessarily).
   - Service object shape (`.new(args).call`, `attr_reader`, single responsibility).
   - Strong params, frozen string literals, RuboCop compliance.

5. **UI review**: If the changes include views, helpers, SASS, or Vue components, eyeball the affected pages on a running app (`bin/dev`) before pushing. Check that Turbolinks hasn't broken any one-off JS init.

Don't create files related to the review unless you are asked to do so.
