# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#---------------------------------------------------------------
# Bash options
#---------------------------------------------------------------

PS1='┌─[$PWD]\n└─╼ '

shopt -s autocd
shopt -s expand_aliases
shopt -s cdspell
shopt -s progcomp

unset HISTFILESIZE
HISTSIZE="1000000000000000"
export HISTCONTROL=ignoreboth:erasedups
PROMPT_COMMAND="history -a; history -c; history -r"
export HISTSIZE PROMPT_COMMAND

export EDITOR='vim'
export IMAGE_VIEWER='sxiv'
source /usr/share/doc/pkgfile/command-not-found.bash

#---------------------------------------------------------------
# Bash completion
#---------------------------------------------------------------

set show-all-if-ambiguous on
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

#---------------------------------------------------------------
# Aliases 
#---------------------------------------------------------------
alias sxiv='sxiv -a'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias pacman='sudo pacman --color always'
alias ls='clear && ls --color=auto'
alias rm='rm -i -v'
alias ping='ping -c 5'
alias du='du -c -h'
alias mkdir='mkdir -p -v'
alias clea='clear; echo "correcting clea to clear"'
alias wifi="nmtui"
alias youtube="youtube-dl --title --no-overwrites --continue --write-description"
alias ffp="sudo systemctl start polipo && firefox; exit"
alias main='grep -rni "main(" * ; grep -rni "main (" *'
alias dus='sudo du --human-readable --max-depth=1 | sort --human-numeric-sort'
alias +x='chmod +x'
alias loc='cloc'
alias connect_monitors="xrandr --output DP2 --auto --left-of HDMI1 --output HDMI1 --auto --above eDP1"
alias disconnect_monitors="xrandr --auto"

#---------------------------------------------------------------
# Functions
#---------------------------------------------------------------

function secure_chromium {
    port=4711
    chromium --proxy-server="socks://localhost:$port" &
    exit
}

extract() { 
    if [ -f $1 ] ; then 
      case $1 in 
        *.tar.bz2)   tar xjf $1     ;; 
        *.tar.gz)    tar xzf $1     ;; 
        *.bz2)       bunzip2 $1     ;; 
        *.rar)       unrar e $1     ;; 
        *.gz)        gunzip $1      ;; 
        *.tar)       tar xf $1      ;; 
        *.tbz2)      tar xjf $1     ;; 
        *.tgz)       tar xzf $1     ;; 
        *.zip)       unzip $1       ;; 
        *.Z)         uncompress $1  ;; 
        *.7z)        7z x $1        ;; 
        *)     echo "'$1' cannot be extracted via extract()" ;; 
         esac 
     else 
         echo "'$1' is not a valid file" 
     fi 
}

