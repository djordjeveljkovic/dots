#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting Arch Linux Setup Script..."

# --- Prerequisites Check (Optional but Recommended) ---
echo "Checking for prerequisites (git, base-devel)..."
if ! command -v git &> /dev/null; then
    echo "git could not be found. Please install git first."
    echo "Example: sudo pacman -S git"
    exit 1
fi
if ! pacman -Q base-devel &> /dev/null; then
    echo "base-devel group not found. Please install it first."
    echo "Example: sudo pacman -S --needed base-devel"
    # Optionally install it automatically:
    # echo "Attempting to install base-devel..."
    # sudo pacman -S --noconfirm --needed base-devel || { echo "Failed to install base-devel. Exiting."; exit 1; }
    exit 1 # Remove this if you uncomment the automatic installation
fi
echo "Prerequisites met."

# --- Install Yay (AUR Helper) ---
echo "Installing Yay AUR Helper..."
if ! command -v yay &> /dev/null; then
    echo "Yay not found. Cloning and installing..."
    cd /tmp # Navigate to a temporary directory
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm # Build and install yay, non-interactive
    cd .. # Go back to /tmp
    rm -rf yay # Clean up cloned directory
    echo "Yay installed successfully."
else
    echo "Yay is already installed."
fi

# --- Update System and AUR packages ---
echo "Updating system and AUR packages with yay..."
yay -Syu --noconfirm

# --- Battery Related Packages ---
echo "Installing battery related packages..."
sudo pacman -S --noconfirm --needed tlp smartmontools laptop-mode-tools powertop ethtool
echo "Enabling tlp service..."
sudo systemctl enable tlp.service
sudo systemctl start tlp.service # Start it immediately as well

# --- Alacritty Image Drawer ---
echo "Installing ueberzugpp for Alacritty image previews..."
sudo pacman -S --noconfirm --needed ueberzugpp

# --- Applications ---
echo "Installing applications..."
sudo pacman -S --noconfirm --needed imagemagick p7zip gimp yazi alacritty git feh qbittorrent unzip tmux unzip
echo "Installing Google Chrome from AUR..."
yay -S --noconfirm google-chrome

# --- Utilities ---
echo "Installing utilities..."
sudo pacman -S --noconfirm --needed bluez bluez-utils brightnessctl grim mpv skim slurp make

# --- Neovim & Development Tools ---
echo "Installing Neovim and development tools..."
sudo pacman -S --noconfirm --needed neovim cmake go lazygit sed fzf nodejs npm openssh stylua ripgrep

# --- PHP ---
echo "Installing PHP Composer..."
sudo pacman -S --noconfirm --needed composer

# --- Sway Window Manager ---
echo "Installing Sway and related packages..."
sudo pacman -S --noconfirm --needed sway swaybg swayidle swaylock swaync waybar wayland-protocols wl-clipboard

# --- Fonts ---
echo "Installing Nerd Fonts..."
sudo pacman -S --noconfirm --needed ttf-ubuntu-nerd ttf-dejavu-nerd ttf-firacode-nerd

# --- Zsh & Configuration ---
echo "Installing Zsh..."
sudo pacman -S --noconfirm --needed zsh

# Install Oh My Zsh (Note: This might be interactive)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    # Attempt non-interactive install, falling back to the standard one if needed
    # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || \
    CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh already installed."
fi

# Install Powerlevel10k Theme
echo "Installing Zsh Powerlevel10k theme..."
yay -S --noconfirm zsh-theme-powerlevel10k-git
# Add p10k theme to .zshrc if not already present
ZSHRC_FILE="$HOME/.zshrc"
P10K_THEME_LINE='source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme'
if [ -f "$ZSHRC_FILE" ] && ! grep -qF "$P10K_THEME_LINE" "$ZSHRC_FILE"; then
    echo "Adding Powerlevel10k theme to $ZSHRC_FILE..."
    echo -e "\n# Theme configuration (Powerlevel10k)" >> "$ZSHRC_FILE"
    echo "$P10K_THEME_LINE" >> "$ZSHRC_FILE"
    # Trigger p10k configure automatically on next Zsh start if .p10k.zsh doesn't exist
    P10K_CONFIG_LINE='[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh'
     if ! grep -qF "$P10K_CONFIG_LINE" "$ZSHRC_FILE"; then
        echo "$P10K_CONFIG_LINE" >> "$ZSHRC_FILE"
     fi
else
    echo "Powerlevel10k theme already configured or $ZSHRC_FILE not found."
fi


# Change default shell to Zsh (Requires password)
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to Zsh for user $USER..."
    echo "You might be prompted for your password."
    chsh -s $(which zsh)
else
    echo "Default shell is already Zsh."
fi

echo "-------------------------------------"
echo "Installation script finished!"
echo "-------------------------------------"
echo "Notes:"
echo "- Please log out and log back in or reboot for all changes (like the default shell) to take effect."
echo "- If this is the first time using Powerlevel10k, its configuration wizard should start automatically when you open a new Zsh terminal. If not, run 'p10k configure'."
echo "- You may need to configure Bluetooth services manually (e.g., sudo systemctl enable --now bluetooth.service)."
echo "- Remember to configure Sway, Waybar, Alacritty, Neovim, etc., according to your preferences."

