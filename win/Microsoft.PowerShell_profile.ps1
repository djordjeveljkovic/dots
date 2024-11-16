function np {nvim $PROFILE}
function pnv {cd ~\AppData\Local\nvim}
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
function gb {
    param(
        [string]$branch
    )
    if (-not $branch) {
        Write-Host "Usage: gb 'branch name'" -ForegroundColor Yellow
        return
    }

    # Check if the branch already exists
    $branchExists = git branch --list $branch | ForEach-Object { $_.Trim() } | Where-Object { $_ -eq $branch }

    if (-not $branchExists) {
        Write-Host "Branch '$branch' does not exist. Creating and switching to it..." -ForegroundColor Green
        git checkout -b $branch
    } else {
        Write-Host "Branch '$branch' already exists. Switching to it..." -ForegroundColor Cyan
        git checkout $branch
    }
}
oh-my-posh init pwsh --config ~/AppData/Roaming/ohmyposh/catppuccin_frappe.omp.json | Invoke-Expression
