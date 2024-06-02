#!/bin/sh
#
# Reproducible Development Environment

wd=$(pwd) # WD=$(dirname "$0") # i.e. path to this file

# Recreate the dirs destroyed by `git clean --force -dx`:
for prjd in \
        $wd/root-dir/var/guix/db \
        ;
    do
    # printf "prjd: $prjd\n"
    if [ ! -d $prjd ]; then
        mkdir --parent $prjd
    fi
done

prj_dirs=(
    $wd/root-dir/var/guix/db
)

# `git clean --force -dx` destroys the prj_dirs. Recreate it:
for prjd in ${prj_dirs[@]}; do
    if [ ! -d $prjd ]; then
        set -x  # Print commands and their arguments as they are executed.
        mkdir --parent $prjd
        { retval="$?"; set +x; } 2>/dev/null
    fi
done

# --preserve=REGEX
#   preserve environment variables matching REGEX
#
# The $DISPLAY is needed by clojure.inspector, however the
#   --preserve=^DISPLAY
# leads to an error in the REPL:
#   Authorization required, but no authorization protocol specified
# and:
#   error in process filter: cljr--maybe-nses-in-bad-state: \
#   Some namespaces are in a bad state: ...

# No shell is started when the '--search-paths' parameter is used. Only the
# variables making up the environment are displayed.
#   guix shell --search-paths

# Make ./persistent-profile a symlink to the `guix shell ...` result, and
# register it as a garbage collector root, i.e. prevent garbage collection
# during(!) the `guix shell ...` session:
#  --root=./persistent-profile \
#

# Create environment for the package that the '...' EXPR evaluates to.
# --expression='(list (@ (gnu packages bash) bash) "include")' \
#

# --share=/tmp/guix-devel-socket.socket=/tmp/guix-devel-socket.socket \
# --share=$wd/var/guix/db=/var/guix/db \
# --share=/usr/bin \
# --share=$wd/etc=/usr/etc \


# touch /tmp/guix-devel-socket.socket
export GUIX_DAEMON_SOCKET=/tmp/guix-devel-socket.socket
# '--preserve=^GUIX_DAEMON_SOCKET$' \
#     --emulate-fhs \


# export SSL_CERT_DIR=$(guix build nss-certs)
export SSL_CERT_DIR="/run/current-system/profile"
export SSL_CERT_FILE="$SSL_CERT_DIR/etc/ssl/certs/ca-certificates.crt"
export GIT_SSL_CAINFO="$SSL_CERT_FILE"

set -x
guix shell \
     --container --network \
     --share=$wd/root-dir/var/guix/db=/var/guix/db \
     --share=$HOME/.bash_history=$HOME/.bash_history \
     --share=$wd/.bash_profile=$HOME/.bash_profile \
     --share=$wd/.bashrc=$HOME/.bashrc \
     --share=$HOME/.cache \
     --share=/gnu/store \
     --share=/tmp \
     --share=/var \
     --development guix \
     gzip libzip gnupg sudo which direnv help2man git strace glibc-locales bash \
     '--preserve=^SSL_CERT_DIR$' \
     '--preserve=^SSL_CERT_FILE$' \
     '--preserve=^GIT_SSL_CAINFO$' \
     nss-certs \
     --pure \
     -- bash
