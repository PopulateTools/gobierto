---
name: deploy-to-staging
description: >
  Deploy the current branch to staging via the project's webhook-based deploy script.
  Use when the user says "deploy to staging", "push to staging", or wants to test the branch on staging.
---

Staging deploys go through a webhook script that triggers the deploy bot.

## Prerequisites

- The branch is pushed to `origin`. If it isn't, push it first:
  ```bash
  git push -u origin HEAD
  ```
- The environment variables `DEPLOY_BOT_TOKEN` and `GOBIERTO_STAGING_DEPLOY_URL` are set locally. If they aren't, ask the user — they live in their personal env, not in the repo.

## Deploy

```bash
script/staging_deploy.sh
```

This issues a POST to the deploy webhook. The script returns immediately; the actual deploy happens asynchronously on the staging server. Watch CircleCI / the staging dashboard for completion.

## Notes

- There is no merge-into-`staging`-branch workflow. The webhook builds whatever ref the bot is configured to deploy.
- If you need to confirm what was deployed, check the deploy bot's logs or ask the team — there is no local feedback loop.
- Don't run this against production; production has a separate `script/production_deploy.sh` and is gated by humans.
