# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# if powerline is installed, then use it
command -v powerline-daemon &>/dev/null
if [ $? -eq 0 ]; then
    powerline-daemon -q
    POWERLINE_BASH_CONTINUATION=1
    POWERLINE_BASH_SELECT=1
    . ~/.local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh
else
    . /usr/share/git-core/contrib/completion/git-prompt.sh
    . $HOME/.bashrc_ps1
fi

# agent setup
if [ -f ~/.agent.env ] ; then
    . ~/.agent.env > /dev/null
    if ! kill -0 $SSH_AGENT_PID > /dev/null 2>&1; then
        echo "Stale agent file found. Spawning new agent… "
        eval `ssh-agent | tee ~/.agent.env`
        ssh-add ~/.ssh
    fi
else
    echo "Starting ssh-agent"
    eval `ssh-agent | tee ~/.agent.env`
    ssh-add ~/.ssh
fi

# User specific aliases and functions
alias matrix='tr -c "[:xdigit:]" " " < /dev/urandom | pv -L 10k | dd cbs=$COLUMNS conv=unblock | GREP_COLOR="1;32" grep --color "[^ ]"'
alias docker-stop-all='docker stop $(docker ps -q -a)'
alias docker-rm-all='docker rm $(docker ps -q -a)'
alias ccat='pygmentize -g'

# Cambio colores de terminal
alias col_dark="sh ~/.config/termcolours/dark.sh"
alias col_light="sh ~/.config/termcolours/light.sh"
alias col_default="sh ~/.config/termcolours/default.sh"

export LOLCOMMITS_DIR=$HOME/Dropbox/Photos/lolcommits/
export LOLCOMMITS_DEVICE=/dev/video2
export EDITOR="vim"
export TODO_DIR=$HOME/.config/todo/

# path setup
PATH=$PATH:$GOPATH/bin
export PATH
