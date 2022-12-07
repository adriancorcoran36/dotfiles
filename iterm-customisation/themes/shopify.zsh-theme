PROMPT='
$(dir_path) $(git_info)

$(prompt)$reset_color '

RPROMPT=''

# auto suggestion plugin color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#50248F"

# -------------------------------------------------------

# Show the prompt
function prompt () {
  echo -en "%F{#9C6ADE}❯%F{#E3D0FF}❯%F{#F6F0FD}❯%f "
}

# Get the current directory, truncate it, and make it blue
function dir_path () {
  echo -en "%F{cyan}➜ /%c%{$reset_color%}"
}

# git information on git
function git_info () {
  # return nothing if we're not in a git repo
  ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 && return
  # start string
  local GIT_INFO=""
  # git location
  GIT_INFO+=$(git_location)
  # git untracked
  GIT_INFO+=$(git_untracked)
  # git uncommitted
  GIT_INFO+=$(git_uncommitted)
  # git staged
  GIT_INFO+=$(git_staged)
  # git clean
  GIT_INFO+=$(git_clean)
  # git position
  GIT_INFO+=$(git_position)
  # echo string
  echo "$GIT_INFO"
}

# Git branch/tag, or name-rev if on detached head, or nothing if not in repo
function git_location() {
  local GIT_LOCATION=${$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD)#(refs/heads/|tags/)}
  echo "%{$fg[magenta]%}($GIT_LOCATION)%{$reset_color%} "
}

# Does the branch have untracked files
function git_untracked() {
  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    echo "%{$fg[blue]%}●%{$reset_color%}"
  fi
}

# Does the branch have uncommitted files
function git_uncommitted() {
  if ! git diff --quiet 2> /dev/null; then
    echo "%{$fg[red]%}●%{$reset_color%}"
  fi
}

# Does the branch have staged files
function git_staged() {
  if ! git diff --cached --quiet 2> /dev/null; then
    echo "%{$fg[yellow]%}●%{$reset_color%}"
  fi
}

# Is the branch clean?
function git_clean() {
  local statusCheck=$(git status 2> /dev/null)
    if [[ $statusCheck =~ 'working tree clean' ]]; then
      echo "%{$fg[green]%}●%{$reset_color%}"
    fi
}

# Are we ahead / behind / up to date?
function git_position() {
  local BEHIND="%{$fg[red]%}⇣NUM%{$reset_color%}"
  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  local AHEAD="%{$fg[green]%}⇡NUM%{$reset_color%}"
  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    echo " ${BEHIND//NUM/$NUM_BEHIND}"
  elif [ "$NUM_AHEAD" -gt 0 ]; then
    echo " ${AHEAD//NUM/$NUM_AHEAD}"
  else
    echo " %{$fg[green]%}±0%{$reset_color%}"
  fi
}