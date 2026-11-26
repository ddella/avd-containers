#!/bin/zsh

# https://github.com/ohmyzsh/ohmyzsh/

### Change the Theme
# https://github.com/ohmyzsh/ohmyzsh/wiki/themes
# sed -i "s/^ZSH_THEME=.*/ZSH_THEME=philips/" ~/.zshrc
# sed -i "s/^ZSH_THEME=.*/ZSH_THEME=robbyrussell/" ~/.zshrc

### Apply the custom Zsh prompt and remove the right prompt
# cat << 'EOF' >> ~/.zshrc
# ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} %{%G✚%}"
# ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} %{%G✹%}"
# ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} %{%G✖%}"
# ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} %{%G➜%}"
# ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} %{%G═%}"
# ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} %{%G✭%}"

# PROMPT='%{$fg[blue]%}%B%c/%b%{$reset_color%} $(git_prompt_info)%(!.#.$) '
# RPROMPT=''
# EOF

# The timezone (TZ) and AGE_PRIVATE_KEY are set in "containerEnv" in devcontainer.json.
# To list the valid timezone names: find /usr/share/zoneinfo/ -type f

git config --global devcontainers-theme.show-dirty 1


exit 0
