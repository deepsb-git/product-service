Goal: Push this product-service project to the GitHub repository https://github.com/deepsb-git/product-service.git under a subfolder named shopify on the remote master (or main) branch.

IMPORTANT for Windows PowerShell users
- Do NOT use Bash operators like || (OR) or && (AND) in PowerShell; they will cause errors like: The token '||' is not a valid statement separator in this version.
- In this guide, all commands are PowerShell-friendly. On Windows, prefer mvnw.cmd over mvnw.

If instead you want to push this repository as-is to its own root (not under a subfolder), see Option 3.

Prerequisites
- You must have permissions to push to the GitHub repository.
- Git is installed and configured with your GitHub credentials.
- Replace main with master if the default branch of the remote is master. Commands below show both where relevant.

How to check default branch name
powershell> git ls-remote --symref origin HEAD
# Look for: ref: refs/heads/main or ref: refs/heads/master

Option 1: Preserve history into a shopify/ subfolder using git subtree (recommended)
1) Initialize and commit this repository (skip if already committed):
   powershell> git init
   powershell> git add .
   powershell> git commit -m "Initialize product-service"
2) Add the target repository as a remote named origin (or update it if origin already exists):
   powershell> git remote add origin https://github.com/deepsb-git/product-service.git
   # If origin already exists and points elsewhere:
   powershell> git remote set-url origin https://github.com/deepsb-git/product-service.git
3) Fetch the remote branches:
   powershell> git fetch origin --prune
4) Ensure the remote has a default branch. If it’s empty, create one locally:
   powershell> git checkout -B main    # or: git checkout -B master
   # Do an initial push to establish it if needed:
   powershell> git push -u origin main # or: git push -u origin master
5) Add or update a placeholder subtree at shopify/ on the remote branch (creates folder if not present).
   PowerShell-compatible approach using try/catch:
   powershell> try { git subtree add --prefix=shopify origin main }
              catch { git subtree pull --prefix=shopify origin main -m "Update shopify subtree" }
   # If using master instead of main, replace main with master in both commands.
6) Split current repo history and push into shopify/ folder on the remote via a temporary branch:
   powershell> try { git branch -D shopify-split } catch {}
   powershell> git subtree split --prefix=. -b shopify-split
   powershell> git push origin shopify-split:refs/heads/shopify-import
   On GitHub, open a PR from shopify-import into main (or master) and squash/merge.

Notes for Option 1
- Some Windows environments have issues with subtree; if so, use Option 2.
- After merging the PR, the remote will contain this project under shopify/ preserving history.

Option 2: Simple copy into shopify/ (no history preservation)
1) Clone the target repo into a separate directory:
   powershell> cd ..
   powershell> git clone https://github.com/deepsb-git/product-service.git product-service-remote
2) Copy this project into the shopify subfolder of that clone:
   powershell> cd product-service-remote
   powershell> mkdir shopify
   powershell> robocopy "F:\shopify_micro\product-service" .\shopify /E /XD .git target data .idea .vscode build
   # robocopy exit codes > 1 can be warnings; verify files were copied.
3) Commit and push in the cloned remote repository directory:
   powershell> git add shopify
   powershell> git commit -m "Add product-service under shopify/"
   powershell> git push origin main   # or: git push origin master

Option 3: Push this repository to the root of the target repo (not under shopify/)
1) From this project directory:
   powershell> git init
   powershell> git add .
   powershell> git commit -m "Initial commit"
2) Set the remote and push master (or main) branch:
   powershell> git branch -M master
   powershell> git remote add origin https://github.com/deepsb-git/product-service.git
   powershell> git push -u origin master
   # If using main instead:
   powershell> git branch -M main
   powershell> git push -u origin main

Troubleshooting
- PowerShell parse error with '||': Replace any Bash conditional like "cmd1 || cmd2" with a try/catch block in PowerShell or run the commands sequentially.
- Authentication: Ensure you’re logged in (Git Credential Manager) or use a PAT URL form.
- Remote protection rules: If main/master is protected, push to a feature branch and open a PR.
- Large files: Ensure target/, data/, and build artifacts are excluded. Update .gitignore if needed.

Automation script (PowerShell)
You can run the included script that already uses try/catch instead of Bash operators:
   powershell> .\push_to_shopify_subfolder.ps1 -RemoteUrl "https://github.com/deepsb-git/product-service.git" -DefaultBranch "main"  # or "master"
