# --- Git prompt ---
source ~/.git-prompt.sh

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWCOLORHINTS=1
GIT_PS1_DESCRIBE_STYLE="branch"

autoload -Uz add-zsh-hook
_set_git_prompt() { __git_ps1 "%F{green}%n%f %B%(?.%F{green}.%F{red})➜%f%b %B%F{blue}%~%f%b" " $ " " (%s)" }
add-zsh-hook precmd _set_git_prompt
