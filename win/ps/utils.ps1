# Open Neovim with the profile
function np {
    nvim $PROFILE
}

# Navigate to Neovim configuration directory
function pnv {
    cd ~\AppData\Local\nvim
}

# Source the PowerShell profile
function source {
    . $PROFILE
}
