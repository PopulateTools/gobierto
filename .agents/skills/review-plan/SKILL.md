---
name: review-plan
description: >
  Review an implementation plan critically before executing it. Use when the user says "review plan",
  "check my plan", or before starting implementation of a planned task.
---

Review your plan before implementing it. Have a critical eye:

- Did you identify the right module owner for each change?
- Are there existing services, queries, or decorators that could be reused instead of writing new ones?
- Does the plan respect site scoping (every multi-tenant query through `current_site`)?
- Are tests planned for every new service / controller / job?
- Does the plan handle the locales correctly (es / ca / gl / eu / en where appropriate)?
- Are there hidden dependencies (e.g. another module's pub/sub event, an existing background job, a Sidekiq queue) that need to be touched?

Pull up more code and re-read the plan. Update it if anything is off before starting implementation.
