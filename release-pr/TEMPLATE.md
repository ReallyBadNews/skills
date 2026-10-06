Promote `dev` to `main` for the <YYYY-MM-DD> production release: <N> merged changes since the last release (#<previous Promotion>). <One or two sentences on what readers or operators will notice.>

## Pull requests

<Group by theme (User-facing changes, Performance, Infrastructure, CI/CD, …). One line per PR:>

- #<n> <PR title> ([<KEY>](https://linear.app/grahammedia/issue/<KEY>)) <or "(no Linear issue)">

## Linear issues

- [<KEY>](https://linear.app/grahammedia/issue/<KEY>): <issue title, plain words> (#<n>, #<n>)

## Database, infrastructure, and tooling

- <Migrations: "No new SQL migrations." or a list with contract/expand noted>
- <infra/, CI, secrets, IAM, ADRs: one line each with the PR number>

## Before merging

- [ ] Deploy dev is green for `<dev head SHA>` (<run link>)
- [ ] <Each PR-specific gate: prerequisite scripts, secrets to set, config to apply>
- [ ] Manual testing below is complete

## Manual testing (human in the loop)

Run against dev (`https://community-dev.<domain>`) before merging, then smoke-test production after the deploy.

### <Surface or page>

- [ ] <URL>: <action> → <expected result> (#<n>; <"compare with the After shots in #<n>" when that PR has Screenshots>)

### No user-visible change

- #<n>: <why it has no user-visible change (CI-only, docs-only, …)>

## Agent-browser test prompt

Paste this into a fresh agent session:

````text
<Standalone prompt: goal, hostnames, profiles/sessions, numbered checks with
expected results (every PR's agent-browser checks, rerun on the deployed stage),
viewports, which checks must use a throwaway session, output format
(pass/fail table + screenshots of failures).>
````

## Validation and promotion

- Source commit: `<dev head SHA>` (current `dev` head).
- Merge this PR using **Create a merge commit**, as required for `dev` → `main` promotions. Merging triggers **Deploy production**, which reruns the full CI gate, deploys the whole production stage, and runs smoke checks against the merge SHA.
