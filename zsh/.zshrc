# global variables
export STARSHIP_CONFIG="/home/yan/.config/starship/starship.toml"
export ICONS="/home/yan/.local/share/icons"
export WALLPAPERS="/home/yan/.local/share/wallpapers"
export LS_COLORS="ow=01;37:di=01;37:ex=01;32:*.png=01;33:*.svg=01;33:*.jpeg=01;33:*.jpg=01;33"
export PATH="$PATH:/home/yan/.opam/default/bin:/home/yan/.local/share/nvim/mason/bin:/home/yan/.altera_lite/25.1std/quartus/bin:/home/yan/.local/bin"
export GOPATH="/home/yan/.go"
export EDITOR="nvim"

export CMAKE_GENERATOR=Ninja
export CMAKE_EXPORT_COMPILE_COMMANDS=ON

#binds -- see command zle -al -- cat to find keycode
bindkey "^[[3~" delete-char
bindkey "^[[3;5~" delete-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey '^H' backward-kill-word
bindkey '^R' history-incremental-search-backward
# bindkey '^R' history-incremental-pattern-search-backward

# aliases
alias ls='ls --color=auto -F'
alias bat='bat --color=always'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip -c=auto'
alias tree='tree -F'
alias rg='rg --color=auto'
alias cls='clear'
alias py='python3'
alias asciiquarium='asciiquarium -t -s'
alias wf-recorder='~/.config/hypr/rec.sh'
alias tmp="cd /tmp"
alias nvi="nvim"
alias nv="nvim"
alias n="nvim"
alias zen="zen-browser"

# alias de terroriste
alias cd="z"
alias cdi="zi"

# custom commands

..() {
  cd ..
}

mvcd() {
  mv $1 $2 && cd $2
}

mkcd() {
    mkdir -p "$1" && cd "$1" || return
}

opti() {
    echo 'pour opti, cpupower pour set la freq cpu et tlp power-saver/perf'
}

mountafs() {
  echo "Warning: you may need a new ticket: kinit -f LOGIN@CRI.EPITA.FR"
  cd
  mkdir -p "afs"
  sshfs -o reconnect LOGIN@ssh.cri.epita.fr:/afs/cri.epita.fr/user/L/LO/LOGIN/u/ afs
  cd "afs"
}

umountafs() {
  cd
  umount afs
}

airpods() {
    case $1 in
        on)
            echo "Connecting AirPods..."
            bluetoothctl connect F0:D3:1F:79:DA:27
            ;;
        off)
            echo "Disconnecting AirPods..."
            bluetoothctl disconnect F0:D3:1F:79:DA:27
            ;;
        forget)
            echo "Forgetting AirPods..."
            bluetoothctl remove F0:D3:1F:79:DA:27
            ;;
        *)
            echo "Usage: airpods [on|off|forget]"
            ;;
    esac
}

chrono() { # $1 = slug
    start=$(date +%s)
    while true; do
        time="$(($(date +%s) - $start))"
        printf '%s - %s\r' "$*" "$(date -u -d "@$time" +%H:%M:%S)"
    done
}

fakeCommit() {
    COMMITS="$1"
    shift
    MESSAGE="$@"

    for i in $(seq 1 $COMMITS); do
        git commit --allow-empty -m "$MESSAGE ($i)"
    done
}

# $1 is the threshould
packlines() {
  local threshold=$1
  local prev=""
  local count=0

  while IFS= read -r line; do
    if [[ "$line" == "$prev" ]]; then
      ((count++))
    else
      if [[ $count -ge $threshold ]]; then
        echo "$prev (x$count)"
      else
        for ((i=0; i<count; i++)); do
          echo "$prev"
        done
      fi
      prev="$line"
      count=1
    fi
  done

  if [[ $count -ge $threshold ]]; then
    echo "$prev (x$count)"
  else
    for ((i=0; i<count; i++)); do
      echo "$prev"
    done
  fi
}

# pfetch variables
export PF_INFO="ascii title os kernel shell wm uptime pkgs memory"
export PF_COL3=4 # Color for info names
export PF_COL2=9 # Color for info data
export PF_COL1=6 # Color for title

autoload -U promptinit && promptinit=6

# unset
unsetopt beep # disable beep on completion when pressing TAB

# init starship
eval "$(starship init zsh)"

# source cargo env
source "$HOME/.cargo/env"

# zsh history
setopt SHARE_HISTORY
HISTFILE="/home/yan/.zsh_history"
SAVEHIST=5000
HISTSIZE=4999

# zsh plugins
# source "/usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#b294bb,underline'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#b294bb,underline'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#b294bb'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#b5bd68'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#b5bd68'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#b294bb'

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#4a4a4a'

# zsh completion
autoload -U compinit && compinit

# BEGIN need to be after compinit
# this adds 400ms of lag to zsh, might be wise to do it ONLY when needed.
# eval "$(pixi completion --shell zsh)" 
eval "$(zoxide init zsh)"
# END need to be after compinit

# [[ ! -r '/home/yan/.opam/opam-init/init.zsh' ]] || source '/home/yan/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null

# Added by Quartus Prime software
# export QSYS_ROOTDIR="/home/yan/.altera_lite/25.1std/quartus/sopc_builder/bin"
# export SALT_LICENSE_FILE="$SALT_LICENSE_FILE;/home/yan/.altera.quartus/questa_lic.dat"
