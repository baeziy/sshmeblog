# --- Configuration ---
$sourcePath = "G:\My Drive\blog\Blog" # <-- UPDATE THIS
$destinationPath = "C:\Users\TK-LPT-1025\Documents\nbin\blog\sshmeblog\content\archive" # <-- UPDATE THIS
$myrepo = "git@github.com:baeziy/sshmeblog.git" # <-- Your GitHub repository
$sourceBranch = "main"
$ghPagesBranch = "gh-pages"
# --- End Configuration ---

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Set current directory to script location
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $ScriptDir
Write-Host "Running script in: $(Get-Location)"

# Check required commands
$requiredCommands = @('git', 'hugo', 'robocopy')
foreach ($cmd in $requiredCommands) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "$cmd is not installed or not found in PATH."
        exit 1
    }
}

# Check Python command
if (Get-Command 'py' -ErrorAction SilentlyContinue) {
    $pythonCommand = 'py'
} elseif (Get-Command 'python' -ErrorAction SilentlyContinue) {
    $pythonCommand = 'python'
} elseif (Get-Command 'python3' -ErrorAction SilentlyContinue) {
    $pythonCommand = 'python3'
} else {
    Write-Error "Python is not installed or not found in PATH."
    exit 1
}
Write-Host "Using Python command: $pythonCommand"

# --- Git Setup ---
if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git repository..."
    git init
    git branch -M $sourceBranch
    git remote add origin $myrepo
} else {
    Write-Host "Git repository already exists."
    $remoteUrl = git remote get-url origin -ErrorAction SilentlyContinue
    if ($null -eq $remoteUrl) {
        git remote add origin $myrepo
    } elseif ($remoteUrl -ne $myrepo) {
        git remote set-url origin $myrepo
    }
    $currentBranch = git rev-parse --abbrev-ref HEAD
    if ($currentBranch -ne $sourceBranch) {
        if (git branch --list $sourceBranch) {
            git checkout $sourceBranch
        } else {
            git branch -M $sourceBranch
        }
    }
}

# --- Sync Obsidian to Hugo ---
Write-Host "Syncing Obsidian posts to Hugo..."

if (-not (Test-Path $sourcePath -PathType Container)) {
    Write-Error "Source path does not exist: $sourcePath"
    exit 1
}
if (-not (Test-Path $destinationPath -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $destinationPath
}

$robocopyOptions = @('/MIR', '/Z', '/W:5', '/R:3', '/NFL', '/NDL', '/NJH', '/NJS', '/NC', '/NS', '/NP')
robocopy $sourcePath $destinationPath $robocopyOptions

if ($LASTEXITCODE -ge 8) {
    Write-Error "Robocopy failed with serious error code: $LASTEXITCODE"
    exit 1
} else {
    Write-Host "Robocopy completed successfully."
}

# --- Process Images in Markdown Files ---
Write-Host "Processing images in Markdown files..."

$pythonScriptPath = Join-Path $ScriptDir "images.py"
if (-not (Test-Path $pythonScriptPath)) {
    Write-Error "Python script 'images.py' not found at: $pythonScriptPath"
    exit 1
}

& $pythonCommand $pythonScriptPath
Write-Host "Image processing complete."

# --- Build Hugo Site ---
Write-Host "Building Hugo site..."
hugo --gc --minify

if (-not (Test-Path "public" -PathType Container)) {
    Write-Error "Hugo build completed, but 'public' directory not found."
    exit 1
}
Write-Host "Hugo build completed."

# --- Git Commit & Push Source ---
Write-Host "Staging changes for Git..."
git add .

# Check if there are staged changes
git diff --cached --quiet
$hasStagedChanges = ($LASTEXITCODE -ne 0)

if ($hasStagedChanges) {
    $commitMessage = "Site update $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host "Committing changes..."
    git commit -m "$commitMessage"

    Write-Host "Pushing to origin/$sourceBranch..."
    $upstream = git rev-parse --abbrev-ref "$sourceBranch@{upstream}" -ErrorAction SilentlyContinue
    if ($null -eq $upstream) {
        git push -u origin $sourceBranch
    } else {
        git push origin $sourceBranch
    }
} else {
    Write-Host "No staged changes to commit."
}

# --- Deploy Public Folder to GitHub Pages ---
Write-Host "Deploying site to GitHub Pages branch..."

$tempDeployBranch = "gh-pages-temp-deploy"

if (git branch --list $tempDeployBranch) {
    git branch -D $tempDeployBranch
}

git subtree split --prefix public -b $tempDeployBranch

git push origin "$($tempDeployBranch):$ghPagesBranch" --force

git branch -D $tempDeployBranch

Write-Host "-----------------------------------------------------"
if ($hasStagedChanges) {
    Write-Host "Deployment complete! Changes pushed to '$sourceBranch' and '$ghPagesBranch'."
} else {
    Write-Host "Deployment complete! No source changes detected, but site deployed."
}
Write-Host "Check your GitHub Pages settings if this was the first deployment!"
Write-Host "-----------------------------------------------------"
