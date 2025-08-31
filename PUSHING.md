Goal: Push this product-service project into the mono-repo https://github.com/deepsb-git/shopify-microservice-deployment.git under subfolder product-service/

Below are two safe approaches. Use Option B if you do not need to preserve this repo's commit history. Use Option A if you want to preserve history using git subtree.

Prerequisites
- You must have permissions to push to the GitHub repository.
- Git is installed and configured with your GitHub credentials.

Option A: Preserve history with git subtree (recommended for history)
1) From this project directory:
   powershell> git init
   powershell> git add .
   powershell> git commit -m "Initialize product-service module"
2) Add the target mono-repo as a remote:
   powershell> git remote add mono https://github.com/deepsb-git/shopify-microservice-deployment.git
3) Fetch the remote:
   powershell> git fetch mono
4) Create a local branch for the module content if you don’t already have one (optional):
   powershell> git branch -M product-service-module
5) Now push using subtree split to the remote mono-repo under folder product-service/.
   If the remote repository already exists and has a default branch (e.g., main), do:
   powershell> git subtree add --prefix=product-service mono main || git subtree pull --prefix=product-service mono main -m "Update subtree placeholder"
   Now push your current repo as a subtree to a new branch and merge via PR:
   powershell> git subtree split --prefix=. -b product-service-split
   powershell> git push mono product-service-split:refs/heads/product-service-import
   Then, on GitHub, open a PR from product-service-import into main and merge.

Note: Some environments have problems with subtree on Windows. If this is complex, use Option B.

Option B: Simple copy into mono-repo (no history)
1) Clone the mono-repo to a new directory:
   powershell> cd ..
   powershell> git clone https://github.com/deepsb-git/shopify-microservice-deployment.git shopify-microservice-deployment
2) Create a subfolder product-service and copy files:
   powershell> cd shopify-microservice-deployment
   powershell> mkdir product-service
   powershell> robocopy "F:\shopify_micro\product-service" .\product-service /E /XD .git target data .idea .vscode build
   (robocopy exit codes > 1 can include warnings; verify files are copied.)
3) Commit and push in the mono-repo:
   powershell> git add product-service
   powershell> git commit -m "Add product-service module"
   powershell> git push origin main

Notes
- The .gitignore here already excludes target/, IDE files, and build outputs.
- The data/ directory contains MongoDB data files and should NOT be pushed.
- If the mono-repo uses a different default branch than main (e.g., master), replace main accordingly.
- If you prefer to nest further (e.g., services/product-service), replace product-service with the desired path everywhere.
