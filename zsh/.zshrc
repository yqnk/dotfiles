#   env -> history -> options -> keybinds -> completion -> plugins
#   -> aliases -> functions -> tool init (zoxide needs compinit, and
#   zsh-syntax-highlighting must be sourced last).

# env

export EDITOR="nvim"
export VISUAL="$EDITOR"
export PAGER="less"
export LESS="-R"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
export ICONS="$HOME/.local/share/icons"
export WALLPAPERS="$HOME/.local/share/wallpapers"

export GOPATH="$HOME/.go"
export CMAKE_GENERATOR=Ninja
export CMAKE_EXPORT_COMPILE_COMMANDS=ON

export LS_COLORS="ow=01;37:di=01;37:ex=01;32:*.png=01;33:*.svg=01;33:*.jpeg=01;33:*.jpg=01;33"

# pfetch
export PF_INFO="ascii title os kernel shell wm uptime pkgs memory"
export PF_COL1=6   # title
export PF_COL2=9   # info data
export PF_COL3=4   # info names

# PATH -- typeset -U keeps it free of duplicates across re-sources
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/.opam/default/bin"
  "$HOME/.local/share/nvim/mason/bin"
  "$HOME/.altera_lite/25.1std/quartus/bin"
  $path
)

# history

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# shell options

setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NUMERIC_GLOB_SORT
setopt INTERACTIVE_COMMENTS
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
DIRSTACKSIZE=20

unsetopt BEEP
unsetopt FLOW_CONTROL

# keybinds
# `zle -al`

bindkey -e
bindkey "^[[3~"    delete-char
bindkey "^[[3;5~"  delete-word
bindkey "^[[1;5C"  forward-word
bindkey "^[[1;5D"  backward-word
bindkey '^H'       backward-kill-word
bindkey '^R'       history-incremental-search-backward

# completion

zmodload zsh/complist
autoload -U compinit && compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

setopt AUTO_MENU
setopt ALWAYS_TO_END
setopt COMPLETE_IN_WORD
setopt AUTO_PARAM_SLASH
setopt GLOB_COMPLETE
unsetopt MENU_COMPLETE

zstyle ':completion:*' verbose yes
zstyle ':completion:*' extra-verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
zstyle ':completion:*' list-separator '--'
zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format '%F{cyan}%B-- %d --%b%f'
zstyle ':completion:*:messages'     format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings'     format '%F{red}-- no match: %d --%f'
zstyle ':completion:*:corrections'  format '%F{yellow}-- %d (errors: %e) --%f'

zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>3?3:($#PREFIX+$#SUFFIX)/3))numeric)'

# ordering and colors
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# per-command tweaks
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:processes'       command 'ps -u $USER -o pid,user,comm -w'
zstyle ':completion:*:processes-names' command 'ps -u $USER -o comm='
zstyle ':completion:*:(ssh|scp|sftp):*' group-order users hosts
zstyle ':completion:*:(rm|cp|mv|kill|diff):*' ignore-line other
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# cache the slow ones (pacman & co)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# inside the completion menu
bindkey -M menuselect '^[[Z' reverse-menu-complete
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect '^[' send-break

bindkey '^Xh' _complete_help

# plugins

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#4a4a4a'

# aliases

alias ls='ls --color=auto -F'
alias la='ls -a'
alias tree='tree -F'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias rg='rg --color=auto'
alias ip='ip -c=auto'

alias n='nvim'
alias nv='nvim'
alias nvi='nvim'
alias py='python3'
alias cls='clear'
alias tmp='cd /tmp'
alias zen='zen-browser'
alias ..='cd ..'
alias asciiquarium='asciiquarium -t -s'
alias wf-recorder="$XDG_CONFIG_HOME/hypr/rec.sh"
alias shift_srt='python3 ~/projects/shift_srt.py'

# alias de terroriste
alias cd='z'
alias cdi='zi'

# functions

mkcd() {
  mkdir -p "$1" && cd "$1"
}

mvcd() {
  mv "$1" "$2" && cd "$2"
}

opti() {
  echo 'pour opti, cpupower pour set la freq cpu et tlp power-saver/perf'
}

mountafs() {
  echo "Warning: you may need a new ticket: kinit -f LOGIN@CRI.EPITA.FR"
  cd || return
  mkdir -p afs
  sshfs -o reconnect xavier.login@ssh.cri.epita.fr:/afs/cri.epita.fr/user/y/ya/login/u/ afs
  cd afs
}

umountafs() {
  cd || return
  umount afs
}

airpods() {
  local mac=F0:D3:1F:79:DA:27
  case $1 in
    on)     echo "Connecting AirPods...";    bluetoothctl connect "$mac" ;;
    off)    echo "Disconnecting AirPods..."; bluetoothctl disconnect "$mac" ;;
    forget) echo "Forgetting AirPods...";    bluetoothctl remove "$mac" ;;
    *)      echo "Usage: airpods [on|off|forget]" ;;
  esac
}

# $1 = number of empty commits, rest = message
fakeCommit() {
  local commits="$1"
  shift
  for i in $(seq 1 "$commits"); do
    git commit --allow-empty -m "$* ($i)"
  done
}

# collapse runs of identical input lines into "line (xN)" once the run
# reaches $1 repetitions; shorter runs are printed as-is
pack() {
  local threshold=$1
  local prev=""
  local count=0

  flush() {
    if [[ $count -ge $threshold ]]; then
      echo "$prev (x$count)"
    else
      for ((i = 0; i < count; i++)); do
        echo "$prev"
      done
    fi
  }

  while IFS= read -r line; do
    if [[ "$line" == "$prev" ]]; then
      ((count++))
    else
      flush
      prev="$line"
      count=1
    fi
  done
  flush

  unfunction flush
}

# tool init

source "$HOME/.cargo/env"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# syntax highlighting must be sourced last
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#b294bb'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#b294bb,underline'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#b294bb,underline'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#b294bb'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#b5bd68'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#b5bd68'
