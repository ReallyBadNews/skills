---
name: feature-pr
description: Branch, commit, push, and open a feature PR into the default branch, with a Problem / Changes / Test plan body, its Linear issue linked, a browser check of user-visible changes, and before/after screenshots.
disable-model-invocation: true
---

A **feature PR** carries one change into the repo's default branch (`dev` here). Its body is the change's **record**: a reviewer reads it to learn why the change exists, what it does, and how it was verified. Later, `release-pr` reads it to build the Promotion. It collects the Linear key, the **Agent-browser test prompt** (merged into its own prompt), the `[ ]` items under **By hand** (for its manual test list), the **Screenshots**, and any **Before merging** or **After this deploys** section. Write the body so that pass finds everything.

Write in plain language: short sentences, real names for files, functions, and people, and real numbers ("2197 passed", "about 470 errors in three days"). The best source for the body is this session: the problem you were handed, what you found, and what you ran. The diff alone doesn't have that.

Typing `/feature-pr` is the go-ahead to branch, commit, and push for this change only. Never force-push or merge.

## Steps

### 1. Read the work

```sh
git fetch origin
BASE=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
git status --short
git branch --show-current
git log --oneline origin/$BASE..HEAD
git diff origin/$BASE...HEAD --stat; git diff --stat
gh pr view --json number,url,state 2>/dev/null   # an open PR for this branch already?
```

If this branch already has an open PR, you're **updating** it: commit, push, and rewrite the body with `gh pr edit`. Don't open a second one.

If the work builds on another unmerged branch, that branch is the base, and the body gets a **Related PRs** line naming it. If a `gh stack` is checked out, hand off to the `gh-stack` skill for the push and submit.

Done when you know the base, every changed file, and whether you're opening or updating.

### 2. Branch

Stay on a named feature branch (`ke/…`, `feat/…`, a Linear-generated `kelshoff/gra-473-…`). When you're on the base branch or a placeholder worktree branch (`t3code/<hex>`), create one:

```sh
git switch -c ke/<short-kebab-summary>
```

Done when `git branch --show-current` names this change.

### 3. Verify

Run the checks the repo's `AGENTS.md` names (typecheck, lint, format, tests) for each package the change touches, on the code you're about to commit. Record exact commands and counts. They go into the Test plan as `[x]` items. Results from earlier in the session count only if the code hasn't changed since.

A red check stops the skill. Report it and ask whether to fix or open anyway.

Done when every touched package has a recorded green run, or you've stopped on a red one.

### 4. Check it in a browser

Unit tests prove the code does what you think. A browser proves the reader sees what you think. Do this step whenever the change is **user-visible**: pages, components, copy, navigation, redirects, anything the browser renders or follows. Skip it for backend-only, CI, infra, test, and docs changes, and say so in the body ("No agent-browser test: no user-visible change"). Screenshots and recordings are only for user-visible changes.

Load the `agent-browser` skill first, then:

1. **Run this branch locally.** Use the repo's dev server (`AGENTS.md` or the `run` skill says how). In community-creators that's `pnpm sst dev` in tmux window `cc:dev`. It deploys your personal stage (`.sst/stage`), not the shared one, and serves the app at `https://cc.localhost:1355`. The first compile is slow, so poll the URL until it answers.
2. **Find "before".** Use the deployed stage that runs the base branch (`https://community-dev.click2houston.com` for `dev` here). If that stage is behind the base branch, or lacks the data you need, run the base branch locally instead and say which you used.
3. **Check each user-visible change** in two sessions (`<slug>` is the branch name with `/` turned into `-`), `--session <slug>-before` and `--session <slug>-after`, so cookies and dismissed banners don't leak between them. In zsh, wrap the command in a function (`B(){ agent-browser --session <slug>-before "$@"; }`); a command stored in a variable won't run. Check at desktop (`set viewport 1440 900`) and mobile (`set viewport 390 844 2`), comparing before against after. Read the result off the page (`snapshot`, `get url`, `eval`), not just a picture: nav link names, the final URL after a redirect, whether text appears. For redirects, `curl -sk -o /dev/null -w "%{http_code} %{redirect_url}"` shows the status code and every hop.
4. **Screenshot before and after** into `temp/pr-assets/<slug>/`, named `before-<viewport>-<page>.png` and `after-<viewport>-<page>.png`. Shoot the part that changed, not just the top of the page. Dismiss cookie banners and other overlays first, and look at every shot before you use it.
5. **Record only when stills can't show the change**: an animation, a swipe or drag, a multi-step flow. `record start temp/pr-assets/<slug>/<name>.webm` … `record stop`. GitHub plays the video inline, so there's no need to convert it. Skip the recording when the end state looks like the start, as with a redirect that lands on a page that looks the same. Headless Chrome has no address bar, so a video of that proves nothing; the URLs prove it.
6. **Reference the files from the body** by their relative path (`![after desktop](./temp/pr-assets/<slug>/after-desktop-<page>.png)`). Step 8 uploads them with `gh --attach`, which rewrites each matching reference to the uploaded file's URL. Put a video reference on a line by itself; inside a sentence it renders as a link instead of a player. Videos take no alt text.
7. `agent-browser close --all` when you're done. Leave the dev server running.

Be honest about gaps. If the data a change depends on doesn't exist on either stage (an empty module, a badge no story carries), say what you couldn't see, and make it a **By hand** item for when the data exists.

Done when every user-visible change has a before/after pair or a stated reason it has none.

### 5. Commit

Stage the files that belong to this change by name. Leave out `temp/`, scratch files, and unrelated edits, and list anything you left out in the final report. Commit with a Conventional Commits message: `type(scope): what changed`, where type is one of feat, fix, perf, refactor, ci, docs, chore. Leave out Claude attribution. Split into several commits only when the change has clearly separate parts.

Done when `git status --short` shows only files you meant to leave out.

### 6. Find the Linear issue

Look for an issue key (`[A-Z]+-\d+`, e.g. `GRA-473`) in the branch name, the commits, and this session. Then search the Linear MCP (`list_issues`) by topic if it's authenticated. Link it with a magic word on the body's first line:

- `Resolves [GRA-473](https://linear.app/grahammedia/issue/GRA-473)` when this PR finishes the issue.
- `Part of [GRA-473](…)` when it's one step of a larger issue. This links the PR without closing the issue.

Sentry issues go on the body's last line as `Fixes COMMUNITY-CREATORS-HUB-7M`.

If you find no key, stop and ask for one, or for the OK to open without one. Never guess a key.

Done when the first line holds a verified key, or you have the OK to open without one.

### 7. Write the body

Build it from [TEMPLATE.md](TEMPLATE.md) and write it to `temp/feature-pr-body.md` (gitignored).

- **Problem** says what was wrong or missing, and for whom, with the evidence you have (a report, logs, Sentry counts).
- **Changes** gives one bullet per decision, naming the file or function and saying why it changed. A reader should be able to review the diff from this list.
- **Test plan** has three parts, because each one is run by someone different:
  - **Checks run**: the typecheck, lint, format, and test commands from step 3 with their counts, all `[x]`.
  - **Agent-browser test prompt**: one fenced block (four backticks, `text`) to paste into a fresh agent session once this merges and deploys. It must work on its own, without this PR open: the goal, the deployed hostname, which `agent-browser` sessions to use (a throwaway one for anything that clears cookies), the viewports, numbered checks each with a URL, an action, and the expected result, and the output format (a pass/fail table with a screenshot for each failure). Write it as a prompt, not a checklist. Above the block, one line says what step 4 already showed locally (for example, "Ran these checks against this branch locally on 2026-10-05; all 4 passed"). `release-pr` merges these prompts into the Promotion's prompt. If you skipped step 4, write "No agent-browser test: no user-visible change" instead.
  - **By hand**: `[ ]` items an agent can't do. That means real phones and browsers, signed-in or third-party accounts, production, data that doesn't exist yet, and judgment calls ("does this read well?"). `release-pr` turns these into the manual test list, so write each one as a URL, an action, and the expected result.

  End with a **Not verified** line naming what nobody has checked yet, and why.
- **Screenshots** holds the before/after table from step 4, with a caption saying where "before" and "after" came from. If you skipped step 4, write the one-line reason here instead.
- Include **Related PRs**, **Before merging**, and **After this deploys** only when they apply. Before merging covers secrets, IAM, monitors, and scripts to run. After this deploys covers backfills and flags to flip.

Done when every changed file is accounted for in Changes and every claim in Test plan traces to a command you ran or something you saw.

### 8. Push and open

```sh
git push -u origin HEAD
gh pr create --base "$BASE" --title "<type(scope): description>" --assignee @me --body-file temp/feature-pr-body.md \
  --attach ./temp/pr-assets/<slug>/before-desktop-<page>.png \
  --attach ./temp/pr-assets/<slug>/after-desktop-<page>.png
```

Pass one `--attach` per screenshot or video from step 4 (up to 50), spelled exactly as the body references it. The alt text comes from the body's `![alt](…)`, so write it there; a `#alt` suffix on the flag applies only to files the body doesn't reference, which get appended at the end. Attaching needs push access, and the uploaded files show only for people who can see the repo. Without a browser check, leave out `--attach`.

When updating, run `gh pr edit <n> --body-file temp/feature-pr-body.md` instead, with the same `--attach` flags for any new or retaken files. The PR opens ready for review. The title follows the Conventional Commits format of the main commit. If the push is rejected, stop and report. Never force-push.

Afterwards, link the PR to the thread if a `link_pull_request` tool is available. Report the PR URL, the Linear key, the checks you ran, what the browser check showed, the open `[ ]` items, and anything you left uncommitted. Mention that the inline images need a signed-in look on GitHub, since you can't see the rendered PR yourself.
