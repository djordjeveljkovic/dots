# Do not override TERM: terminal applications rely on the value set by the
# terminal emulator. GREP_OPTIONS is deprecated by GNU grep; configure color
# through GREP_COLORS and an interactive alias instead.
export GREP_COLORS='mt=1;32'
alias grep='grep --color=auto'
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# Keep these as prompt-escaped values. The \[ and \] markers tell Readline
# that the color sequences do not occupy columns on screen.
COLOR_NC='\[\e[0m\]'
COLOR_BLACK='\[\e[0;30m\]'
COLOR_GRAY='\[\e[1;30m\]'
COLOR_RED='\[\e[0;31m\]'
COLOR_LIGHT_RED='\[\e[1;31m\]'
COLOR_GREEN='\[\e[0;32m\]'
COLOR_LIGHT_GREEN='\[\e[1;32m\]'
COLOR_BROWN='\[\e[0;33m\]'
COLOR_YELLOW='\[\e[1;33m\]'
COLOR_BLUE='\[\e[0;34m\]'
COLOR_LIGHT_BLUE='\[\e[1;34m\]'
COLOR_PURPLE='\[\e[0;35m\]'
COLOR_LIGHT_PURPLE='\[\e[1;35m\]'
COLOR_CYAN='\[\e[0;36m\]'
COLOR_LIGHT_CYAN='\[\e[1;36m\]'
COLOR_LIGHT_GRAY='\[\e[0;37m\]'
COLOR_WHITE='\[\e[1;37m\]'
