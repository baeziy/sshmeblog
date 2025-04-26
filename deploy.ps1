# # --- Configuration ---
# $sourcePath = "G:\My Drive\blog\Blog" # <-- UPDATE THIS
# $destinationPath = "C:\Users\TK-LPT-1025\Documents\nbin\blog\sshmeblog\content\archive" # <-- UPDATE THIS
# $myrepo = "git@github.com:baeziy/sshmeblog.git" # <-- Your GitHub repository
# $sourceBranch = "main"
# $ghPagesBranch = "gh-pages"
# # --- End Configuration ---

# $ErrorActionPreference = "Stop"
# Set-StrictMode -Version Latest

# # Set current directory to script location
# $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
# Set-Location $ScriptDir
# Write-Host "Running script in: $(Get-Location)"

# # Check required commands
# $requiredCommands = @('git', 'hugo', 'robocopy')
# foreach ($cmd in $requiredCommands) {
#     if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
#         Write-Error "$cmd is not installed or not found in PATH."
#         exit 1
#     }
# }

# # Check Python command
# if (Get-Command 'py' -ErrorAction SilentlyContinue) {
#     $pythonCommand = 'py'
# } elseif (Get-Command 'python' -ErrorAction SilentlyContinue) {
#     $pythonCommand = 'python'
# } elseif (Get-Command 'python3' -ErrorAction SilentlyContinue) {
#     $pythonCommand = 'python3'
# } else {
#     Write-Error "Python is not installed or not found in PATH."
#     exit 1
# }
# Write-Host "Using Python command: $pythonCommand"

# # --- Git Setup ---
# if (-not (Test-Path ".git")) {
#     Write-Host "Initializing Git repository..."
#     git init
#     git branch -M $sourceBranch
#     git remote add origin $myrepo
# } else {
#     Write-Host "Git repository already exists."
#     $remoteUrl = git remote get-url origin -ErrorAction SilentlyContinue
#     if ($null -eq $remoteUrl) {
#         git remote add origin $myrepo
#     } elseif ($remoteUrl -ne $myrepo) {
#         git remote set-url origin $myrepo
#     }
#     $currentBranch = git rev-parse --abbrev-ref HEAD
#     if ($currentBranch -ne $sourceBranch) {
#         if (git branch --list $sourceBranch) {
#             git checkout $sourceBranch
#         } else {
#             git branch -M $sourceBranch
#         }
#     }
# }

# # --- Sync Obsidian to Hugo ---
# Write-Host "Syncing Obsidian posts to Hugo..."

# if (-not (Test-Path $sourcePath -PathType Container)) {
#     Write-Error "Source path does not exist: $sourcePath"
#     exit 1
# }
# if (-not (Test-Path $destinationPath -PathType Container)) {
#     New-Item -ItemType Directory -Force -Path $destinationPath
# }

# $robocopyOptions = @('/MIR', '/Z', '/W:5', '/R:3', '/NFL', '/NDL', '/NJH', '/NJS', '/NC', '/NS', '/NP')
# robocopy $sourcePath $destinationPath $robocopyOptions

# if ($LASTEXITCODE -ge 8) {
#     Write-Error "Robocopy failed with serious error code: $LASTEXITCODE"
#     exit 1
# } else {
#     Write-Host "Robocopy completed successfully."
# }

# # --- Process Images in Markdown Files ---
# Write-Host "Processing images in Markdown files..."

# $pythonScriptPath = Join-Path $ScriptDir "images.py"
# if (-not (Test-Path $pythonScriptPath)) {
#     Write-Error "Python script 'images.py' not found at: $pythonScriptPath"
#     exit 1
# }

# & $pythonCommand $pythonScriptPath
# Write-Host "Image processing complete."

# # --- Build Hugo Site ---
# Write-Host "Building Hugo site..."
# hugo --gc --minify

# if (-not (Test-Path "public" -PathType Container)) {
#     Write-Error "Hugo build completed, but 'public' directory not found."
#     exit 1
# }
# Write-Host "Hugo build completed."

# # --- Git Commit & Push Source ---
# Write-Host "Staging changes for Git..."
# git add .

# # Check if there are staged changes
# git diff --cached --quiet
# $hasStagedChanges = ($LASTEXITCODE -ne 0)

# if ($hasStagedChanges) {
#     $commitMessage = "Site update $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
#     Write-Host "Committing changes..."
#     git commit -m "$commitMessage"

#     Write-Host "Pushing to origin/$sourceBranch..."
#     $upstream = git rev-parse --abbrev-ref "$sourceBranch@{upstream}" -ErrorAction SilentlyContinue
#     if ($null -eq $upstream) {
#         git push -u origin $sourceBranch
#     } else {
#         git push origin $sourceBranch
#     }
# } else {
#     Write-Host "No staged changes to commit."
# }

# # --- Deploy Public Folder to GitHub Pages ---
# Write-Host "Deploying site to GitHub Pages branch..."

# $tempDeployBranch = "gh-pages-temp-deploy"

# if (git branch --list $tempDeployBranch) {
#     git branch -D $tempDeployBranch
# }

# git subtree split --prefix public -b $tempDeployBranch

# git push origin "$($tempDeployBranch):$ghPagesBranch" --force

# git branch -D $tempDeployBranch

# Write-Host "-----------------------------------------------------"
# if ($hasStagedChanges) {
#     Write-Host "Deployment complete! Changes pushed to '$sourceBranch' and '$ghPagesBranch'."
# } else {
#     Write-Host "Deployment complete! No source changes detected, but site deployed."
# }
# Write-Host "Check your GitHub Pages settings if this was the first deployment!"
# Write-Host "-----------------------------------------------------"

# PowerShell Script for Windows - Optimized for GitHub Pages

# Set variables for Obsidian to Hugo copy
$sourcePath = "G:\My Drive\blog\Blog"
$destinationPath = "C:\Users\TK-LPT-1025\Documents\nbin\blog\sshmeblog\content\archive"

# Set Github repo
$myrepo = "git@github.com:baeziy/sshmeblog.git" # Changed from https to ssh

# Set the target branch.  Use 'main' or 'master' as appropriate.
$targetBranch = "main" # Or "master"

# Set error handling
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Change to the script's directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $ScriptDir

# Check for required commands
$requiredCommands = @('git', 'hugo')

# Check for Python command (python or python3)
if (Get-Command 'py' -ErrorAction SilentlyContinue) {
    $pythonCommand = 'py'
} elseif (Get-Command 'python' -ErrorAction SilentlyContinue) {
    $pythonCommand = 'python'
} elseif (Get-Command 'python3' -ErrorAction SilentlyContinue) {
    $pythonCommand = 'python3'
} else {
    Write-Error "Python is not installed or not in PATH."
    exit 1
}

foreach ($cmd in $requiredCommands) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "$cmd is not installed or not in PATH."
        exit 1
    }
}

# Step 1: Check if Git is initialized, and initialize if necessary
if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git repository..."
    git init
    git remote add origin $myrepo
} else {
    Write-Host "Git repository already initialized."
    $remotes = git remote
    if (-not ($remotes -contains 'origin')) {
        Write-Host "Adding remote origin..."
        git remote add origin $myrepo
    }
    # Fetch latest changes
    Write-Host "Fetching latest changes from origin..."
    git fetch origin
    #switch to target branch
    Write-Host "Switching to target branch $targetBranch..."
    git checkout $targetBranch
}

# Step 2: Sync posts from Obsidian to Hugo content folder using Robocopy
Write-Host "Syncing posts from Obsidian..."

if (-not (Test-Path $sourcePath)) {
    Write-Error "Source path does not exist: $sourcePath"
    exit 1
}

if (-not (Test-Path $destinationPath)) {
    Write-Error "Destination path does not exist: $destinationPath"
    exit 1
}

# Use Robocopy to mirror the directories
$robocopyOptions = @('/MIR', '/Z', '/W:5', '/R:3')
$robocopyResult = robocopy $sourcePath $destinationPath @robocopyOptions

if ($LASTEXITCODE -ge 8) {
    Write-Error "Robocopy failed with exit code $LASTEXITCODE"
    exit 1
}

# Step 3: Process Markdown files with Python script to handle image links
Write-Host "Processing image links in Markdown files..."
if (-not (Test-Path "images.py")) {
    Write-Error "Python script images.py not found."
    exit 1
}

# Execute the Python script
try {
    & $pythonCommand images.py
} catch {
    Write-Error "Failed to process image links."
    exit 1
}

# Step 4: Build the Hugo site
Write-Host "Building the Hugo site..."
try {
    hugo
} catch {
    Write-Error "Hugo build failed."
    exit 1
}

# Step 5: Add changes to Git
Write-Host "Staging changes for Git..."
$hasChanges = (git status --porcelain) -ne ""
if (-not $hasChanges) {
    Write-Host "No changes to stage."
} else {
    git add .
}

# Step 6: Commit changes with a dynamic message
$commitMessage = "New Blog Post on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$hasStagedChanges = (git diff --cached --name-only) -ne ""
if (-not $hasStagedChanges) {
    Write-Host "No changes to commit."
} else {
    Write-Host "Committing changes..."
    git commit -m "$commitMessage"
}

# Step 7: Push all changes to the main branch
Write-Host "Pushing changes to $targetBranch branch..."
try {
    git push origin $targetBranch
} catch {
    Write-Error "Failed to push to $targetBranch branch."
    exit 1
}

# Step 8: Deploy the Hugo site to GitHub Pages
Write-Host "Deploying to GitHub Pages..."

# Option 1: Using the 'gh-pages' branch (Traditional Method)
# This method is more explicit and creates a separate 'gh-pages' branch
# which is good for clarity and maintaining a clean separation.
$deployBranch = "gh-pages" #changed from hostinger-deploy

# Check if the gh-pages branch exists and delete it
$branchExists = git branch --list "$deployBranch"
if ($branchExists) {
    Write-Host "Deleting existing $deployBranch branch..."
    git branch -D "$deployBranch"
}

# Create a new orphan branch
Write-Host "Creating orphan branch $deployBranch..."
git checkout --orphan "$deployBranch"

# Clean the branch
Write-Host "Cleaning $deployBranch branch..."
git rm -rf .

# Copy the contents of the Hugo 'public' directory to the root of the gh-pages branch
Write-Host "Copying Hugo output to $deployBranch branch..."
Copy-Item -Path "public\*" -Destination "." -Recurse -Force

# Add all files
Write-Host "Adding files to $deployBranch branch..."
git add .

# Commit the changes
Write-Host "Committing changes to $deployBranch branch..."
git commit -m "Deploying to GitHub Pages"

# Push the changes to the 'gh-pages' branch
Write-Host "Pushing $deployBranch branch to origin..."
try {
    git push origin "$deployBranch" --force
} catch {
    Write-Error "Failed to push $deployBranch branch."
    exit 1
}

# Switch back to the main branch
Write-Host "Switching back to $targetBranch branch..."
git checkout "$targetBranch"

Write-Host "Successfully deployed to GitHub Pages!"
Write-Host "Your site is available at: https://$(git config --get user.name).github.io/$(git rev-parse --show-toplevel | Split-Path -Leaf)/"
