# Bash initialization for interactive non-login shells and
# for remote shells (info "(bash) Bash Startup Files").

# Export 'SHELL' to child processes.  Programs such as 'screen'
# honor it and otherwise use /bin/sh.
export SHELL

# /run is not automatically created by guix
[ ! -d /run ] && mkdir /run

# # Quick access to $GUIX_ENVIRONMENT, for usage on config files
# # (currently only /etc/nginx/nginx.conf)
# [ ! -L /env ] && ln -s $GUIX_ENVIRONMENT /env

# # Link every file in /usr/etc on /etc
# ls -1d /usr/etc/* | while read filepath; do
#     bname=/etc/$(basename $filepath)
#     [ ! -L $bname ] && ln -s $filepath $bname
# done

run-guix-daemon () {
    set -x  # Print commands and their arguments as they are executed.
    ./pre-inst-env \
    ./guix-daemon \
        --debug \
        --build-users-group=guixbuild \
        --substitute-urls='https://ci.guix.gnu.org' \
        --listen=$GUIX_DAEMON_SOCKET
    { retval="$?"; set +x; } 2>/dev/null
}

guix-time-machine-a () {
    set -x  # Print commands and their arguments as they are executed.
    ./pre-inst-env guix time-machine --cores=24 --channels=channels-a.scm -- describe
    { retval="$?"; set +x; } 2>/dev/null
}

guix-time-machine-ab () {
    set -x  # Print commands and their arguments as they are executed.
    ./pre-inst-env guix time-machine --cores=24 --channels=channels-ab.scm -- describe
    { retval="$?"; set +x; } 2>/dev/null
}

guix-time-machine-abc () {
    set -x  # Print commands and their arguments as they are executed.
    ./pre-inst-env guix time-machine --cores=24 --channels=channels-abc.scm -- describe
    { retval="$?"; set +x; } 2>/dev/null
}

guix_prompt () {
    cat << "EOF"
    ░░░                                     ░░░
    ░░▒▒░░░░░░░░░               ░░░░░░░░░▒▒░░
     ░░▒▒▒▒▒░░░░░░░           ░░░░░░░▒▒▒▒▒░
         ░▒▒▒░░▒▒▒▒▒         ░░░░░░░▒▒░
               ░▒▒▒▒░       ░░░░░░
                ▒▒▒▒▒      ░░░░░░
                 ▒▒▒▒▒     ░░░░░
                 ░▒▒▒▒▒   ░░░░░
                  ▒▒▒▒▒   ░░░░░
                   ▒▒▒▒▒ ░░░░░
                   ░▒▒▒▒▒░░░░░
                    ▒▒▒▒▒▒░░░
                     ▒▒▒▒▒▒░
     _____ _   _ _    _    _____       _
    / ____| \ | | |  | |  / ____|     (_)
   | |  __|  \| | |  | | | |  __ _   _ ___  __
   | | |_ | . ' | |  | | | | |_ | | | | \ \/ /
   | |__| | |\  | |__| | | |__| | |_| | |>  <
    \_____|_| \_|\____/   \_____|\__,_|_/_/\_\

# 1.   Before starting Guix-Shell:
# 1.1. Kill default guix-daemon:
     sudo herd stop guix-daemon
# 1.2. Start development version of guix-daemon:
    ./guix-daemon-devel.sh
# 2. Start Guix-Shell:
    ./run.sh
# 3. Start the Guix-Time-machine(s):
    guix-time-machine-a    # alias: gta
    guix-time-machine-ab   # alias: gtab
    guix-time-machine-abc  # alias: gtabc
# 4. After exiting Guix-Shell start default guix-daemon:
    sudo herd start guix-daemon
EOF
}

if [[ $- != *i* ]]
then
    # We are being invoked from a non-interactive shell.  If this
    # is an SSH session (as in "ssh host command"), source
    # /etc/profile so we get PATH and other essential variables.
    [[ -n "$SSH_CLIENT" ]] && guix_prompt

    # Don't do anything else.
    return
fi

guix_prompt

if [ -z ${GUIX_DAEMON_SOCKET+x} ]; then
    printf "\nGUIX_DAEMON_SOCKET is not set\n"
else
    printf "\nGUIX_DAEMON_SOCKET: %s\n" $GUIX_DAEMON_SOCKET
fi

# Adjust the prompt depending on whether we're in 'guix environment'.
if [ -n "$GUIX_ENVIRONMENT" ]
then
    PS1='\u@\h \w [env]\$ '
else
    PS1='\u@\h \w\$ '
fi
alias ls='ls -p --color=auto'
alias ll='ls -l'
alias grep='grep --color=auto'
alias clear="printf '\e[2J\e[H'"
alias rgd='run-guix-daemon'
alias gta='guix-time-machine-a'
alias gtab='guix-time-machine-ab'
alias gtabc='guix-time-machine-abc'
