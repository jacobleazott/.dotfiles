# LS and Color Commands
alias ls='ls -h --group-directories-first --color=auto'
alias ll='ls -lF'
alias la='ls -la'
alias lrt='ls -lrt'
alias dir='dir --color=auto'
alias grep='grep --color=auto'

# Helpers
alias psaux='ps aux | grep $USER'
alias disk='du -h --max-depth=1 | sort -hr'
alias rcp='rsync -ah --progress'
alias findg='find . | grep'
alias venv='source .venv/bin/activate'
alias scphere='echo $USER@$HOSTNAME:$PWD'

# GIT Commands
alias gits='git status'
alias gitam='git commit -am'
alias gitull='git pull'
alias gitush='git push'
alias gitb='git checkout -b'
alias gitc='git checkout'
alias gitclean='git rm -r --cached .'
alias gitdiff='git diff --stat $(git merge-base HEAD ${1:-main})'

# Shortcuts
alias proj='cd /home/$USER/projects/'
alias dock='cd /home/$USER/homelab/docker'

# Environment
alias python='python3'
alias pythonsrc='export PYTHONPATH=$(pwd)/src:$PYTHONPATH'

# Docker
alias ddown='docker compose down'
alias dup='docker compose up -d'
alias dres='ddown && dup'
