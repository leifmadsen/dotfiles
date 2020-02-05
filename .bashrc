# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# if powerline is installed, then use it
#command -v powerline-daemon &>/dev/null
#if [ $? -eq 0 ]; then
#    powerline-daemon -q
#    POWERLINE_BASH_CONTINUATION=1
#    POWERLINE_BASH_SELECT=1
#    . ~/.local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh
#else
#    . /usr/share/git-core/contrib/completion/git-prompt.sh
#    . $HOME/.bashrc_ps1
#fi

function _update_ps1() {
    eval $(powerline-go -eval -colorize-hostname -shorten-gke-names -modules "user,kube,venv,ssh,cwd,docker,node,dotenv,git,jobs,nix-shell,perms,exit,termtitle" -cwd-max-depth 3 -path-aliases \~/src/go/src/github.com=@GO-GH -error $?)
}

#function _update_ps1() {
#    PS1="$(~/.powerline/powerline-go -cwd-max-depth 3 -modules "nix-shell,docker,venv,user,host,ssh,cwd,perms,git,hg,jobs,exit,root,vgo")"
#}

if [ "$TERM" != "linux" ]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

# agent setup
if [ -f ~/.agent.env ] ; then
    . ~/.agent.env > /dev/null
    if ! kill -0 $SSH_AGENT_PID > /dev/null 2>&1; then
        echo "Stale agent file found. Spawning new agent… "
        eval `ssh-agent | tee ~/.agent.env`
        ssh-add
    fi
else
    echo "Starting ssh-agent"
    eval `ssh-agent | tee ~/.agent.env`
    ssh-add
fi

# User specific aliases and functions
alias matrix='tr -c "[:xdigit:]" " " < /dev/urandom | pv -L 10k | dd cbs=$COLUMNS conv=unblock | GREP_COLOR="1;32" grep --color "[^ ]"'
alias docker-stop-all='docker stop $(docker ps -q -a)'
alias docker-rm-all='docker rm $(docker ps -q -a)'
alias ccat='pygmentize -g'
alias pastebin='nc termbin.com 9999'
alias git=hub
alias ssh-virthost='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no -o ProxyCommand="ssh -W %h:%p root@virthost"'
alias ssh-whistler='ssh -o ProxyCommand="ssh -W %h:%p -p 2212 leif@whistler.dougbtv.com"'
alias ssh-remote='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -p 3128 root@ljam.ddns.net"'
alias ssh-salab='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no -o ProxyCommand="ssh -W %h:%p root@10.19.110.11"'


# Cambio colores de terminal
alias col_dark="sh ~/.config/termcolours/dark.sh"
alias col_light="sh ~/.config/termcolours/light.sh"
alias col_default="sh ~/.config/termcolours/default.sh"

# Gertty
alias gertty-opnfv="gertty -c ~/.gertty-opnfv.yaml"
alias gertty-stack="gertty -c ~/.gertty.yaml"

# firewall
alias fw="sudo firewall-cmd"

# lolcommits
export LOLCOMMITS_DIR=$HOME/Dropbox/Photos/lolcommits/
export LOLCOMMITS_DEVICE=/dev/video2
export LOLCOMMITS_FORK=true
export LOLCOMMITS_STEALTH=true

export EDITOR="vim"
export XDG_CONFIG_DIRS=$HOME/.config
export TASKDDATA=$HOME/.config/taskd
export NOTES_DIRECTORY=$HOME/.notes/

# ansible
alias playbook=ansible-playbook

# kubernetes
export KUBECONFIG=$HOME/.kube/config

# lambdaMOO
alias lambdamoo="telnet lambda.moo.mud.org 8888"

# add atom.io alias using docker
alias atom="docker run --privileged -ti --rm -e DISPLAY=$DISPLAY -v ~/.atom:/home/developer/.atom -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/src:/home/developer/src leifmadsen/atom.io"

# Depends on 'dnf install source-hightlight'
export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
export LESS=" -R "

alias oc=~/.local/bin/oc4

# notifier
alias notify=~/bin/pushbullet_notify.sh

# find large files (ducks) [ref: https://www.cyberciti.biz/faq/linux-find-largest-file-in-directory-recursively-using-find-du/]
alias ducks='du -cks * | sort -rn | head'

# GHI (GitHub Issues CLI client)
source ~/.private/tokens/ghi

# Quay.io token
source ~/.private/tokens/quay.io

# starred repo token
source ~/.private/tokens/github_starred_token
alias build_starred="starred --username leifmadsen --repository awesome-stars --sort"

# path setup
PATH=$PATH:$GOPATH/bin
export PATH

# added by travis gem
[ -f /home/lmadsen/.travis/travis.sh ] && source /home/lmadsen/.travis/travis.sh
#source <(kubectl completion bash)
source <(kompose completion bash)
source <(oc completion bash)
