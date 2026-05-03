---
name: manage-skills
description: >
  Create, review, and improve agent skills in .agents/skills/.
  Use when the user wants to add a new skill, review existing skills,
  improve a skill's description or body, or check skills against best practices.
---

# Managing Agent Skills

Skills live in `.agents/skills/<skill-name>/SKILL.md`. Each skill is a directory with at minimum a `SKILL.md` file.

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: detailed documentation
└── assets/           # Optional: templates, resources
```

## Frontmatter (required)

```yaml
---
name: skill-name        # lowercase, hyphens only, must match directory name, max 64 chars
description: >          # max 1024 chars — what it does AND when to use it
  Extract PDF text, fill forms, merge files.
  Use when the user needs to work with PDF documents.
---
```

### Writing good descriptions

The description carries the entire burden of triggering. A skill only helps if the agent activates it.

- **Use imperative phrasing**: "Use when..." not "This skill does..."
- **Focus on user intent**: describe what the user is trying to achieve, not internal mechanics.
- **Include trigger phrases**: "Use when the user says 'deploy to staging', 'push to staging'..."
- **Be specific but not narrow**: cover the skill's scope without false-triggering.
- **Stay under 1024 characters.**

```yaml
# Bad — too vague, won't trigger reliably
description: Helps with PDFs.

# Good — specific about what and when
description: >
  Extract text and tables from PDF files, fill PDF forms, and merge multiple PDFs.
  Use when working with PDF documents or when the user mentions PDFs, forms,
  or document extraction.
```

## Body best practices

### Keep it focused (<500 lines, <5000 tokens)

The full SKILL.md loads into context when activated. Every token competes for attention.

- **Add what the agent lacks, omit what it knows**: focus on project-specific procedures, edge cases, and conventions — don't explain HTTP or git basics.
- **Procedures over declarations**: teach *how to approach* a class of problems, not *what to produce* for a specific instance.
- **Provide defaults, not menus**: pick one recommended approach, mention alternatives briefly.

### Use progressive disclosure

Keep core instructions in `SKILL.md`. Move detailed content to:

- `references/` — detailed docs loaded on demand.
- `scripts/` — executable code the agent runs.
- `assets/` — templates, schemas, lookup tables.

Tell the agent *when* to load each file: "Read `references/api-errors.md` if the API returns a non-200 status code."

### Effective patterns

**Gotchas** — concrete corrections to mistakes the agent will make:

```markdown
## Gotchas
- Multi-tenant queries must scope through current_site
- Service factory files end with `_factory.rb` and are plain Ruby (not FactoryBot)
```

**Checklists** for multi-step workflows:

```markdown
- [ ] Step 1: Analyze the input
- [ ] Step 2: Validate the mapping
- [ ] Step 3: Execute and verify
```

**Validation loops** — instruct the agent to verify its own work:

```markdown
1. Make edits
2. Run validation: `bin/rails test <relevant_file>`
3. If validation fails, fix and re-validate
4. Only proceed when validation passes
```

## Review checklist

When reviewing a skill, check:

- [ ] `name` matches directory name, lowercase + hyphens only.
- [ ] `description` says what the skill does AND when to use it.
- [ ] `description` includes trigger phrases or keywords.
- [ ] `description` is under 1024 characters.
- [ ] Body focuses on what the agent wouldn't know on its own.
- [ ] Body is under 500 lines.
- [ ] Large reference material is in separate files, not inline.
- [ ] Scripts are in `scripts/`, not inlined in SKILL.md.
- [ ] No redundant explanations of things the agent already knows.
- [ ] Gotchas section covers non-obvious edge cases (if applicable).

## Reference

- Full specification: https://agentskills.io/specification
- Best practices: https://agentskills.io/skill-creation/best-practices
- Optimizing descriptions: https://agentskills.io/skill-creation/optimizing-descriptions
