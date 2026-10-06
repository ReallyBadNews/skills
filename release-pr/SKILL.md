---
name: release-pr
description: Open a dev → main production release PR (a Promotion) listing every merged PR, its Linear issues, human test steps, and an agent-browser test prompt.
disable-model-invocation: true
---

A **Promotion** is a `dev → main` PR in a repo where `dev` is the default branch and every push to `main` deploys production. Merging it ships every PR merged to `dev` since the last Promotion. The PR body is the release's **manifest**: a reviewer reads it to learn what ships, what to test, and what has to happen before merging.

Write the body in plain language. Readers include people outside engineering.

## Steps

### 1. Collect the release contents

```sh
git fetch origin
git log --first-parent --format='%h %s' origin/main..origin/dev
gh pr list --base main --state merged --limit 3 --json number,title,mergedAt   # previous Promotion
gh pr list --base main --head dev --state open                                 # an existing open Promotion
```

If a Promotion is already open, update its body (`gh pr edit`). Don't open a second one.

For each squash commit, pull the PR number from its `(#NNN)` suffix and read the PR:

```sh
gh pr view NNN --json number,title,body,headRefName,author,files,comments
```

Done when you've read every PR in `origin/main..origin/dev` and none are missing from your notes. Commits without a PR (direct pushes) are listed by SHA.

### 2. Map each PR to its Linear issues

For each PR, check these places in order and use every issue key you find (`[A-Z]+-\d+`, e.g. `GRA-444`):

1. The PR title, body, and branch name.
2. The `linear-code` bot's linkback comment (`<!-- linear-linkback -->`). It holds the issue URL and title.
3. The Linear MCP (`list_issues` search by PR URL or number), if it's authenticated.

Issue URL: `https://linear.app/grahammedia/issue/<KEY>`. For PRs where you find no issue, write "(no Linear issue)". Never guess a key.

Done when every PR has one or more issue keys or is marked "(no Linear issue)".

### 3. Check the release gates

Collect everything that must be true before merging:

- **Dev deploy:** `gh run list --branch dev --workflow "Deploy dev" --limit 3`. The run for the `dev` head SHA has to be green. Report it if it's red or still running.
- **Database:** `git diff --stat origin/main origin/dev -- '**/migrations/**'`. List new migrations. Point out destructive (contract) ones; they need the backup-gate rerun described in ADR-0045.
- **PR-specific gates:** any "Before merging", "Not yet tested", or "After this deploys" section in a PR body, plus each PR's **Not verified** line. Each one becomes a gate or a manual test.
- **Infra, CI, or config changes:** `infra/`, `sst.config.ts`, `.github/`, secrets, IAM. These go under Database, infrastructure, and tooling.

### 4. Write the test plan

Feature PRs split their Test plan by who runs each check, so the release test plan starts from those parts:

- A PR's **Agent-browser test prompt** gets merged into the Promotion's single prompt: carry over each of its numbered checks, tagged with the PR number, and point them at the stage the release targets. Those checks ran against a local dev server before merge. Rerunning them on a deployed stage is the point of the Promotion pass. PRs from before the prompt format may have an **Agent-browser** checklist instead; turn its items into checks the same way.
- **By hand** items become the manual test list, with the PR number on each.
- **Screenshots**: when a PR has them, link its Screenshots section from that PR's manual items ("compare with the After shots in #522"), so the tester knows what right looks like. Don't re-embed the images.

Older PRs, and PRs that don't follow the split, still need covering. Turn each user-facing or infra-visible change into a test and decide who runs it: an agent if it only needs a URL and the page, a person if it needs a signed-in account, a real device, production access, or judgment.

- **Manual testing:** a checkbox list for a person. Each item gives the URL, the action, the expected result, and the PR number. Group items by page or surface. Items that need a signed-in account, a real device, or production access go here only.
- **Agent-browser prompt:** one fenced block to paste into a fresh agent session. It must work on its own, without this PR open. Include the hostnames, the signed-in profile (`agent-browser --profile "$PWD/temp/agent-browser-dev-profile"`), a throwaway session for anything that clears cookies, and a numbered check for each item, at desktop (1440×900) and mobile (390×844) where layout matters. Ask for a pass/fail table with a screenshot for each failure. Target **dev** (`community-dev.<domain>`), where this code is already running. Add a production smoke pass only for after the merge.

Done when every PR is either covered by a test or listed as "no user-visible change" (CI-only, docs-only) with the reason, and every PR's agent-browser checks and By hand items are in the prompt or the manual list.

### 5. Open the PR

Build the body from [TEMPLATE.md](TEMPLATE.md), write it to `temp/release-pr-body.md` (gitignored), then:

```sh
gh pr create --base main --head dev --title "ci: release" --assignee @me --body-file temp/release-pr-body.md
```

The title is exactly `ci: release`. Leave out Claude attribution. Don't merge. The Promotion is merged by hand with **Create a merge commit**, never squash.

Afterwards, link the PR to the thread if a `link_pull_request` tool is available. Then check `gh pr view --json mergeable,mergeStateStatus`. Report the PR URL, the gates that are still open, and anything you couldn't find (e.g. the Linear MCP was unauthenticated).
