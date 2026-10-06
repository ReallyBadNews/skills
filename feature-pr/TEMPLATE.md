Resolves [<KEY>](https://linear.app/grahammedia/issue/<KEY>) <or "Part of …"; omit only with Kenny's OK>

## Problem

<What was wrong or missing, who hit it, and the evidence: a report, logs, Sentry counts, a screenshot. Name the root cause if you found it.>

## Changes

- <One bullet per decision: the file or function in backticks, what it does now, and why.>

## Related PRs

<Only if they apply. Base or stacked PRs, and companion PRs in other repos (`GrahamDigital/<repo>#<n>`).>

- #<n>: <how it relates>

## Before merging

<Only if something must happen first: secrets, IAM, a Sentry monitor, a prerequisite script.>

- [ ] <gate>

## Test plan

### Checks run

- [x] `<test file>`: <cases covered>
- [x] `<package>`: typecheck, lint, format, full suite (<N> passed)

### Agent-browser test prompt

<One line on what the local browser check showed, e.g. "Ran these checks against this branch locally (`<dev command>`, `<local URL>`) on <date>; all <N> passed." Or: "No agent-browser test: no user-visible change.">

````text
<Standalone prompt to run on <stage> after this deploys: the goal, the hostname
(<deployed URL>), agent-browser sessions (a throwaway one for checks that clear
cookies), viewports (1440x900 desktop, 390x844 mobile), then numbered checks:

1. <URL> at <viewport>: <action>. Expect <result>.

Report a pass/fail table, one row per check, with a screenshot of each failure.>
````

### By hand

- [ ] <URL> on <real device / signed-in account / production>: <action> → <expected result>
- Not verified: <what nobody has checked yet, and why>

## Screenshots

<"Before" is <where>. "After" is <where>. Or one line saying why there are none.>

| | Before | After |
| --- | --- | --- |
| <view> | ![before <view>](./temp/pr-assets/<slug>/before-<viewport>-<page>.png) | ![after <view>](./temp/pr-assets/<slug>/after-<viewport>-<page>.png) |

<A recording, if any, on a line by itself so it renders as a player:>

./temp/pr-assets/<slug>/<name>.webm

## After this deploys

<Only if follow-up is needed: backfill, flag flip, monitoring to watch.>

<"Fixes <SENTRY-SHORT-ID>" as the last line if this resolves a Sentry issue>
