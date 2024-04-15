#!/bin/sh

set -ex

# mkdir a
# echo '(define-module (my-channel-a))' > a/my-channel-a.scm
# (cd a; git init; git add .; git commit -m init)

# mkdir b
# cat > b/my-channel-b.scm <<EOF
# (define-module (my-channel-b)
#   #:use-module (my-channel-a))
# EOF
# cat > b/.guix-channel <<EOF
# (channel
#   (version 0)
#   (dependencies
#    (channel (name my-channel-a) (url "$PWD/a"))))
# EOF
# (cd b; git init; git add .; git commit -m init)

# mkdir c
# cat > c/my-channel-c.scm <<EOF
# (define-module (my-channel-c)
#   #:use-module (my-channel-b))
# EOF
# cat > c/.guix-channel <<EOF
# (channel
#   (version 0)
#   (dependencies
#    (channel (name my-channel-b) (url "$PWD/b"))))
# EOF
# (cd c; git init; git add .; git commit -m init)

# cat > "channels.scm" <<EOF
# (list (channel
#         (name 'guix)
#         (url "https://git.savannah.gnu.org/git/guix.git")
#         (commit
#           "65dc2d40cb113382fb98796f1d04099f28cab355")
#         (introduction
#           (make-channel-introduction
#             "9edb3f66fd807b096b48283debdcddccfea34bad"
#             (openpgp-fingerprint
#               "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
#       (channel
#         (name 'my-channel-c)
#         (url "$PWD/c")))
# EOF

# /var/log/guix/drvs/xm/hfg4b67gx4mw67gmfm9b597hgp359p-my-channel-c.drv.gz

exec guix time-machine --channels=channels.scm -- describe
