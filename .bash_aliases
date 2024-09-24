# LS and Color Commands
alias ls='ls -h --color=auto'
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

# GIT Commands
alias gits='git status'
alias gitam='git commit -am'
alias gitull='git pull'
alias gitush='git push'
alias gitb='git checkout -b'
alias gitc='git checkout'
alias gitclean='git rm -r --cached .'

# Shortcuts
alias proj='cd /home/$USER/projects/'

# Environment
alias python='python3'