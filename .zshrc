#==============================================================================
#                         HARDIK'S ZSH CONFIGURATION
#==============================================================================

#------------------------------------------------------------------------------
# SSH Agent Setup (must be BEFORE instant prompt to avoid console output warning)
#------------------------------------------------------------------------------
# Set ksshaskpass so KDE wallet stores the SSH passphrase
export SSH_ASKPASS=/usr/bin/ksshaskpass
export SSH_ASKPASS_REQUIRE=prefer

# Start keychain and add SSH key (prompts for passphrase only once per boot)
eval $(keychain --eval --quiet --agents ssh id_rsa 2>/dev/null)

#------------------------------------------------------------------------------
# Powerlevel10k Instant Prompt
#------------------------------------------------------------------------------
# Enable Powerlevel10k instant prompt for faster shell loading
# Keep this at the top of ~/.zshrc for best performance
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#------------------------------------------------------------------------------
# Oh My Zsh Configuration
#------------------------------------------------------------------------------
# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set Powerlevel10k as the theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Load plugins - carefully selected for performance and utility
plugins=(
  git                     # Git integration and status
  zsh-syntax-highlighting # Command syntax highlighting
  colored-man-pages       # Colorized man pages
  zsh-fzf-history-search  # Fuzzy search through command history
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

#------------------------------------------------------------------------------
# Development Environment Setup
#------------------------------------------------------------------------------
# Clean, organized PATH with no duplicates
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH="$HOME/.local/bin:$HOME/git_scripts:$HOME/.zellij:$DENO_INSTALL/bin:$NVM_DIR/versions/node/v22.17.0/bin:/opt/mw-agent/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.local/share/JetBrains/Toolbox/scripts:$GOROOT/bin:$GOPATH/bin"

# Node Version Manager (lazy-loaded for fast startup)
export NVM_DIR="$HOME/.nvm"
# node/npm/npx work immediately via the hardcoded PATH above.
# nvm itself is lazy-loaded on first use.
nvm() {
  unfunction nvm
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
  nvm "$@"
}

# Deno setup
export DENO_INSTALL="$HOME/.deno"

# Cargo environment
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# pnpm
export PNPM_HOME="/home/hardik/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export KUBECONFIG="$HOME/.kube/config:$HOME/work/kubeconfigs/mw-beta-rke-ovh.yaml:$HOME/work/kubeconfigs/sandbox-k8s-kubeconfig.yaml:$HOME/work/kubeconfigs/kind-agent-team-lab.yaml"

export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
#------------------------------------------------------------------------------
# Prompt Configuration
#------------------------------------------------------------------------------
# Powerlevel10k configuration
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Fallback prompt in case powerlevel10k is not loaded
PS1='\[\e[1;97m\][\[\e[38;5;10m\]\u\[\e[38;5;10m\]@\[\e[38;5;10m\]\h\[\e[1;97m\] \[\e[1;97m\]\W\[\e[1;97m\]]:\[\e[0m\] '

fpath+=${ZDOTDIR:-~}/.zsh_functions

#----------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias 'lz=lazydocker'
alias 'mw=cd ~/work/mw'
alias 'bf=code ~/work/mw/middleware/bifrost'
alias 'cbf=cursor ~/work/mw/middleware/bifrost'
alias 'aes=cursor /home/hardik/work/mw/agent-ecosystem'
alias 'k=kubectl'
alias bpftool="/usr/lib/linux-tools/6.8.0-87-generic/bpftool"
# alias perf="/usr/lib/linux-tools/6.8.0-87-generic/perf"
alias f="yazi"
alias 'bat=batcat'
alias 'hex=dz6'
alias 'cb=xclip -selection clipboard'

# bun completions
[ -s "/home/hardik/.bun/_bun" ] && source "/home/hardik/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# opencode
export PATH=/home/hardik/.opencode/bin:$PATH

# aider -> local ollama
export OLLAMA_API_BASE=http://127.0.0.1:11434
