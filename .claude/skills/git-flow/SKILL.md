---
name: git-flow
description: GitHub Flow workflow — create feature branches, commit, push, and open PRs against main. Use when starting new work, finishing a feature, or managing branches.
---

# GitHub Flow

This project follows **GitHub Flow**: `main` is always deployable, all work happens on short-lived feature branches merged via pull requests.

## Commands

The user may invoke this skill with an argument to specify a sub-command:

- `/git-flow start <branch-name>` — Start a new feature branch
- `/git-flow pr` — Push current branch and open a PR against main
- `/git-flow finish` — Merge the current PR and clean up the branch
- `/git-flow status` — Show current branch state relative to main

If no argument is given, show the current branch status and ask what the user wants to do.

---

## Sub-command: `start`

1. Ensure the working tree is clean (warn if there are uncommitted changes).
2. Fetch latest from origin: `git fetch origin main`.
3. Create and switch to a new branch from `origin/main`:
   ```
   git checkout -b <branch-name> origin/main
   ```
4. Confirm the branch was created and is tracking correctly.

Branch naming conventions:
- Features: `feat/<short-description>`
- Fixes: `fix/<short-description>`
- Chores: `chore/<short-description>`

If the user provides a plain name like `add-logging`, infer the appropriate prefix based on context or ask.

---

## Sub-command: `pr`

1. Check that the current branch is NOT `main`. Refuse to PR from main.
2. Run `dart format .` to format all Dart files.
3. Run `dart analyze` to catch lint issues before pushing.
4. Run `dart test -r expanded packages/gittui/` to ensure tests pass.
5. Push the branch to origin: `git push -u origin HEAD`.
6. Open a pull request against `main` using `gh pr create`.
   - Derive the title from the branch name or commit history.
   - Generate a summary body from the commits on the branch.
   - Use this format:
     ```
     gh pr create --base main --title "<title>" --body "$(cat <<'EOF'
     ## Summary
     <bullet points summarizing changes>

     ## Test plan
     - [ ] Tests pass (`dart test`)
     - [ ] Analysis clean (`dart analyze`)

     🤖 Generated with [Claude Code](https://claude.com/claude-code)
     EOF
     )"
     ```
7. Enable auto-merge: `gh pr merge --squash --auto`.
8. Return the PR URL.

---

## Sub-command: `finish`

1. Ensure the current branch has an open PR (check with `gh pr view`).
2. Confirm with the user before merging.
3. Merge via `gh pr merge --squash --delete-branch`.
4. Switch back to main and pull: `git checkout main && git pull origin main`.
5. Confirm completion.

---

## Sub-command: `status`

1. Show the current branch name.
2. Show commits ahead/behind `origin/main`:
   ```
   git rev-list --left-right --count origin/main...HEAD
   ```
3. Show if there's an open PR for this branch: `gh pr view --json state,url 2>/dev/null`.
4. Show working tree status: `git status --short`.

---

## Rules

- **Never commit directly to main.** All changes go through feature branches and PRs.
- **Never force-push** unless the user explicitly asks.
- **Keep branches short-lived.** Encourage small, focused PRs.
- **Squash merge** by default to keep main history clean.
- Before any destructive action (deleting branches, resetting), confirm with the user.
