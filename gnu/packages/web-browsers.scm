;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2014 John Darrington <jmd@gnu.org>
;;; Copyright © 2014, 2019 Mark H Weaver <mhw@netris.org>
;;; Copyright © 2015, 2016, 2019, 2021-2023 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2016 Kei Kebreau <kkebreau@posteo.net>
;;; Copyright © 2017 Eric Bavier <bavier@member.fsf.org>
;;; Copyright © 2018–2021 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2018 Rutger Helling <rhelling@mykolab.com>
;;; Copyright © 2018 Timo Eisenmann <eisenmann@fn.de>
;;; Copyright © 2018 Pierre Neidhardt <mail@ambrevar.xyz>
;;; Copyright © 2019 Clément Lassieur <clement@lassieur.org>
;;; Copyright © 2019 Brett Gilio <brettg@gnu.org>
;;; Copyright © 2020 Raghav Gururajan <raghavgururajan@disroot.org>
;;; Copyright © 2020 B. Wilson <elaexuotee@wilsonb.com>
;;; Copyright © 2020 Michael Rohleder <mike@rohleder.de>
;;; Copyright © 2020 Nicolò Balzarotti <nicolo@nixo.xyz>
;;; Copyright © 2020 Alexandru-Sergiu Marton <brown121407@posteo.ro>
;;; Copyright © 2020 Hartmut Goebel <h.goebel@crazy-compilers.com>
;;; Copyright © 2021, 2022 Cage <cage-dev@twistfold.it>
;;; Copyright © 2021 Benoit Joly <benoit@benoitj.ca>
;;; Copyright © 2021 Alexander Krotov <krotov@iitp.ru>
;;; Copyright © 2020 Hartmut Goebel <h.goebel@crazy-compilers.com>
;;; Copyright © 2021 Christopher Howard <christopher@librehacker.com>
;;; Copyright © 2023 Herman Rimm <herman@rimm.ee>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnu packages web-browsers)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system go)
  #:use-module (guix build-system python)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages backup)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages fltk)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages fribidi)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnome-xyz)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages javascript)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages libidn)
  #:use-module (gnu packages libunistring)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages lisp-check)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages lua)
  #:use-module (gnu packages man)
  #:use-module (gnu packages markup)
  #:use-module (gnu packages mp3)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages suckless)
  #:use-module (gnu packages tcl)
  #:use-module (gnu packages text-editors)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages web)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xorg))

(define-public midori
  (package
    (name "midori")
    (version "9.0")
    (source
     (origin
       (method url-fetch)
       (uri
        (string-append "https://github.com/midori-browser/core/releases/"
                       "download/v" version "/" name "-v" version ".tar.gz"))
       (sha256
        (base32
         "05i04qa83dnarmgkx4xsk6fga5lw1lmslh4rb3vhyyy4ala562jy"))))
    (build-system cmake-build-system)
    (arguments
     `(#:imported-modules
       (,@%cmake-build-system-modules
        (guix build glib-or-gtk-build-system))
       #:modules
       ((guix build cmake-build-system)
        ((guix build glib-or-gtk-build-system) #:prefix glib-or-gtk:)
        (guix build utils))
       #:phases
       (modify-phases %standard-phases
         (add-after 'install 'glib-or-gtk-compile-schemas
           (assoc-ref glib-or-gtk:%standard-phases
                      'glib-or-gtk-compile-schemas))
         (add-after 'install 'glib-or-gtk-wrap
           (assoc-ref glib-or-gtk:%standard-phases
                      'glib-or-gtk-wrap)))))
    (native-inputs
     `(("desktop-file-utils" ,desktop-file-utils) ;for tests
       ("glib:bin" ,glib "bin")
       ("gtk+:bin" ,gtk+ "bin")
       ("intltool" ,intltool)
       ("pkg-config" ,pkg-config)
       ("which" ,which))) ;for tests
    (inputs
     `(("adwaita-icon-theme" ,adwaita-icon-theme)
       ("gcr" ,gcr-3)
       ("glib" ,glib)
       ("glib-networking" ,glib-networking)
       ("gsettings-desktop-schemas" ,gsettings-desktop-schemas)
       ("gtk+" ,gtk+)
       ("json-glib" ,json-glib)
       ("libarchive" ,libarchive)
       ("libpeas" ,libpeas)
       ("sqlite" ,sqlite)
       ("vala" ,vala)
       ("webkitgtk" ,webkitgtk-with-libsoup2)))
    (synopsis "Lightweight graphical web browser")
    (description "@code{Midori} is a lightweight, Webkit-based web browser.
It features integration with GTK+3, configurable web search engine, bookmark
management, extensions such as advertisement blocker and colorful tabs.")
    (home-page "https://www.midori-browser.org")
    (license license:lgpl2.1+)))

(define-public links
  (package
    (name "links")
    (version "2.29")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://links.twibright.com/download/"
                                  "links-" version ".tar.bz2"))
              (sha256
               (base32
                "163rmng8zkwy0pv9wxcpc0j3gz27g8ba9myrgs7ny6lfng09dai2"))))
    (build-system gnu-build-system)
    (arguments
     (list
       #:configure-flags #~(list "--enable-graphics")
       #:phases
       #~(modify-phases %standard-phases
           (replace 'configure
             (lambda* (#:key outputs (configure-flags '()) #:allow-other-keys)
               ;; The tarball uses a very old version of autoconf. It doesn't
               ;; understand extra flags like `--enable-fast-install', so
               ;; we need to invoke it with just what it understands.
               (let ((out (assoc-ref outputs "out")))
                 ;; 'configure' doesn't understand '--host'.
                 #$@(if (%current-target-system)
                       #~((setenv "CHOST" #$(%current-target-system)))
                       #~())
                 (setenv "CONFIG_SHELL" (which "bash"))
                 (apply invoke "./configure"
                        (string-append "--prefix=" out)
                        configure-flags)))))))
    (native-inputs (list pkg-config))
    (inputs
     (list gpm
           libevent
           libjpeg-turbo
           libpng
           libtiff
           libxt
           openssl
           zlib))
    (synopsis "Text and graphics mode web browser")
    (description "Links is a graphics and text mode web browser, with many
features including, tables, builtin image display, bookmarks, SSL and more.")
    (home-page "http://links.twibright.com")
    ;; The distribution contains a copy of GPLv2
    ;; However, the copyright notices simply say:
    ;; "This file is a part of the Links program, released under GPL."
    ;; Therefore, under the provisions of Section 9, we can choose
    ;; any version ever published by the FSF.
    ;; One file (https.c) contains an exception permitting
    ;; linking of the program with openssl.
    (license license:gpl1+)))

(define-public luakit
  (package
    (name "luakit")
    (version "2.3.3")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/luakit/luakit")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "19z6idmjz6y7xmjpqgw65mdfi65lyvy06819dj5bb7rad63v5542"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     (list
      #:tests? #false                   ;require un-packaged "luassert"
      #:test-target "run-tests"
      #:make-flags
      #~(list (string-append "CC=" #$(cc-for-target))
              "LUA_BIN_NAME=lua"
              "DEVELOPMENT_PATHS=0"
              (string-append "PREFIX=" #$output)
              (string-append "XDGPREFIX=" #$output "/etc/xdg"))
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'lfs-workaround
            (lambda _
              (setenv "LUA_CPATH"
                      (string-append #$(this-package-input "lua5.1-filesystem")
                                     "/lib/lua/5.1/?.so;;"))))
          (add-before 'build 'set-version
            (lambda _
              (setenv "VERSION_FROM_GIT" #$version)))
          (delete 'configure)
          (add-after 'install 'wrap
            (lambda _
              (wrap-program (string-append #$output "/bin/luakit")
                `("LUA_CPATH" prefix
                  (,(string-append #$(this-package-input "lua5.1-filesystem")
                                   "/lib/lua/5.1/?.so;;")))
                `("XDG_CONFIG_DIRS" prefix
                  (,(string-append #$output "/etc/xdg/")))))))))
    (native-inputs
     (list pkg-config))
    (inputs
     (list glib-networking
           gsettings-desktop-schemas
           gtk+
           lua-5.1
           lua5.1-filesystem
           luajit
           sqlite
           webkitgtk-with-libsoup2))
    (synopsis "Fast, lightweight, and simple browser based on WebKit")
    (description "Luakit is a fast, lightweight, and simple to use
micro-browser framework extensible by Lua using the WebKit web content engine
and the GTK+ toolkit.")
    (home-page "https://luakit.github.io/")
    (license license:gpl3+)))

(define-public lynx
  (package
    (name "lynx")
    (version "2.9.0dev.12")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "http://invisible-mirror.net/archives/lynx/tarballs"
                    "/lynx" version ".tar.bz2"))
              (sha256
               (base32
                "1rg8dqafq8ray37s0w855mahq7ywfb4qa4h5q676sxq0klamnid6"))))
    (build-system gnu-build-system)
    (native-inputs (list pkg-config perl))
    (inputs (list ncurses
                  libidn
                  openssl
                  libgcrypt
                  unzip
                  zlib
                  gzip
                  bzip2))
    (arguments
     (list #:configure-flags
           #~(let ((openssl #$(this-package-input "openssl")))
               (list "--with-pkg-config"
                     "--with-screen=ncurses"
                     "--with-zlib"
                     "--with-bzlib"
                     (string-append "--with-ssl=" openssl)
                     ;; "--with-socks5"    ; XXX TODO
                     "--enable-widec"
                     "--enable-ascii-ctypes"
                     "--enable-local-docs"
                     "--enable-htmlized-cfg"
                     "--enable-gzip-help"
                     "--enable-nls"
                     "--enable-ipv6"))
           #:tests? #f                  ; no check target
           #:phases
           #~(modify-phases %standard-phases
               (add-before 'configure 'set-makefile-shell
                 (lambda _ (substitute* "po/makefile.inn"
                        (("/bin/sh") (which "sh")))))
               (replace 'install
                 (lambda* (#:key (make-flags '()) #:allow-other-keys)
                   (apply invoke "make" "install-full" make-flags))))))
    (synopsis "Text Web Browser")
    (description
     "Lynx is a fully-featured @acronym{WWW, World Wide Web} client for users
of cursor-addressable, character-cell display devices.  It will display
@acronym{HTML, Hypertext Markup Language} documents containing links to files
on the local system, as well as files on remote systems running http, gopher,
ftp, wais, nntp, finger, or cso/ph/qi servers.

Lynx can be used to access information on the WWW, or to build information
systems intended primarily for local access.")
    (home-page "https://lynx.invisible-island.net/")
    ;; This was fixed in 2.8.9dev.10.
    (properties `((lint-hidden-cve . ("CVE-2016-9179"))))
    (license license:gpl2)))

(define-public kristall
  ;; Fixes to the build system applied after the latest tag
  ;; Use tagged release when updating
  (let ((commit "204b08a9303e75cd8d4c252b0554935062766f86")
        (revision "1"))
    (package
      (name "kristall")
      (version (string-append "0.3-" revision "." (string-take commit 7)))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/MasterQ32/kristall")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "1mymq0dh6r0829x74j0jkw8hw46amqwbznlf1b4ra6w77h9yz3lj"))
         (modules '((srfi srfi-1)
                    (ice-9 ftw)
                    (guix build utils)))
         (snippet
          '(let ((preserved-lib-files '("luis-l-gist")))
             (with-directory-excursion "lib"
               (for-each
                (lambda (directory)
                  (simple-format #t "deleting: ~A\n" directory)
                  (delete-file-recursively directory))
                (lset-difference string=?
                                 (scandir ".")
                                 (cons* "." ".." preserved-lib-files))))
             ;; Contains executable of 7z and pscp
             (delete-file-recursively "ci/tools")
             ;; Remove bundled fonts
             (delete-file-recursively "src/fonts")
             #t))))
      (build-system gnu-build-system)
      (arguments
       `(#:modules ((guix build gnu-build-system)
                    (guix build qt-utils)
                    (guix build utils))
         #:imported-modules (,@%gnu-build-system-modules
                             (guix build qt-utils))
         #:make-flags
         (list (string-append "PREFIX=" %output))
         #:phases
         (modify-phases %standard-phases
           (delete 'configure)          ; no ./configure script
           (delete 'check)              ; no check target
           (add-before 'build 'set-program-version
             (lambda _
               ;; configure.ac relies on ‘git --describe’ to get the version.
               ;; Patch it to just return the real version number directly.
               (substitute* "src/kristall.pro"
                 (("(KRISTALL_VERSION=).*" _ match)
                  (string-append match ,version "\n")))
               #t))
           (add-before 'build 'dont-use-bundled-cmark
             (lambda _
               (substitute* "src/kristall.pro"
                 (("(^include\\(.*cmark.*)" _ match)
                  (string-append
                   "LIBS += -I" (assoc-ref %build-inputs "cmark") " -lcmark")))
               #t))
           (add-before 'build 'dont-use-bundled-breeze-stylesheet
             (lambda _
               (substitute* "src/kristall.pro"
                 (("../lib/BreezeStyleSheets/breeze.qrc")
                  (string-append
                   (assoc-ref %build-inputs "breeze-stylesheet") "/breeze.qrc")))
               #t))
           (add-before 'build 'dont-use-bundled-fonts
             (lambda _
               (substitute* "src/kristall.pro"
                 ((".*fonts.qrc.*") ""))
               (substitute* "src/main.cpp"
                 (("/fonts/OpenMoji-Color")
                  (string-append
                   (assoc-ref %build-inputs "font-openmoji")
                   "/share/fonts/truetype/OpenMoji-Color"))
                 (("/fonts/NotoColorEmoji")
                  (string-append
                   (assoc-ref %build-inputs "font-google-noto")
                   "/share/fonts/truetype/NotoColorEmoji")))
               #t))
           (add-after 'install 'wrap-program
             (lambda* (#:key outputs inputs #:allow-other-keys)
               (let ((out (assoc-ref outputs "out")))
                 (wrap-qt-program "kristall" #:output out #:inputs inputs))
               #t)))))
      (native-inputs
       `(("breeze-stylesheet"
          ,(let ((commit "2d595a956f8a5f493aa51139a470b768a6d82cce")
                 (revision "0"))
             (origin
               (method git-fetch)
               (uri
                (git-reference
                 (url "https://github.com/Alexhuszagh/BreezeStyleSheets")
                 (commit "2d595a956f8a5f493aa51139a470b768a6d82cce")))
               (file-name (git-file-name "breeze-stylesheet"
                                         (git-version "0" revision commit)))
               (sha256
                (base32
                 "1kvkxkisi3czldnb43ig60l55pi4a3m2a4ixp7krhpf9fc5wp294")))))))
      (inputs
       (list cmark
             font-google-noto
             font-openmoji
             openssl
             qtbase-5
             qtmultimedia-5
             qtsvg-5))
      (home-page "https://kristall.random-projects.net")
      (synopsis "Small-internet graphical client")
      (description "Graphical small-internet client with with many features
including multi-protocol support (gemini, HTTP, HTTPS, gopher, finger),
bookmarks, TSL certificates management, outline generation and a tabbed
interface.")
      (license (list license:gpl3+
                     ;; for breeze-stylesheet
                     license:expat)))))

(define-public qutebrowser
  (package
    (name "qutebrowser")
    (version "3.1.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/qutebrowser/"
                           "qutebrowser/releases/download/v" version "/"
                           "qutebrowser-" version ".tar.gz"))
       (sha256
        (base32 "0prf9c7nx4aizfczjb0fpsn3alz210i6wc7s2jwb1mh8r8fcq3ah"))))
    (build-system python-build-system)
    (native-inputs
     (list python-attrs))               ; for tests
    (inputs
     (list bash-minimal
           python-colorama
           python-jinja2
           python-markupsafe
           python-pygments
           python-pynacl
           python-pypeg2
           python-pyyaml
           python-pyqt-6
           python-pyqtwebengine-6
           ;; While qtwebengine is provided by python-pyqtwebengine-6, it's
           ;; included here so we can wrap QTWEBENGINEPROCESS_PATH.
           qtwebengine))
    (arguments
     `(;; FIXME: With the existence of qtwebengine, tests can now run.  But
       ;; they are still disabled because test phase hangs.  It's not readily
       ;; apparent as to why.
       #:tests? #f
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-systemdir
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (substitute* "qutebrowser/utils/standarddir.py"
                 (("/usr/share") (string-append out "/share"))))))
         (add-after 'unpack 'find-userscripts
           (lambda* (#:key outputs #:allow-other-keys)
             (substitute* "qutebrowser/commands/userscripts.py"
               (("os.path.join.*system=True)")
                (string-append "os.path.join(\""
                               (assoc-ref outputs "out")
                               "\", \"share\", \"qutebrowser\"")))))
         (add-before 'check 'set-env-offscreen
           (lambda _
             (setenv "QT_QPA_PLATFORM" "offscreen")))
         (add-after 'install 'install-more
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (rename-file "misc/Makefile" "Makefile")
               (substitute* "Makefile"
                 ((".*setup\\.py.*") ""))
               (invoke "make" "install" (string-append "PREFIX=" out))
               (delete-file-recursively (string-append out "/share/metainfo")))))
         (add-after 'install-more 'wrap-scripts
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (python (assoc-ref inputs "python"))
                    (path (string-append out "/lib/python"
                                         ,(version-major+minor (package-version
                                                                python))
                                         "/site-packages:"
                                         (getenv "GUIX_PYTHONPATH"))))
               (for-each
                (lambda (file)
                  (wrap-program file
                    `("GUIX_PYTHONPATH" ":" prefix (,path))))
                (append
                 (find-files
                  (string-append out "/share/qutebrowser/scripts") "\\.py$")
                 (find-files
                  (string-append out "/share/qutebrowser/userscripts")))))))
         (add-after 'wrap 'wrap-qt-process-path
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (wrap-program (search-input-file outputs "bin/qutebrowser")
               `("QTWEBENGINE_RESOURCES_PATH" =
                 (,(search-input-directory
                    inputs "/share/qt6/resources")))
               `("QTWEBENGINEPROCESS_PATH" =
                 (,(search-input-file
                    inputs "/lib/qt6/libexec/QtWebEngineProcess")))))))))
    (home-page "https://qutebrowser.org/")
    (synopsis "Minimal, keyboard-focused, vim-like web browser")
    (description "qutebrowser is a keyboard-focused browser with a minimal
GUI.  It is based on PyQt6 and QtWebEngine.")
    (license license:gpl3+)))

(define-public vimb
  (package
    (name "vimb")
    (version "3.6.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/fanglingsu/vimb/")
             (commit version)))
       (sha256
        (base32 "0228khh3lqbal046k6akqah7s5igq9s0wjfjbdjam75kjj42pbhj"))
       (file-name (git-file-name name version))))
    (build-system glib-or-gtk-build-system)
    (arguments
     '(#:tests? #f                      ; no tests
       #:make-flags (list "CC=gcc"
                          "DESTDIR="
                          (string-append "PREFIX=" %output))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))))
    (inputs
     `(("glib-networking" ,glib-networking)
       ("gsettings-desktop-schemas" ,gsettings-desktop-schemas)
       ("webkitgtk" ,webkitgtk-with-libsoup2)))
    (native-inputs
     (list pkg-config))
    (home-page "https://fanglingsu.github.io/vimb/")
    (synopsis "Fast and lightweight Vim-like web browser")
    (description "Vimb is a fast and lightweight vim like web browser based on
the webkit web browser engine and the GTK toolkit.  Vimb is modal like the great
vim editor and also easily configurable during runtime.  Vimb is mostly keyboard
driven and does not detract you from your daily work.")
    (license license:gpl3+)))

(define-public nyxt
  (package
    (name "nyxt")
    (version "3.11.6")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/atlas-engineer/nyxt")
             (commit version)))
       (sha256
        (base32
         "0q7kf1a42gfvgv54hwhgiyvnsi6qhjdl1k88c3wxr1bj4ffhpvm3"))
       (file-name (git-file-name name version))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags (list "nyxt" "NYXT_SUBMODULES=false"
                          (string-append "DESTDIR=" (assoc-ref %outputs "out"))
                          "PREFIX=")
       #:strip-binaries? #f             ; Stripping breaks SBCL binaries.
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (add-before 'build 'fix-common-lisp-cache-folder
           (lambda _ (setenv "HOME" "/tmp")))
         (add-before 'check 'configure-tests
           (lambda _ (setenv "NYXT_TESTS_NO_NETWORK" "1") #t))
         (add-after 'install 'wrap-program
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((bin (string-append (assoc-ref outputs "out") "/bin/nyxt"))
                    (glib-networking (assoc-ref inputs "glib-networking"))
                    (libs '("gsettings-desktop-schemas"))
                    (path (string-join
                           (map (lambda (lib)
                                  (string-append (assoc-ref inputs lib) "/lib"))
                                libs)
                           ":"))
                    (gi-path (getenv "GI_TYPELIB_PATH"))
                    (xdg-path (string-join
                               (map (lambda (lib)
                                      (string-append (assoc-ref inputs lib) "/share"))
                                    libs)
                               ":")))
               (wrap-program bin
                 `("GIO_EXTRA_MODULES" prefix
                   (,(string-append glib-networking "/lib/gio/modules")))
                 `("GI_TYPELIB_PATH" prefix (,gi-path))
                 `("LD_LIBRARY_PATH" ":" prefix (,path))
                 `("XDG_DATA_DIRS" ":" prefix (,xdg-path)))))))))
    (native-inputs (list cl-lisp-unit2 sbcl))
    (inputs (list sbcl-alexandria
                  sbcl-bordeaux-threads
                  sbcl-calispel
                  sbcl-cl-base64
                  sbcl-cl-colors2
                  sbcl-cl-containers
                  sbcl-cl-gopher
                  sbcl-cl-html-diff
                  sbcl-cl-json
                  sbcl-cl-ppcre
                  sbcl-cl-prevalence
                  sbcl-cl-qrencode
                  sbcl-cl-sqlite
                  sbcl-cl-str
                  sbcl-cl-tld
                  sbcl-closer-mop
                  sbcl-clss
                  sbcl-cluffer
                  sbcl-custom-hash-table
                  sbcl-dexador
                  sbcl-dissect
                  sbcl-enchant
                  sbcl-flexi-streams
                  sbcl-history-tree
                  sbcl-iolib
                  sbcl-lass
                  sbcl-local-time
                  sbcl-log4cl
                  sbcl-lparallel
                  sbcl-montezuma
                  sbcl-moptilities
                  sbcl-named-readtables
                  sbcl-nclasses
                  sbcl-ndebug
                  sbcl-nfiles
                  sbcl-nhooks
                  sbcl-njson
                  sbcl-nkeymaps
                  sbcl-nsymbols
                  sbcl-parenscript
                  sbcl-phos
                  sbcl-plump
                  sbcl-prompter
                  sbcl-py-configparser
                  sbcl-quri
                  sbcl-serapeum
                  sbcl-slime-swank
                  sbcl-slynk
                  sbcl-spinneret
                  sbcl-trivia
                  sbcl-trivial-clipboard
                  sbcl-trivial-custom-debugger
                  sbcl-trivial-features
                  sbcl-trivial-garbage
                  sbcl-trivial-package-local-nicknames
                  sbcl-trivial-types
                  sbcl-unix-opts
                  ;; WebKitGTK deps
                  sbcl-cl-cffi-gtk
                  sbcl-cl-webkit
                  glib-networking
                  gsettings-desktop-schemas
                  cl-gobject-introspection
                  gtk+                  ; For the main loop
                  webkitgtk-for-gtk3    ; Required when we use its typelib
                  gobject-introspection
                  pkg-config
                  ;; Useful for video playback
                  gst-libav
                  gst-plugins-bad
                  gst-plugins-base
                  gst-plugins-good
                  gst-plugins-ugly))
    (synopsis "Extensible web-browser in Common Lisp")
    (home-page "https://nyxt-browser.com/")
    (description "Nyxt is a keyboard-oriented, extensible web-browser designed
for power users.  The application has familiar Emacs and VI key-bindings and
is fully configurable and extensible in Common Lisp.")
    (license license:bsd-3)))

(define-public lagrange
  (package
    (name "lagrange")
    (version "1.17.6")
    (source
     (origin
       (method url-fetch)
       (uri
        (string-append "https://git.skyjake.fi/skyjake/lagrange/releases/"
                       "download/v" version "/lagrange-" version ".tar.gz"))
       (sha256
        (base32 "0fsjn74cmrchqgnj88yzdxyj1gm0i2vrzh69b9b9bi7y2wk9il5r"))
       (modules '((guix build utils)))
       (snippet
        '(begin
           ;; TODO: unbundle fonts.
           (delete-file-recursively "lib/fribidi")
           (delete-file-recursively "lib/harfbuzz")
           (delete-file-recursively "lib/sealcurses")))))
    (build-system cmake-build-system)
    (arguments
     `(#:tests? #false                  ;no tests
       #:configure-flags (list "-DTFDN_ENABLE_SSE41=OFF")))
    (native-inputs
     (list pkg-config zip))
    (inputs
     (list freetype
           fribidi
           harfbuzz
           libunistring
           libwebp
           mpg123
           openssl
           pcre
           sdl2
           zlib))
    (native-search-paths
     (list (search-path-specification
            (variable "XDG_DATA_DIRS")
            (files '("share")))))
    (home-page "https://gmi.skyjake.fi/lagrange/")
    (synopsis "Graphical Gemini client")
    (description
     "Lagrange is a desktop GUI client for browsing Geminispace.  It offers
modern conveniences familiar from web browsers, such as smooth scrolling,
inline image viewing, multiple tabs, visual themes, Unicode fonts, bookmarks,
history, and page outlines.")
    (properties
     '((release-monitoring-url . "https://git.skyjake.fi/gemini/lagrange/releases")))
    (license license:bsd-2)))

(define-public gmni
  (package
    (name "gmni")
    (version "1.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://git.sr.ht/~sircmpwn/gmni")
                    (commit version)))
              (sha256
               (base32
                "0bky9fd8iyr13r6gj4aynb7j9nd36xdprbgq6nh5hz6jiw04vhfw"))
              (file-name (git-file-name name version))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f                       ;no check target
      #:make-flags #~(list #$(string-append "CC=" (cc-for-target)))))
    (inputs
     (list bearssl))
    (native-inputs
     (list pkg-config scdoc))
    (home-page "https://sr.ht/~sircmpwn/gmni")
    (synopsis "Minimalist command line Gemini client")
    (description "The gmni package includes:

@itemize
@item A CLI utility (like curl): gmni
@item A line-mode browser: gmnlm
@end itemize")
    (license (list license:gpl3+
                   (license:non-copyleft
                    "https://curl.se/docs/copyright.html"
                    "Used only for files taken from curl.")))))

(define-public bombadillo
  (package
    (name "bombadillo")
    (version "2.4.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://tildegit.org/sloum/bombadillo")
                    (commit version)))
              (sha256
               (base32
                "03gcd813bmiy7ad179zg4p61nfa9z5l94sdmsmmn2x204h1ksd8n"))
              (file-name (git-file-name name version))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "tildegit.org/sloum/bombadillo"
      #:install-source? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-data
            (lambda _
              (let* ((builddir "src/tildegit.org/sloum/bombadillo")
                     (pkg (strip-store-file-name #$output))
                     (sharedir (string-append #$output "/share"))
                     (appdir (string-append sharedir "/applications"))
                     (docdir (string-append sharedir "/doc/" pkg))
                     (mandir (string-append sharedir "/man/man1"))
                     (pixdir (string-append sharedir "/pixmaps")))
                (with-directory-excursion builddir
                  (install-file "bombadillo.desktop" appdir)
                  (install-file "bombadillo.1" mandir)
                  (install-file "bombadillo-icon.png" pixdir))))))))
    (home-page "https://bombadillo.colorfield.space")
    (synopsis "Terminal browser for the gopher, gemini, and finger protocols")
    (description "Bombadillo is a non-web browser for the terminal with
vim-like key bindings, a document pager, configurable settings, and robust
command selection.  The following protocols are supported as first-class
citizens: gopher, gemini, finger, and local.  There is also support for telnet,
http, and https via third-party applications.")
    (license license:gpl3+)))

(define-public tinmop
  (package
    (name "tinmop")
    (version "0.9.9.141421356")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/cage/tinmop")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0cw8scjxci98jx5cmm98x0frjrbs3q7w3dwz60xpy67aqmwq7kqx"))))
    (build-system gnu-build-system)
    (native-inputs
     (list autoconf
           automake
           gnu-gettext
           imagemagick
           mandoc
           nano
           openssl
           sbcl
           tk
           unzip
           xdg-utils))
    (inputs
     (list ncurses
           sbcl-access
           sbcl-alexandria
           sbcl-babel
           sbcl-bordeaux-threads
           sbcl-cl+ssl
           sbcl-cl-base64
           sbcl-cl-colors2
           sbcl-cl-html5-parser
           sbcl-cl-i18n
           sbcl-cl-ppcre
           sbcl-cl-spark
           sbcl-cl-sqlite
           sbcl-clunit2
           sbcl-croatoan
           sbcl-crypto-shortcuts
           sbcl-drakma
           sbcl-esrap
           sbcl-flexi-streams
           sbcl-ieee-floats
           sbcl-local-time
           sbcl-log4cl
           sbcl-marshal
           sbcl-nodgui
           sbcl-osicat
           sbcl-parse-number
           sbcl-percent-encoding
           sbcl-purgatory
           sbcl-sxql
           sbcl-sxql-composer
           sbcl-tooter
           sbcl-trivial-clipboard
           sbcl-unix-opts
           sbcl-usocket
           sbcl-yason
           sqlite))
    (arguments
     `(#:tests? #f
       #:strip-binaries? #f
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'set-home
           (lambda _
             (setenv "HOME" "/tmp")
             #t))
         (add-after 'unpack 'fix-configure.ac
           (lambda _
             (delete-file "configure")
             (substitute* "configure.ac"
               (("AC_PATH_PROG.+CURL")
                "dnl")
               (("AC_PATH_PROGS.+GIT")
                "dnl")
               (("AC_PATH_PROG.+GPG")
                "dnl"))
             #t))
         (add-after 'configure 'fix-asdf
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "Makefile.in"
               (("LISP_COMPILER) ")
                (string-concatenate
                 '("LISP_COMPILER) --eval \"(require 'asdf)\" "
                   "--eval \"(push \\\"$$(pwd)/\\\" asdf:*central-registry*)\"  "))))
             #t)))))
    (synopsis
     "Gemini, gopher, kami and mastodon/pleroma client with a terminal interface")
    (description
     "This package provides a Gemini, gopher, kami and mastodon/pleroma client
with a terminal interface, for Gemini also a GUI is available.")
    (home-page "https://www.autistici.org/interzona/tinmop.html")
    (license license:gpl3+)))

(define-public telescope
  (package
    (name "telescope")
    (version "0.9")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/omar-polo/telescope/releases/download/"
                           version "/telescope-" version ".tar.gz"))
       (sha256
        (base32 "1xbwdm3xcahwl6sjqx6f8hhx7nyzyygkjsnxglwxazp8zlmchqy9"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f))                    ;no tests
    (native-inputs
     (list gettext-minimal pkg-config))
    (inputs
     (list libgrapheme libressl ncurses))
    (home-page "https://telescope.omarpolo.com/")
    (synopsis "Gemini client with a terminal interface")
    (description "Telescope is a w3m-like browser for Gemini.")
    (license license:x11)))

(define-public leo
  ;; PyPi only provides a wheel.
  (let ((commit "88cc10a87afe2ec86be06e6ea2bcd099f5360b74")
        (version "1.0.4")
        (revision "1"))
    (package
      (name "leo")
      (version (git-version version revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/xyzshantaram/leo")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0jp4v4jw82qqynqqs7x35g5yvm1sd48cvbqh7j2r1ixw1z6ldhc4"))))
      (build-system python-build-system)
      (home-page "https://github.com/xyzshantaram/leo")
      (synopsis "Gemini client written in Python")
      (description
       "@command{leo} is a gemini client written in Python with no external
dependencies that fully implements the Gemini spec.  A list of URLs can be
saved to a file for further viewing in another window.")
      (license license:expat))))

(define-public av-98
  (package
    (name "av-98")
    (version "1.0.1")
    (properties
     '((upstream-name . "AV-98")))
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "AV-98" version))
       (sha256
        (base32
         "02fjnc2rvm010gb3i07p8r4xlhrmnv1wca1qymfjcymr7vm68h0i"))))
    (build-system python-build-system)
    (home-page "https://tildegit.org/solderpunk/AV-98/")
    (synopsis "Command line Gemini client")
    (description "AV-98 is an experimental client for the Gemini protocol.
Features include
@itemize
@item TOFU or CA server certificate validation;
@item Extensive client certificate support if an openssl binary is available;
@item Ability to specify external handler programs for different MIME types;
@item Gopher proxy support;
@item Advanced navigation tools like tour and mark (as per VF-1);
@item Bookmarks;
@item IPv6 support;
@item Support for any character encoding recognised by Python.
@end itemize")
    (license license:bsd-2)))

(define-public edbrowse
  (package
    (name "edbrowse")
    (version "3.8.9")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/CMB/edbrowse.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0hxvdvplmbnn0jzw4ls8a03k2s7qdylghln74910yljzjf392mld"))))
    (build-system gnu-build-system)
    (inputs (list curl-ssh pcre2 quickjs openssl readline-7 tidy-html
                  unixodbc))
    (native-inputs (list perl pkg-config))
    (arguments
     (list
      #:make-flags
      #~(list (string-append "CC=" #$(cc-for-target))
              (string-append "QUICKJS_LIB="
                             (assoc-ref %build-inputs "quickjs")
                             "/lib/quickjs"))
      #:tests? #f ; Edbrowse doesn't have tests
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (add-after 'unpack 'patch
            (lambda _
              (for-each
               (lambda (file)
                 (substitute* file
                   (("\"quickjs-libc.h\"") "<quickjs/quickjs-libc.h>")))
               '("src/js_hello_quick.c" "src/jseng-quick.c"))))
          (replace 'install
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (bin (string-append out "/bin"))
                     (doc (string-append out "/share/doc/" #$name "-" #$version)))
                (mkdir-p doc)
                (install-file "doc/usersguide.html" doc)
                (install-file "src/edbrowse" bin)))))))
    (home-page "https://edbrowse.org/")
    (synopsis "Command-line editor and web browser")
    (description "Edbrowse is a combination editor, browser, and mail client that is
100% text based.  The interface is similar to /bin/ed, though there are many more
features, such as editing multiple files simultaneously, and rendering html.  This
program was originally written for blind users, but many sighted users have taken
advantage of the unique scripting capabilities of this program, which can be found
nowhere else.  A batch job, or cron job, can access web pages on the internet, submit
forms, and send email, with no human intervention whatsoever.  edbrowse can also tap
into databases through odbc.  It was primarily written by Karl Dahlke.")
    (license license:gpl2+)))
