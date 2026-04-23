# Publish this repo to GitHub (first time)

The remote `origin` is set to `https://github.com/zwilliams/cursor-web-research.git` by default. If your GitHub username is different, change it before pushing, or use the `gh` flow below (it uses your **logged-in** account).

## Option A: GitHub website + git push (minimal tooling)

1. On [github.com/new](https://github.com/new), create a public repository named **`cursor-web-research`**.  
   **Do not** add a README, .gitignore, or license (this repo already has them).

2. Set `origin` to your account (example for user `acme`):

   ```bash
   cd "/Users/zwilliams/Cursor /cursor-web-research"
   git remote remove origin 2>/dev/null || true
   git remote add origin https://github.com/<YOUR_GITHUB_USERNAME>/cursor-web-research.git
   git push -u origin main
   ```

3. Update [README.md](README.md): replace `YOUR_GH_USERNAME` in the one-line `curl` install with your real username or org, commit, and push again.

## Option B: GitHub CLI (`gh`) — one command after login

1. Install and log in (once per machine):

   ```bash
   brew install gh
   gh auth login
   ```

2. From the repo root, create the repository on GitHub and push in one step:

   ```bash
   cd "/Users/zwilliams/Cursor /cursor-web-research"
   ./scripts/first-push.sh
   ```

   Or run manually:

   ```bash
   gh repo create cursor-web-research --public --source=. --remote=origin --push
   ```

   If `origin` already exists with a bad URL, remove it first: `git remote remove origin`.

3. As in option A, commit a README follow-up with your real `raw.githubusercontent.com/.../owner/.../main/install.sh` so the one-liner works for others. (The maintained repo is `zwilliams3/cursor-web-research`.)

## After publishing

- Share the one-line installer from the README.
- In Cursor: run the **After install: verify (checklist)** in [README.md](README.md).
