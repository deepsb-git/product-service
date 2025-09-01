# Push current repository into shopify/ subfolder of https://github.com/deepsb-git/product-service.git
# Usage: Run from the project root in PowerShell. Requires git installed and permissions to the repo.

param(
  [string]$RemoteUrl = "https://github.com/deepsb-git/product-service.git",
  [string]$DefaultBranch = "main"  # set to "master" if your remote uses master
)

$ErrorActionPreference = "Stop"

Write-Host "Initializing git repo (if needed)..."
git init | Out-Null

Write-Host "Adding files and committing..."
git add .
if (-not (git rev-parse --verify HEAD 2>$null)) {
  git commit -m "Initialize product-service" | Out-Null
} else {
  if (-not (git diff --cached --quiet)) {
    git commit -m "Update product-service" | Out-Null
  }
}

Write-Host "Configuring remote origin: $RemoteUrl"
if (git remote | Select-String -SimpleMatch "origin") {
  git remote set-url origin $RemoteUrl | Out-Null
} else {
  git remote add origin $RemoteUrl | Out-Null
}

Write-Host "Fetching remote..."
git fetch origin --prune | Out-Null

Write-Host "Ensuring local branch $DefaultBranch exists..."
git checkout -B $DefaultBranch | Out-Null

Write-Host "Pushing default branch to set upstream if needed..."
try { git push -u origin $DefaultBranch } catch { Write-Host "Proceeding; branch may already exist or be protected." }

Write-Host "Adding/updating shopify subtree on $DefaultBranch..."
$subtreeCmd = "git subtree add --prefix=shopify origin $DefaultBranch"
$pullCmd = "git subtree pull --prefix=shopify origin $DefaultBranch -m 'Update shopify subtree'"
$subtreeAdded = $false
try {
  iex $subtreeCmd
  $subtreeAdded = $true
} catch {
  Write-Host "Subtree add failed, attempting subtree pull..."
  iex $pullCmd
}

Write-Host "Splitting current repo to shopify-split branch..."
# Remove existing split branch if exists
try { git branch -D shopify-split | Out-Null } catch {}

git subtree split --prefix=. -b shopify-split

Write-Host "Pushing shopify-split to remote as shopify-import..."
git push origin shopify-split:refs/heads/shopify-import

Write-Host "Done. Next steps: Open a PR on GitHub from 'shopify-import' into '$DefaultBranch'."