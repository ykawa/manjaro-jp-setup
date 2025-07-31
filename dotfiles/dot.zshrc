# Enhanced zsh configuration
# Created by setup script

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load Powerlevel10k theme
if [[ -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]]; then
    source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
else
    # Fallback to basic prompt if Powerlevel10k is not available
    autoload -U colors && colors
    PS1="%{$fg[green]%}[%n@%m %{$fg[blue]%}%~%{$fg[green]%}]%{$reset_color%}$ "
fi

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt appendhistory
setopt sharehistory
setopt incappendhistory
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify

# Directory navigation
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_silent

# Auto completion
autoload -Uz compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Completion styling
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'

# Load syntax highlighting
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Load autosuggestions
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
fi

# Load history substring search
if [[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
    # Bind keys for history substring search
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^P' history-substring-search-up
    bindkey '^N' history-substring-search-down
fi

# Key bindings
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Aliases
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Enhanced aliases if tools are available
if command -v exa >/dev/null 2>&1; then
    alias ll='exa -la'
    alias la='exa -a'
    alias tree='exa --tree'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# System aliases
alias pacs='yay -S'
alias pacss='yay -Ss'
alias pacr='yay -R'
alias pacu='yay -Syu'
alias pacq='yay -Q'

# Productivity aliases
alias py='python'
alias py3='python3'
alias vi='vim'
alias c='clear'
alias h='history'
alias j='jobs'

# Source additional configurations if they exist
[[ -f ~/.bashrc_additions ]] && source ~/.bashrc_additions

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH=$HOME/.nodebrew/current/bin:$PATH

# Input method configuration (fcitx5)
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# Load X11 key mappings if in X11 session
[ -n "$DISPLAY" ] && [ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap 2>/dev/null
