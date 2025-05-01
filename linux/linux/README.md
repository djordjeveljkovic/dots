# Arch Linux Setup Script

This repository contains a script (`install.sh`) to automate the installation of various packages and tools for a development and desktop environment on an Arch-based Linux distribution. It includes battery optimization tools, essential applications, utilities, development tools (Neovim, PHP, Go, Node.js), the Sway window manager, fonts, and Zsh with Oh My Zsh and Powerlevel10k.

## Prerequisites

* An Arch Linux-based distribution.
* `sudo` privileges.
* `git` installed (`sudo pacman -S git`).
* `base-devel` package group installed (for building AUR packages like `yay`) (`sudo pacman -S --needed base-devel`).
* An active internet connection.

## Script Overview

The `install.sh` script performs the following actions:

1.  **Installs Yay:** Clones the `yay` AUR helper repository, builds, and installs it. `yay` is then used for installing AUR packages.
2.  **Installs Battery Management Tools:** Installs `tlp`, `smartmontools`, `laptop-mode-tools`, `powertop`, and `ethtool`. Enables the `tlp` service for power saving.
3.  **Installs Alacritty Image Viewer:** Installs `ueberzugpp` for image previews in terminals like Alacritty (often used with file managers like `yazi`).
4.  **Installs Applications:** Installs common applications like `imagemagick`, `7zip`, `gimp`, `yazi`, `alacritty`, `git`, `feh`, `qbittorrent`, `unzip`, `tmux`, and `google-chrome` (from AUR).
5.  **Installs Utilities:** Installs system utilities like `bluez` (Bluetooth stack), `bluez-utils`, `brightnessctl`, `grim` (screenshot tool), `mpv` (media player), `skim` (fuzzy finder), `slurp` (region selection for screenshots), and `make`.
6.  **Installs Neovim & Development Tools:** Installs `neovim`, `cmake`, `go`, `lazygit`, `sed`, `fzf`, `nodejs`, `npm`, `openssh`, `stylua`, and `ripgrep`.
7.  **Installs PHP Tools:** Installs `composer`.
8.  **Installs Sway Window Manager:** Installs `sway`, `swaybg`, `swayidle`, `swaylock`, `swaync` (notification center), `waybar`, `wayland-protocols`, and `wl-clipboard`.
9.  **Installs Fonts:** Installs Nerd Fonts (`ttf-ubuntu-nerd`, `ttf-dejavu-nerd`, `ttf-firacode-nerd`) often used for terminal icons and themes.
10. **Installs and Configures Zsh:**
    * Installs `zsh`.
    * Installs Oh My Zsh using the official script (Note: This step might be interactive).
    * Installs the Powerlevel10k theme using `yay`.
    * Changes the default shell to Zsh for the current user (requires password).

## Usage

1.  **Clone the repository or download the files.**
2.  **Make the script executable:**
    ```bash
    chmod +x install.sh
    ```
3.  **Run the script:**
    ```bash
    ./install.sh
    ```

    You will be prompted for your `sudo` password multiple times during the installation process. The Oh My Zsh installation might also require user interaction. The `chsh` command to change the default shell will also likely prompt for your password.

## Notes

* Wallpaper git repository
```
git clone --filter=blob:none --no-checkout --depth 1 --sparse https://github.com/dharmx/walls.git
cd walls
git sparse-checkout add <folder_name>
git ls-tree -d --name-only HEAD
git checkout
```
* The script uses `sudo pacman -S --noconfirm --needed` to install official repository packages non-interactively and avoid reinstalling existing packages.
* The script uses `yay -S --noconfirm` to install AUR packages non-interactively where possible.
* Review the script before running it to ensure you understand the packages being installed and the commands being executed.
* It's recommended to run this on a fresh Arch Linux installation or be aware of potential conflicts with existing configurations.
* After the script finishes and you log in again (or start a new Zsh session), the Powerlevel10k configuration wizard (`p10k configure`) should run automatically. If not, you can run it manually.
