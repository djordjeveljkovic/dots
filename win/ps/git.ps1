# Git add all
function ga {
    git add .
}

# Git status
function gs {
    git status
}

# Git diff
function gd {
    git diff
}

# Git pull
function gpa {
    git pull
}

# Git create pull request (default into 'dev')
function gpr {
    param(
        [string]$BaseBranch = "dev"  # Default branch is 'dev'
    )
    gh pr create --base $BaseBranch
}

# Git push to origin or specified remote and branch
function gpo {
    param(
        [string]$Origin = "origin",  # Default remote is 'origin'
        [string]$Branch = $(git rev-parse --abbrev-ref HEAD)  # Default branch is the current branch
    )
    git push $Origin $Branch
}

# Git commit with a message
function gca {
    param(
        [string]$Message
    )

    if (-not $Message) {
        Write-Host "Usage: gca 'commit message'" -ForegroundColor Yellow
        return
    }

    git commit -am "$Message"
}

# Git branch management: create or switch branches
function gb {
    param(
        [string]$Branch
    )

    if (-not $Branch) {
        Write-Host "Usage: gb 'branch name'" -ForegroundColor Yellow
        return
    }

    # Check if the branch already exists
    $branchExists = git branch --list $Branch | ForEach-Object { $_.Trim() } | Where-Object { $_ -eq $Branch }

    if (-not $branchExists) {
        Write-Host "Branch '$Branch' does not exist. Creating and switching to it..." -ForegroundColor Green
        git checkout -b $Branch
    } else {
        Write-Host "Branch '$Branch' already exists. Switching to it..." -ForegroundColor Cyan
        git checkout $Branch
    }
}

