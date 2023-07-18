;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2013, 2014, 2015, 2016, 2022 Andreas Enge <andreas@enge.fr>
;;; Copyright © 2014 Eric Bavier <bavier@member.fsf.org>
;;; Copyright © 2015 Mark H Weaver <mhw@netris.org>
;;; Copyright © 2016 Roel Janssen <roel@gnu.org>
;;; Copyright © 2016, 2018, 2019, 2020, 2021 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2016 Federico Beffa <beffa@fbengineering.ch>
;;; Copyright © 2016 Thomas Danckaert <post@thomasdanckaert.be>
;;; Copyright © 2016-2023 Ricardo Wurmus <rekado@elephly.net>
;;; Copyright © 2017 Leo Famulari <leo@famulari.name>
;;; Copyright © 2017, 2020-2022 Marius Bakke <marius@gnu.org>
;;; Copyright © 2017, 2018, 2019, 2020 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2018 Danny Milosavljevic <dannym+a@scratchpost.org>
;;; Copyright © 2018, 2020 Arun Isaac <arunisaac@systemreboot.net>
;;; Copyright © 2020 Vincent Legoll <vincent.legoll@gmail.com>
;;; Copyright © 2020, 2021 Paul Garlick <pgarlick@tourbillion-technology.com>
;;; Copyright © 2021, 2022 Maxim Cournoyer <maxim.cournoyer@gmail.com>
;;; Copyright © 2021-2023 Nicolas Goaziou <mail@nicolasgoaziou.fr>
;;; Copyright © 2021 Leo Le Bouter <lle-bout@zaclys.net>
;;; Copyright © 2021 Xinglu Chen <public@yoctocell.xyz>
;;; Copyright © 2021 Ivan Gankevich <i.gankevich@spbu.ru>
;;; Copyright © 2021 Julien Lepiller <julien@lepiller.eu>
;;; Copyright © 2021 Thiago Jung Bauermann <bauermann@kolabnow.com>
;;; Copyright © 2022 Simon South <simon@simonsouth.net>
;;; Copyright © 2022 Jack Hill <jackhill@jackhill.us>
;;; Copyright © 2022 Fabio Natali <me@fabionatali.com>
;;; Copyright © 2022 Philip McGrath <philip@philipmcgrath.com>
;;; Copyright © 2023 Thomas Albers Raviola <thomas@thomaslabs.org>
;;; Copyright © 2023 John Kehayias <john.kehayias@protonmail.com>
;;; Copyright © 2023 Dominik Delgado Steuter <d@delgado.nrw>
;;; Copyright © 2023 Timothy Sample <samplet@ngyro.com>
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

(define-module (gnu packages tex)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system perl)
  #:use-module (guix build-system python)
  #:use-module (guix build-system qt)
  #:use-module (guix build-system trivial)
  #:use-module (guix build-system texlive)
  #:use-module (guix utils)
  #:use-module (guix deprecation)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix svn-download)
  #:use-module (gnu packages)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages aspell)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages digest)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gd)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages icu4c)
  #:use-module (gnu packages image)
  #:use-module (gnu packages libreoffice)
  #:use-module (gnu packages lua)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages perl-check)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages ruby)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages texinfo)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 match)
  #:use-module ((srfi srfi-1) #:hide (zip)))

(define* (simple-texlive-package name locations hash
                                 #:key trivial?)
  "Return a template for a simple TeX Live package with the given NAME,
downloading from a list of LOCATIONS in the TeX Live repository, and expecting
the provided output HASH.  If TRIVIAL? is provided, all files will simply be
copied to their outputs; otherwise the TEXLIVE-BUILD-SYSTEM is used."
  (set! locations
        ;; Some locations may be manually inserted, so be tolerant with
        ;; leading slashes.  Ignore them consistently.
        (map (lambda (location)
               (if (string-prefix? "/" location)
                   (string-drop location 1)
                   location))
             locations))
  (define with-documentation?
    (any (lambda (l) (string-prefix? "doc/" l))
         locations))
  (package
    (name name)
    (version (number->string %texlive-revision))
    (source (texlive-origin name version locations hash))
    (outputs (if with-documentation?
                 '("out" "doc")
                 '("out")))
    (build-system (if trivial?
                      gnu-build-system
                      texlive-build-system))
    (arguments
     (let ((copy-files
            `(lambda* (#:key outputs inputs tex-directory #:allow-other-keys)
               (let (,@(if with-documentation?
                           `((doc (string-append (assoc-ref outputs "doc")
                                                 "/share/texmf-dist")))
                           '())
                     (source (assoc-ref inputs "source"))
                     (out (string-append (assoc-ref outputs "out")
                                         "/share/texmf-dist")))
                 ,@(if with-documentation?
                       '((mkdir-p doc)
                         (copy-recursively
                          (string-append source "/doc")
                          (string-append doc "/doc")))
                       '())
                 (mkdir-p out)
                 (copy-recursively "." out)
                 ;; In any case, if documentation exists, it is already in the
                 ;; "doc" output, so remove it from regular one.
                 (let ((doc (string-append out "/doc")))
                   (when (file-exists? doc)
                     (delete-file-recursively doc)))
                 ;; Also remove all source files.
                 (let ((srcfiles (string-append out "/source")))
                   (when (file-exists? srcfiles)
                     (delete-file-recursively srcfiles)))))))
       (if trivial?
           `(#:tests? #f
             #:phases
             (modify-phases %standard-phases
               (delete 'configure)
               (replace 'build (const #t))
               (replace 'install ,copy-files)))
           `())))
    (home-page #f)
    (synopsis #f)
    (description #f)
    (license #f)))

(define hyph-utf8-scripts
  (origin
    (method svn-fetch)
    (uri (texlive-ref "generic" "hyph-utf8"))
    (file-name (string-append "hyph-utf8-scripts-"
                              (number->string %texlive-revision)
                              "-checkout"))
    (patches (search-patches "texlive-hyph-utf8-no-byebug.patch"))
    (sha256
     (base32
      "04xzf5gr3ylyh3ls09imrx4mwq3qp1k97r9njzlan6hlff875rx2"))))

(define (texlive-hyphen-package name code locations hash)
  "Return a TeX Live hyphenation package with the given NAME, using source
files from LOCATIONS with expected checksum HASH.  CODE is not currently in use."
  (let ((parent (simple-texlive-package
                 name locations hash #:trivial? #t)))
    (package
      (inherit parent)
      (arguments
       (substitute-keyword-arguments (package-arguments parent)
         ((#:phases phases)
          `(modify-phases ,phases
             (replace 'build
               (lambda* (#:key inputs outputs #:allow-other-keys)
                 (let* ((out (assoc-ref outputs "out"))
                        (root (string-append out "/share/texmf-dist"))
                        (patterns
                         (string-append root "/tex/generic/hyph-utf8/patterns/txt/"))
                        (loaders
                         (string-append root "/tex/generic/hyph-utf8/loadhyph"))
                        (ptex
                         (string-append root "/tex/generic/hyph-utf8/patterns/ptex"))
                        (quote
                         (string-append root "/tex/generic/hyph-utf8/patterns/quote")))
                   (mkdir "scripts")
                   (copy-recursively
                    (dirname (search-input-file inputs "hyph-utf8.rb"))
                    "scripts")

                   ;; Prepare target directories
                   (mkdir-p patterns)
                   (mkdir-p loaders)
                   (mkdir-p ptex)
                   (mkdir-p quote)

                   ;; Generate plain patterns
                   (with-directory-excursion "scripts"
                     (substitute* "lib/tex/hyphen/path.rb"
                       (("^([[:blank:]]+)TeXROOT = .*" _ indent)
                        (string-append indent "TeXROOT = \""
                                       (getcwd) "/..\"\n")))

                     (substitute* "generate-plain-patterns.rb"
                       ;; Ruby 2 does not need this.
                       (("require 'unicode'") "")
                       ;; Write directly to the output directory
                       (("File\\.join\\(PATH::TXT")
                        (string-append "File.join(\"" patterns "\""))
                       (("File\\.join\\(PATH::QUOTE")
                        (string-append "File.join(\"" quote "\"")))
                     (invoke "ruby" "generate-plain-patterns.rb")

                     ;; Build pattern loaders
                     (substitute* "generate-pattern-loaders.rb"
                       (("File\\.join\\(PATH::LOADER")
                        (string-append "File.join(\"" loaders "\"")))

                     (invoke "ruby" "generate-pattern-loaders.rb")

                     ;; Build ptex patterns
                     (substitute* "generate-ptex-patterns.rb"
                       (("File\\.join\\(PATH::PTEX")
                        (string-append "File.join(\"" ptex "\"")))
                     (invoke "ruby" "generate-ptex-patterns.rb")))))))))
      (native-inputs
       (list ruby-2.7 ruby-hydra-minimal/pinned hyph-utf8-scripts))
      (home-page "https://ctan.org/pkg/hyph-utf8"))))

(define texlive-extra-src
  (origin
    (method url-fetch)
    (uri "ftp://tug.org/historic/systems/texlive/2021/texlive-20210325-extra.tar.xz")
    (sha256 (base32
             "171kg1n9zapw3d2g47d8l0cywa99bl9m54xkqvp9625ks22z78s6"))))

(define texlive-texmf-src
  (origin
    (method url-fetch)
    (uri "ftp://tug.org/historic/systems/texlive/2021/texlive-20210325-texmf.tar.xz")
    (sha256 (base32
             "070gczcm1h9rx29w2f02xd3nhd84c4k28nfmm8qgp69yq8vd84pz"))))

(define-public texlive-bin
  (package
    (name "texlive-bin")
    (version "20210325")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "ftp://tug.org/historic/systems/texlive/2021/"
                           "texlive-" version "-source.tar.xz"))
       (sha256
        (base32
         "0jsq1p66l46k2qq0gbqmx25flj2nprsz4wrd1ybn286p11kdkvvs"))
       (modules '((guix build utils)
                  (ice-9 ftw)))
       (snippet
        ;; TODO: Unbundle stuff in texk/dvisvgm/dvisvgm-src/libs too.
        '(with-directory-excursion "libs"
           (let ((preserved-directories '("." ".." "lua53" "luajit" "pplib" "xpdf")))
             ;; Delete bundled software, except Lua which cannot easily be
             ;; used as an external dependency, pplib and xpdf which aren't
             ;; supported as system libraries (see m4/kpse-xpdf-flags.m4).
             (for-each delete-file-recursively
                       (scandir "."
                                (lambda (file)
                                  (and (not (member file preserved-directories))
                                       (eq? 'directory (stat:type (stat file))))))))))))
    (build-system gnu-build-system)
    (inputs
     `(("texlive-extra-src" ,texlive-extra-src)
       ("config" ,config)
       ("texlive-scripts"
        ,(origin
           (method svn-fetch)
           (uri (svn-reference
                 (url (string-append "svn://www.tug.org/texlive/tags/"
                                     %texlive-tag "/Master/texmf-dist/"
                                     "/scripts/texlive"))
                 (revision %texlive-revision)))
           (file-name (string-append "texlive-scripts-"
                                     (number->string %texlive-revision)
                                     "-checkout"))
           (sha256
            (base32
             "1jrphfjhmw17rp1yqsl70shmvka3vg0g8841q6zx2lfn48p7vqf3"))))
       ("cairo" ,cairo)
       ("fontconfig" ,fontconfig)
       ("fontforge" ,fontforge)
       ("freetype" ,freetype)
       ("gd" ,gd)
       ("gmp" ,gmp)
       ("ghostscript" ,ghostscript)
       ("graphite2" ,graphite2)
       ("harfbuzz" ,harfbuzz)
       ("icu4c" ,icu4c)
       ("libpaper" ,libpaper)
       ("libpng" ,libpng)
       ("libxaw" ,libxaw)
       ("libxt" ,libxt)
       ("mpfr" ,mpfr)
       ("perl" ,perl)
       ("pixman" ,pixman)
       ("potrace" ,potrace)
       ("python" ,python)
       ("ruby" ,ruby-2.7)
       ("tcsh" ,tcsh)
       ("teckit" ,teckit)
       ("zlib" ,zlib)
       ("zziplib" ,zziplib)))
    (native-inputs
     (list pkg-config))
    (arguments
     `(#:modules ((guix build gnu-build-system)
                  (guix build utils)
                  (ice-9 ftw)
                  (srfi srfi-1)
                  (srfi srfi-26))
       #:out-of-source? #t
       #:configure-flags
       '("--disable-static"
         "--disable-native-texlive-build"
         "--enable-shared"
         "--with-banner-add=/GNU Guix"
         "--with-system-cairo"
         "--with-system-freetype2"
         "--with-system-gd"
         "--with-system-gmp"
         "--with-system-graphite2"
         "--with-system-harfbuzz"
         "--with-system-icu"
         "--with-system-libgs"
         "--with-system-libpaper"
         "--with-system-libpng"
         "--with-system-mpfr"
         "--with-system-pixman"
         "--with-system-potrace"
         "--with-system-teckit"
         "--with-system-zlib"
         "--with-system-zziplib"
         ;; LuaJIT is not ported to some architectures yet.
         ,@(if (or (target-ppc64le?)
                   (target-riscv64?))
             '("--disable-luajittex"
               "--disable-luajithbtex"
               "--disable-mfluajit")
             '()))

      ;; Disable tests on some architectures to cope with a failure of
      ;; luajiterr.test.
      ;; XXX FIXME fix luajit properly on these architectures.
      #:tests? ,(let ((s (or (%current-target-system)
                             (%current-system))))
                  (not (or (string-prefix? "aarch64" s)
                           (string-prefix? "mips64" s)
                           (string-prefix? "powerpc64le" s))))

       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-psutils-test
           (lambda _
             ;; This test fails due to a rounding difference with libpaper 1.2:
             ;;   https://github.com/rrthomas/libpaper/issues/23
             ;; Adjust the expected outcome to account for the minute difference.
             (substitute* "texk/psutils/tests/playres.ps"
               (("844\\.647799")
                "844.647797"))))
         (add-after 'unpack 'configure-ghostscript-executable
           ;; ps2eps.pl uses the "gswin32c" ghostscript executable on Windows,
           ;; and the "gs" ghostscript executable on Unix. It detects Unix by
           ;; checking for the existence of the /usr/bin directory. Since
           ;; Guix System does not have /usr/bin, it is also detected as Windows.
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "utils/ps2eps/ps2eps-src/bin/ps2eps.pl"
               (("gswin32c") "gs"))
             (substitute* "texk/texlive/linked_scripts/epstopdf/epstopdf.pl"
               (("\"gs\"")
                (string-append "\"" (assoc-ref inputs "ghostscript") "/bin/gs\"")))))
         (add-after 'unpack 'patch-dvisvgm-build-files
           (lambda _
             ;; XXX: Ghostscript is detected, but HAVE_LIBGS is never set, so
             ;; the appropriate linker flags are not added.
             (substitute* "texk/dvisvgm/configure"
               (("^have_libgs=yes" all)
                (string-append all "\nHAVE_LIBGS=1")))))
         (add-after 'unpack 'disable-failing-test
           (lambda _
             ;; FIXME: This test fails on 32-bit architectures since Glibc 2.28:
             ;; <https://bugzilla.redhat.com/show_bug.cgi?id=1631847>.
             (substitute* "texk/web2c/omegafonts/check.test"
               (("^\\./omfonts -ofm2opl \\$srcdir/tests/check tests/xcheck \\|\\| exit 1")
                "./omfonts -ofm2opl $srcdir/tests/check tests/xcheck || exit 77"))))
         ,@(if (or (target-ppc32?)
                   (target-riscv64?))
             ;; Some mendex tests fail on some architectures.
             `((add-after 'unpack 'skip-mendex-tests
                 (lambda _
                   (substitute* '("texk/mendexk/tests/mendex.test"
                                  "texk/upmendex/tests/upmendex.test")
                     (("srcdir/tests/pprecA-0.ind pprecA-0.ind1 \\|\\| exit 1")
                      "srcdir/tests/pprecA-0.ind pprecA-0.ind1 || exit 77")))))
             '())
         (add-after 'unpack 'unpack-texlive-extra
           (lambda* (#:key inputs #:allow-other-keys)
             (mkdir "texlive-extra")
             (with-directory-excursion "texlive-extra"
               (apply (assoc-ref %standard-phases 'unpack)
                      (list #:source (assoc-ref inputs "texlive-extra-src"))))))
         (add-after 'unpack-texlive-extra 'unpack-texlive-scripts
           (lambda* (#:key inputs #:allow-other-keys)
             (mkdir "texlive-scripts")
             (with-directory-excursion "texlive-scripts"
               (apply (assoc-ref %standard-phases 'unpack)
                      (list #:source (assoc-ref inputs "texlive-scripts")))
               ;; Configure the version string for some scripts.
               ;; Normally this would be done by Subversion.
               ;; See <https://issues.guix.gnu.org/43442#15>.
               (for-each (lambda (file)
                           (substitute* file
                             (("\\$Id\\$")
                              (format #f "$Id: ~a ~a ~a nobody $"
                                      file
                                      ,%texlive-revision
                                      ,%texlive-date))
                             (("\\$Revision\\$")
                              (format #f "$Revision: ~a $"
                                      ,%texlive-revision))
                             (("\\$Date\\$")
                              (format #f "$Date: ~a $"
                                      ,%texlive-date))))
                         '("fmtutil.pl"
                           "mktexlsr"
                           "mktexlsr.pl"
                           "mktexmf"
                           "mktexpk"
                           "mktextfm"
                           "tlmgr.pl"
                           "tlmgrgui.pl"
                           "updmap.pl")))))
         (add-after 'unpack-texlive-scripts 'patch-scripts
           (lambda _
             (let* ((scripts (append (find-files "texk/kpathsea" "^mktex")
                                     (find-files "texk/texlive/linked_scripts"
                                                 "\\.sh$")
                                     (find-files "texlive-scripts" "\\.sh$")))
                    (commands '("awk" "basename" "cat" "grep" "mkdir" "rm"
                                "sed" "sort" "uname"))
                    (command-regexp (format #f "\\b(~a)\\b"
                                            (string-join commands "|")))
                    (iso-8859-1-encoded-scripts
                     '("texk/texlive/linked_scripts/texlive-extra/rubibtex.sh"
                       "texk/texlive/linked_scripts/texlive-extra/rumakeindex.sh")))

               (define (substitute-commands scripts)
                 (substitute* scripts
                   ((command-regexp dummy command)
                    (which command))))

               (substitute-commands (lset-difference string= scripts
                                                     iso-8859-1-encoded-scripts))

               (with-fluids ((%default-port-encoding "ISO-8859-1"))
                 (substitute-commands iso-8859-1-encoded-scripts)))))
         ;; When ST_NLINK_TRICK is set, kpathsea attempts to avoid work when
         ;; searching files by assuming that a directory with exactly two
         ;; links has no subdirectories.  This assumption does not hold in our
         ;; case, so some directories with symlinked subdirectories would not
         ;; be traversed.
         (add-after 'patch-scripts 'patch-directory-traversal
           (lambda _
             (substitute* "texk/kpathsea/config.h"
               (("#define ST_NLINK_TRICK") ""))))

         ,@(if (target-arm32?)
               `((add-after 'unpack 'skip-faulty-test
                   (lambda _
                     ;; Skip this faulty test on armhf-linux:
                     ;;   https://issues.guix.gnu.org/54055
                     (substitute* '("texk/mendexk/tests/mendex.test"
                                    "texk/upmendex/tests/upmendex.test")
                       (("^TEXMFCNF=" all)
                        (string-append "exit 77 # skip\n" all))))))
               '())

         (add-after 'check 'customize-texmf.cnf
           ;; The default texmf.cnf is provided by this package, texlive-bin.
           ;; Every variable of interest is set relatively to the GUIX_TEXMF
           ;; environment variable defined via a search path specification
           ;; further below.  The configuration file is patched after the test
           ;; suite has run, as it relies on the default configuration to find
           ;; its paths (and the GUIX_TEXMF variable isn't set yet).
           (lambda _
             ;; The current directory is build/ because of the out-of-tree
             ;; build.
             (let* ((source    (first (scandir ".." (cut string-suffix?
                                                         "source" <>))))
                    (texmf.cnf (string-append "../" source
                                              "/texk/kpathsea/texmf.cnf")))
               (substitute* texmf.cnf
                 (("^TEXMFROOT = .*")
                  "TEXMFROOT = {$GUIX_TEXMF}/..\n")
                 (("^TEXMF = .*")
                  "TEXMF = {$GUIX_TEXMF}\n")
                 (("^%TEXMFCNF = .*")
                  "TEXMFCNF = {$GUIX_TEXMF}/web2c\n")
                 ;; Don't truncate lines.
                 (("^error_line = .*$") "error_line = 254\n")
                 (("^half_error_line = .*$") "half_error_line = 238\n")
                 (("^max_print_line = .*$") "max_print_line = 1000\n")))))
         (add-after 'install 'post-install
           (lambda* (#:key inputs outputs #:allow-other-keys #:rest args)
             (let* ((out (assoc-ref outputs "out"))
                    (patch-source-shebangs (assoc-ref %standard-phases
                                                      'patch-source-shebangs))
                    (share (string-append out "/share"))
                    (scripts (string-append share
                                            "/texmf-dist/scripts/texlive"))
                    (source (string-append
                             "../" (first (scandir ".." (cut string-suffix?
                                                             "source" <>)))))
                    (tl-extra-root (string-append source "/texlive-extra"))
                    (tl-extra-dir (first
                                   (scandir tl-extra-root
                                            (negate
                                             (cut member <> '("." ".."))))))
                    (tlpkg-src (string-append tl-extra-root "/" tl-extra-dir
                                              "/tlpkg"))
                    (config.guess (search-input-file inputs
                                                     "/bin/config.guess")))

               ;; Create symbolic links for the latex variants and their man
               ;; pages.  We link lualatex to luahbtex; see issue #51252 for
               ;; details.
               (with-directory-excursion (string-append out "/bin/")
                 (for-each symlink
                           '("pdftex" "pdftex"   "xetex"   "luahbtex")
                           '("latex"  "pdflatex" "xelatex" "lualatex")))
               (with-directory-excursion (string-append share "/man/man1/")
                 (symlink "luatex.1" "lualatex.1"))

               ;; Install tlpkg.
               (copy-recursively tlpkg-src (string-append share "/tlpkg"))

               ;; Install texlive-scripts.
               (copy-recursively (string-append
                                  source "/texlive-scripts/source/")
                                 scripts)

               ;; Patch them.
               (let ((dirs (map dirname (list (which "sed") (which "awk")))))
                 (with-directory-excursion scripts
                   (substitute* '("mktexpk" "mktexmf" "mktexlsr")
                     (("^version=" m)
                      (format #false "PATH=\"~{~a:~}$PATH\"; export PATH~%~a"
                              dirs m)))))

               ;; Make sure that fmtutil can find its Perl modules.
               (substitute* (string-append scripts "/fmtutil.pl")
                 (("\\$TEXMFROOT/")
                  (string-append share "/")))

               ;; Likewise for updmap.pl.
               (substitute* (string-append scripts "/updmap.pl")
                 (("\\$TEXMFROOT/tlpkg")
                  (string-append share "/tlpkg")))

               ;; Likewise for the tlmgr.
               (substitute* (string-append scripts "/tlmgr.pl")
                 ((".*\\$::installerdir = \\$Master.*" all)
                  (format #f "  $Master = ~s;~%~a" share all)))

               ;; Install the config.guess script, required by tlmgr.
               (with-directory-excursion share
                 (mkdir-p "tlpkg/installer/")
                 (symlink config.guess "tlpkg/installer/config.guess"))

               ;; texlua shebangs are not patched by the patch-source-shebangs
               ;; phase because the texlua executable does not exist at that
               ;; time.
               (setenv "PATH" (string-append (getenv "PATH") ":" out "/bin"))
               (with-directory-excursion out
                 (patch-source-shebangs))))))))
    (native-search-paths
     (list (search-path-specification
            (variable "GUIX_TEXMF")
            (files '("share/texmf-dist")))))
    (synopsis "TeX Live, a package of the TeX typesetting system")
    (description
     "TeX Live provides a comprehensive TeX document production system.
It includes all the major TeX-related programs, macro packages, and fonts
that are free software, including support for many languages around the
world.

This package contains the binaries.")
    (license (license:fsf-free "https://www.tug.org/texlive/copying.html"))
    (home-page "https://www.tug.org/texlive/")))

(define-public texlive-bidi
  (package
    (name "texlive-bidi")
    ;; Take the version from texlive-2022.0 as the one from texlive 2021.0 is
    ;; buggy.
    (version "36.4")
    (source (origin
              (method svn-multi-fetch)
              (uri (svn-multi-reference
                    (url (string-append "svn://www.tug.org/texlive/tags/"
                                        "texlive-2022.0/Master/texmf-dist"))
                    (locations (list "doc/xelatex/bidi/"
                                     "source/xelatex/bidi/"))
                    (revision 62885)))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "09nfvsjfnms3pclyd2rcivyb5qvzw48b934i3bcl83hv69ix2ks7"))))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs (list texlive-iftex
                             texlive-ltxcmds
                             texlive-hyperref
                             texlive-xkeyval
                             texlive-zref))
    (home-page "https://ctan.org/pkg/bidi")
    (synopsis "Bidirectional typesetting in plain TeX and LaTeX using XeTeX")
    (description "The @code{bidi} package provides a convenient interface for
typesetting bidirectional texts with plain TeX and LaTeX.  The package
includes adaptations for use with many other commonly-used packages.")
    (license license:lppl1.3+)))

(define-public texlive-libkpathsea
  (package/inherit texlive-bin
    (name "texlive-libkpathsea")
    (source
     (origin
       (inherit (package-source texlive-bin))
       (snippet
        `(begin
           ,(origin-snippet (package-source texlive-bin))
           (with-directory-excursion "texk"
             (let ((preserved-directories '("." ".." "kpathsea")))
               (for-each
                delete-file-recursively
                (scandir "."
                         (lambda (file)
                           (and (not (member file preserved-directories))
                                (eq? 'directory (stat:type (stat file)))))))))))))
    (arguments
     (substitute-keyword-arguments (package-arguments texlive-bin)
       ((#:configure-flags flags)
        `(cons* "--disable-all-pkgs" "--enable-kpathsea"
                "--enable-shared" ,flags))
       ((#:phases phases)
        `(modify-phases %standard-phases
           (add-after 'install 'post-install
             (lambda* (#:key inputs outputs #:allow-other-keys)
               (with-directory-excursion "texk/kpathsea"
                 (invoke "make" "install"))))))))
    (inputs '())
    (synopsis "Path searching library")
    (description "kpathsea is a library, whose purpose is to return a filename
from a list of user-specified directories similar to how shells look up
executables.  It is maintained as a part of TeX Live.")))

(define-syntax-rule (define-deprecated-package old-name name)
  "Define OLD-NAME as a deprecated package alias for NAME."
  (define-deprecated/public old-name name
    (deprecated-package (symbol->string 'old-name) name)))

(define-public texlive-alphalph
  (let ((template (simple-texlive-package
                   "texlive-alphalph"
                   (list "doc/latex/alphalph/"
                         "source/latex/alphalph/"
                         "tex/generic/alphalph/")
                   (base32
                    "0ap59hmg0brg2wlh3bl77jxfxrk7hphhdal8cr05mby9bw35gffy"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:build-targets _ '())
          #~(list "alphalph.dtx"))))
      (propagated-inputs
       (list texlive-intcalc texlive-infwarerr))
      (home-page "https://ctan.org/pkg/alphalph")
      (synopsis "Convert numbers to letters")
      (description
       "This package provides commands @code{\\alphalph} and
@code{\\AlphAlph}.  They are like @code{\\number} but the expansion
consists of lowercase and uppercase letters respectively (1 to a, 26 to
z, 27 to aa, 52 to zz, 53 to ba, 702 to zz, 703 to aaa, etc.).
Alphalph's commands can be used as a replacement for LaTeX's
@code{\\@@alph} and @code{\\@@Alph} macros.")
      (license license:lppl1.3c+))))

(define texlive-docstrip
  (package
    (name "texlive-docstrip")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "/tex/latex/base/docstrip.tex")
             (base32
              "1pxbqbia0727vg01xv8451szm55z2w8sb0vv3kf4iqx5ibb6m0d2")))
    (build-system texlive-build-system)
    (arguments
     (list #:texlive-latex-base #f))
    (home-page "https://www.ctan.org/texlive")
    (synopsis "Utility to strip documentation from TeX files")
    (description "This package provides the docstrip utility to strip
documentation from TeX files.  It is part of the LaTeX base.")
    (license license:lppl1.3+)))

(define-public texlive-underscore
  (package
    (inherit (simple-texlive-package
              "texlive-underscore"
              (list "/doc/latex/underscore/"
                    "/tex/latex/underscore/")
              (base32
               "0slxsxc9azmv3gsm55jkhkv8a06wafankp55hhsdd6k4prp8szrb")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/underscore")
    (synopsis "Control the behaviour of @samp{_} in text")
    (description "This package causes @code{\\_} in text mode (i.e.,
@code{\\textunderscore}) to print an underscore so that hyphenation of words
either side of it is not affected; a package option controls whether an actual
hyphenation point appears after the underscore, or merely a break point.  The
package also arranges that, while in text, @samp{_} itself behaves as
@code{\\textunderscore} (the behaviour of @samp{_} in maths mode is not
affected).")
    (license license:lppl1.2+)))

(define-public texlive-unicode-data
  (package
    (inherit (simple-texlive-package
              "texlive-unicode-data"
              (list "/tex/generic/unicode-data/"
                    "/doc/generic/unicode-data/")
              (base32
               "1d41zvjsig7sqf2j2m89dnbv3gicpb16r04b4ikps4gabhbky83k")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/unicode-data")
    (synopsis "Unicode data and loaders for TeX")
    (description "This bundle provides generic access to Unicode Consortium
data for TeX use.  It contains a set of text files provided by the Unicode
Consortium which are currently all from Unicode 8.0.0, with the exception of
@code{MathClass.txt} which is not currently part of the Unicode Character
Database.  Accompanying these source data are generic TeX loader files
allowing this data to be used as part of TeX runs, in particular in building
format files.  Currently there are two loader files: one for general character
set up and one for initializing XeTeX character classes as has been carried
out to date by @code{unicode-letters.tex}.")
    (license license:lppl1.3c+)))

(define-deprecated-package texlive-generic-unicode-data texlive-unicode-data)

(define-public texlive-hyphen-base
  (package
    (inherit (simple-texlive-package
              "texlive-hyphen-base"
              (list "/tex/generic/config/language.dat"
                    "/tex/generic/config/language.dat.lua"
                    "/tex/generic/config/language.def"
                    "/tex/generic/config/language.us"
                    "/tex/generic/config/language.us.def"
                    "/tex/generic/config/language.us.lua"
                    "/tex/generic/hyphen/dumyhyph.tex"
                    "/tex/generic/hyphen/hyphen.tex"
                    "/tex/generic/hyphen/hypht1.tex"
                    "/tex/generic/hyphen/zerohyph.tex")
              (base32
               "1nad1bqpjsywm49hlv7d75mqvgha3j5vayvkvfhv8wwzgdb3mk84")
              #:trivial? #t))
    (home-page "https://tug.org/texlive/")
    (synopsis "Core hyphenation support files")
    (description "This package includes Knuth's original @file{hyphen.tex},
@file{zerohyph.tex} to disable hyphenation, @file{language.us} which starts
the autogenerated files @file{language.dat} and @file{language.def} (and
default versions of those), etc.")
    (license license:knuth)))

(define-public texlive-dvipdfmx
  (let ((template (simple-texlive-package
                   "texlive-dvipdfmx"
                   (list "doc/dvipdfm/"
                         "doc/dvipdfmx/"
                         "doc/man/man1/"
                         "dvipdfmx/"
                         "fonts/cmap/dvipdfmx/"
                         "fonts/map/dvipdfmx/")
                   (base32
                    "08i81hciksh0sm9pw6lw8v8s2rj92p58wd5j2mq1mzqbp171wjmr")
                   #:trivial? #t)))
    (package
      (inherit template)
      (source
       (origin
         (inherit (package-source template))
         ;; This map file is supposed to be generated in a profile hook.
         (snippet '(delete-file "fonts/map/dvipdfmx/updmap/kanjix.map"))))
      (propagated-inputs (list texlive-glyphlist))
      (home-page "https://www.tug.org/texlive/")
      (synopsis "Extended version of dvipdfm")
      (description
       "Dvipdfmx (formerly dvipdfm-cjk) is a development of dvipdfm created to
support multi-byte character encodings and large character sets for East Asian
languages.  Dvipdfmx, if \"called\" with the name dvipdfm, operates in a
\"dvipdfm compatibility\" mode, so that users of the both packages need only
keep one executable.  A secondary design goal is to support as many \"PDF\"
features as does pdfTeX.")
      (license license:gpl3+))))

(define-public texlive-dvips
  (package
    (inherit (simple-texlive-package
              "texlive-dvips"
              (list "/doc/man/man1/afm2tfm.1"
                    "/doc/man/man1/dvips.1"
                    "/dvips/base/"
                    "/dvips/config/"
                    "/fonts/enc/dvips/base/"
                    "/tex/generic/dvips/")
              (base32
               "1fb73mfw9mp4ylp6sfc0465rbdb7k830aq0qf3c085c3n0zyrin8")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/dvips")
    (synopsis "DVI to PostScript drivers")
    (description "This package provides files needed for converting DVI files
to PostScript.")
    (license license:lppl)))

(define-public texlive-tex-ini-files
  (package
    (inherit (simple-texlive-package
              "texlive-tex-ini-files"
              (list "/tex/generic/tex-ini-files/")
              (base32
               "0q1g62jg0qiqslm93ycvm30bw8ydmssjdshzsnzl7n2vpd62qfi2")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/tex-ini-files")
    (synopsis "Files for creating TeX formats")
    (description "This bundle provides a collection of model \".ini\" files
for creating TeX formats.  These files are commonly used to introduced
distribution-dependent variations in formats.  They are also used to
allow existing format source files to be used with newer engines, for example
to adapt the plain e-TeX source file to work with XeTeX and LuaTeX.")
    (license license:public-domain)))

(define-deprecated-package texlive-generic-tex-ini-files texlive-tex-ini-files)

(define-public texlive-metafont
  (package
    (name "texlive-metafont")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/man/man1/inimf.1"
                   "doc/man/man1/inimf.man1.pdf"
                   "doc/man/man1/mf-nowin.1"
                   "doc/man/man1/mf-nowin.man1.pdf"
                   "doc/man/man1/mf.1"
                   "doc/man/man1/mf.man1.pdf"
                   "metafont/base/"
                   "metafont/config/"
                   "metafont/misc/")
             (base32
              "1zzab3b8h2xsp88jqjr64i7f0yiqzd9rmzyvpgbfpyhd4sdl4fk4")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:texlive-latex-base #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'build 'generate-mf.base
            ;; Even though the file "mf.base" does not appear in tlpdb, it
            ;; must be generated and provided in metafont package.
            (lambda _
              (let* ((cwd (getcwd))
                     (mf (string-append cwd "/metafont"))
                     (modes #$(this-package-native-input "texlive-modes")))
                (setenv "MFINPUTS"
                        (string-append
                         modes "/share/texmf-dist/fonts/source/public/modes:"
                         mf "/base:"
                         mf "/misc:"
                         mf "/roex:"
                         mf "/feynmf:"
                         mf "/mfpic:"
                         mf "/config")))
              ;; "build" directory was not created during `build' phases since
              ;; there is no ".ins" nor ".dtx" file to process.
              (mkdir-p "build")
              (with-directory-excursion "build"
                (invoke "inimf" "mf.mf")
                (install-file "mf.base"
                              (string-append #$output
                                             "/share/texmf-dist/web2c"))))))))
    (native-inputs
     (list texlive-bin texlive-modes))
    (home-page "https://ctan.org/pkg/metafont")
    (synopsis "Metafont base files")
    (description "This package provides the Metafont base files needed to
build fonts using the Metafont system.")
    (license license:knuth)))

(define-deprecated-package texlive-metafont-base texlive-metafont)

(define-public texlive-mfirstuc
  (package
    (name "texlive-mfirstuc")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/mfirstuc/"
                   "scripts/mfirstuc/"
                   "source/latex/mfirstuc/"
                   "tex/latex/mfirstuc/")
             (base32
              "033ymwwc6q0v6saq0x2jc20vc94d38hna0vb8cymj3d8irqy97x2")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-etoolbox))
    (home-page "https://ctan.org/pkg/mfirstuc")
    (synopsis "Uppercase the first letter of a word")
    (description
     "The package provides commands @code{\\makefirstuc} that uppercases the
first letter in its argument (with a check for a semantic markup command at
the start of the argument), and @code{\\xmakefirstuc} which expands the
argument before uppercasing.  It also provides
@code{\\capitalisewords@{phrase@}} which applies @code{\\makefirstuc} to each
word in the phrase, where the words are separated by regular
spaces.  (Exceptions can be made for words that shouldn't be converted.)")
    (license license:lppl1.3+)))

(define-public texlive-modes
  (package
    (name "texlive-modes")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/modes/"
                   "fonts/source/public/modes/")
             (base32
              "1vz3ygpixswnk7hr3qfn3nffw460cp5wjq09q5ac83ddw3nya1ca")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list #:texlive-latex-base #f))
    (home-page "https://ctan.org/pkg/modes")
    (synopsis "Collection of Metafont @code{mode_def}'s")
    (description
     "The modes file collects all known Metafont modes for printing or display
devices, of whatever printing technology.  Special provision is made for
write-white printers, and a landscape mode is available, for making suitable
fonts for printers with pixels whose aspect is non-square.  The file also
provides definitions that make @code{\\specials} identifying the mode in
Metafont's GF output, and put coding information and other Xerox-world
information in the TFM file.")
    (license license:public-domain)))

(define-public texlive-fontinst
  (let ((template (simple-texlive-package
                   "texlive-fontinst"
                   (list "/doc/fonts/fontinst/"
                         "/doc/man/man1/fontinst.1"
                         "/doc/man/man1/fontinst.man1.pdf"

                         ;; This is used to build parts of
                         ;; /tex/fontinst/{base,misc}/ and
                         ;; /tex/latex/fontinst/fontdoc.sty.
                         "/source/fontinst/base/"

                         ;; These are not generated.
                         "/tex/fontinst/base/bbox.sty"
                         "/tex/fontinst/base/multislot.sty"
                         "/tex/fontinst/misc/glyphbox.mtx"
                         "/tex/fontinst/misc/glyphoff.mtx"
                         "/tex/fontinst/misc/glyphon.mtx"
                         "/tex/fontinst/misc/kernoff.mtx"
                         "/tex/fontinst/misc/kernon.mtx"

                         "/tex/fontinst/latinetx/"
                         "/tex/fontinst/latinmtx/"
                         "/tex/fontinst/mathmtx/"
                         "/tex/fontinst/smblmtx/")
                   (base32
                    "195jsijrpv828pqy99gm13j31nsc8bsa58zlbln2r0h5j9l44b5g")
                   #:trivial? #t)))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:modules _ '())
          '((guix build gnu-build-system)
            (guix build utils)
            (ice-9 match)))
         ((#:phases phases)
          `(modify-phases ,phases
             (replace 'build
               (lambda* (#:key inputs #:allow-other-keys)
                 (setenv "TEXINPUTS"
                         (string-append (getcwd) "//:"
                                        (getcwd) "/source/fontinst/base//:"
                                        (assoc-ref inputs "texlive-docstrip") "//"))
                 (mkdir "build")
                 (invoke "tex" "-ini" "-interaction=scrollmode"
                         "-output-directory=build"
                         "fontinst.ins")))
             ;; Since we're using docstrip without LaTeX we can't set \UseTDS
             ;; or \BaseDirectory, so the generated files are just dumped in
             ;; the "build" directory.
             (add-after 'install 'install-generated-files
               (lambda* (#:key outputs #:allow-other-keys)
                 (let* ((out (assoc-ref outputs "out"))
                        (root (string-append out "/share/texmf-dist")))
                   (for-each (match-lambda
                               ((dir files ...)
                                (for-each (lambda (file)
                                            (install-file
                                             (string-append "build/" file)
                                             (string-append root dir)))
                                          files)))
                             '(("/tex/fontinst/base"
                                "fontinst.sty"
                                "cfntinst.sty"
                                "xfntinst.sty"
                                "finstmsc.sty"
                                "fontinst.ini")
                               ("/tex/fontinst/misc"
                                "csc2x.tex"
                                "csckrn2x.tex"
                                "osf2x.tex")
                               ("/tex/latex/fontinst"
                                "fontdoc.sty")))
                   #t)))))))
      (native-inputs
       (list texlive-bin texlive-docstrip))
      (home-page "https://www.ctan.org/pkg/fontinst")
      (synopsis "Tools for converting and installing fonts for TeX and LaTeX")
      (description "This package provides TeX macros for converting Adobe Font
Metric files to TeX metric and virtual font format.  Fontinst helps mainly
with the number crunching and shovelling parts of font installation.  This
means in practice that it creates a number of files which give the TeX
metrics (and related information) for a font family that TeX needs to do any
typesetting in these fonts.")
      (license license:lppl1.1+))))

(define-deprecated-package texlive-tex-fontinst-base texlive-fontinst)

(define-public texlive-fontname
  (package
    (inherit (simple-texlive-package
              "texlive-fontname"
              (list "/doc/fonts/fontname/fontname.texi"
                    "/fonts/map/fontname/")
              (base32
               "009qvjpw48lajp0gxpvdk10n5qw3q41cpq05ycns67mxwkcaywq6")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/fontname")
    (synopsis "Scheme for naming fonts in TeX")
    (description "This is Fontname, a naming scheme for (the base part of)
external TeX font filenames.  This makes at most eight-character names
from (almost) arbitrarily complex font names, thus helping portability of TeX
documents.")
    (license license:public-domain)))

(define-public texlive-cbfonts          ;71 MiB of greek fonts
  (package
    (inherit (simple-texlive-package
              "texlive-cbfonts"
              (list "/doc/fonts/cbfonts/"
                    "/fonts/type1/public/cbfonts/")
              (base32
               "01j22cbwq9jkni5vvrpz2mg1799cbx3aq801sni74i8wb1zcf6y1")
              #:trivial? #t))
    (propagated-inputs (list texlive-cbfonts-fd))
    (home-page "https://www.ctan.org/pkg/cbgreek-complete")
    (synopsis "Complete set of Greek fonts")
    (description "This bundle presents the whole of Beccari's original Greek
font set, which use the @i{Lispiakos} font shape derived from the shape of the
fonts used in printers' shops in Lispia.  The fonts are available both as
Metafont source and in Adobe Type 1 format, and at the same wide set of design
sizes as are such font sets as the EC fonts.")
    (license license:lppl1.3c+)))

(define-public texlive-cbfonts-fd
  (package
    (inherit (simple-texlive-package
              "texlive-cbfonts-fd"
              (list "/doc/fonts/cbfonts/"
                    "/tex/latex/cbfonts-fd/")
              (base32
               "0g91p2qcgqn916vgf777h45dabv2r6l6f9xkcq0b3gpir3qsj3d4")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/cbfonts-fd")
    (synopsis "LaTeX font description files for the CB Greek fonts")
    (description "The package provides font description files for all the many
shapes available from the cbfonts collection.  The files provide the means
whereby the @acronym{NFSS, New Font Selection Scheme} knows which fonts a
LaTeX user is requesting.

Tip: installing @code{texlive-cbfonts} will automatically propagate this one.")
    (license license:lppl1.3c+)))

(define-public texlive-cite
  (package
    (inherit (simple-texlive-package
              "texlive-cite"
              (list "doc/latex/cite/" "tex/latex/cite/")
              (base32
               "0b1amznayxj80dmqbzcysmj7q8aksbyz98k6djsqi0mhwp1cd0fd")
              #:trivial? #t))
    (version (number->string %texlive-revision))
    (home-page "https://ctan.org/pkg/cite")
    (synopsis "Improved citation handling in LaTeX")
    (description
     "The package supports compressed, sorted lists of numerical citations,
and also deals with various punctuation and other issues of representation,
including comprehensive management of break points.  The package is compatible
with both hyperref and backref.  The package is (unsurprisingly) part of the
cite bundle of the author's citation-related packages.")
    (license (license:fsf-free
              "/share/texmf-dist/doc/latex/cite/README"))))

(define-public texlive-cm
  (let ((template (simple-texlive-package
                   "texlive-cm"
                   (list "/fonts/source/public/cm/"
                         "/fonts/map/dvips/cm/cmtext-bsr-interpolated.map"
                         "/doc/fonts/cm/")
                   (base32
                    "0mfslqs9saqkb3z3xdhsqnklxk858nmipgj1y93by2791jzkma1d")
                   #:trivial? #t)))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:modules modules '())
          '((guix build gnu-build-system)
            (guix build utils)
            (srfi srfi-26)))
         ((#:phases phases)
          `(modify-phases ,phases
             (replace 'build
               (lambda* (#:key inputs #:allow-other-keys)
                 (let ((mf (assoc-ref inputs "texlive-metafont")))
                   ;; Tell mf where to find mf.base
                   (setenv "MFBASES" (string-append mf "/share/texmf-dist/web2c"))
                   ;; Tell mf where to look for source files
                   (setenv "MFINPUTS"
                           (string-append (getcwd) "/fonts/source/public/cm/:"
                                          mf "/share/texmf-dist/metafont/base")))
                 (for-each make-file-writable
                           (cons "fonts/source/public/cm/"
                                 (find-files "fonts/source/public/cm/" ".*")))
                 (let ((build (string-append (getcwd) "/build"))
                       (pkdir (string-append (getcwd) "/pk/ljfour/public/cm/dpi600")))
                   (mkdir-p pkdir)
                   (mkdir-p build)
                   (with-directory-excursion "fonts/source/public/cm/"
                     (for-each (lambda (font)
                                 (format #t "building font ~a\n" font)
                                 (invoke "mf" "-progname=mf"
                                         (string-append "-output-directory=" build)
                                         (string-append "\\"
                                                        "mode:=ljfour; "
                                                        "mag:=1+0/600; "
                                                        "scrollmode; "
                                                        "input "
                                                        (basename font ".mf")))
                                 (invoke "gftopk"
                                         (string-append build "/"
                                                        (basename font ".mf") ".600gf")
                                         (string-append pkdir "/"
                                                        (basename font ".mf") ".pk")))
                               (find-files "." "cm(.*[0-9]+.*|inch)\\.mf$"))))
                 #t))
             (add-after 'install 'install-generated-fonts
               (lambda* (#:key inputs outputs #:allow-other-keys)
                 (let* ((out    (assoc-ref outputs "out"))
                        (fonts  (string-append out "/share/texmf-dist/fonts/"))
                        (pk     (string-append fonts "pk"))
                        (tfm    (string-append fonts "tfm/public/cm")))
                   (for-each (cut install-file <> tfm)
                             (find-files "build" "\\.*"))
                   (copy-recursively "pk" pk)
                   #t)))))))
      (native-inputs
       (list texlive-bin texlive-metafont))
      (home-page "https://www.ctan.org/pkg/cm")
      (synopsis "Computer Modern fonts for TeX")
      (description "This package provides the Computer Modern fonts by Donald
Knuth.  The Computer Modern font family is a large collection of text,
display, and mathematical fonts in a range of styles, based on Monotype Modern
8A.")
      (license license:knuth))))

(define-deprecated-package texlive-fonts-cm texlive-cm)

(define-public texlive-cm-lgc
  (package
    (inherit (simple-texlive-package
              "texlive-cm-lgc"
              (list "/doc/fonts/cm-lgc/"
                    "/fonts/afm/public/cm-lgc/"
                    "/fonts/type1/public/cm-lgc/"
                    "/fonts/vf/public/cm-lgc/"
                    "/tex/latex/cm-lgc/")
              (base32
               "0rm7wgyb07y8h6vbvc2xzsqnxy322d4j9ly2p67z84b81c8i3zpc")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/cm-lgc")
    (synopsis "Type 1 CM-based fonts for Latin, Greek and Cyrillic")
    (description "The fonts are converted from Metafont sources of the
Computer Modern font families, using @command{textrace}.  Supported encodings
are: T1 (Latin), T2A (Cyrillic), LGR (Greek) and TS1.  The package also
includes Unicode virtual fonts for use with Omega.  The font set is not a
replacement for any of the other Computer Modern-based font sets (for example,
cm-super for Latin and Cyrillic, or cbgreek for Greek), since it is available
at a single size only; it offers a compact set for @i{general} working.  The
fonts themselves are encoded to external standards, and virtual fonts are
provided for use with TeX.")
    (license license:gpl2+)))

(define-public texlive-cm-super
  (let ((template (simple-texlive-package
                   "texlive-cm-super"
                   (list "/doc/fonts/cm-super/"
                         "/dvips/cm-super/"
                         "/fonts/afm/public/cm-super/"
                         "/fonts/enc/dvips/cm-super/"
                         "/fonts/map/dvips/cm-super/"
                         "/fonts/map/vtex/cm-super/"
                         "/fonts/type1/public/cm-super/"
                         "/tex/latex/cm-super/")
                   (base32
                    "1k3afl0x0bqbr5mnawbnp7rr2126dwn0vwnxzibm9ggvzqilnkm6")
                   #:trivial? #t)))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:phases phases)
          `(modify-phases ,phases
             (delete 'reset-gzip-timestamps)))))
      (home-page "https://www.ctan.org/pkg/cm-super")
      (synopsis "Computer Modern Super family of fonts")
      (description "The CM-Super family provides Adobe Type 1 fonts that replace
the T1/TS1-encoded Computer Modern (EC/TC), T1/TS1-encoded Concrete,
T1/TS1-encoded CM bright and LH Cyrillic fonts (thus supporting all European
languages except Greek), and bringing many ameliorations in typesetting
quality.  The fonts exhibit the same metrics as the METAFONT-encoded
originals.")
      ;; With font exception
      (license license:gpl2+))))

(define-deprecated-package texlive-fonts-cm-super texlive-cm-super)

(define-public texlive-courier
  (package
    (inherit (simple-texlive-package
              "texlive-courier"
              (list "/dvips/courier/"
                    "/fonts/afm/adobe/courier/"
                    "/fonts/afm/urw/courier/"
                    "/fonts/map/dvips/courier/"
                    "/fonts/tfm/adobe/courier/"
                    "/fonts/tfm/urw35vf/courier/"
                    "/fonts/type1/adobe/courier/"
                    "/fonts/type1/urw/courier/"
                    "/fonts/vf/adobe/courier/"
                    "/fonts/vf/urw35vf/courier/"
                    "/tex/latex/courier/"
                    "/tex4ht/ht-fonts/alias/adobe/courier/"
                    "/tex4ht/ht-fonts/unicode/adobe/courier/")
              (base32
               "05lglavi073glj26k9966351hka5ac22g4vim61dkfy001vz4i7r")
              #:trivial? #t))
    (home-page "https://ctan.org/pkg/urw-base35")
    (synopsis "URW Base 35 font pack for LaTeX")
    (description "This package provides a drop-in replacements for the Courier
font from Adobe's basic set.")
    ;; No license version specified.
    (license license:gpl3+)))

(define-public texlive-tex-gyre
  (package
    (inherit (simple-texlive-package
              "texlive-tex-gyre"
              '("/doc/fonts/tex-gyre/GUST-FONT-LICENSE.txt"
                "/fonts/afm/public/tex-gyre/"
                "/fonts/enc/dvips/tex-gyre/"
                "/fonts/map/dvips/tex-gyre/"
                "/fonts/opentype/public/tex-gyre/"
                "/fonts/tfm/public/tex-gyre/"
                "/fonts/type1/public/tex-gyre/"
                "/tex/latex/tex-gyre/")
              (base32
               "1ldnlmclghm3gnyv02r8a6cqybygz2ifq07mhykhf43h1pw3aq7k")
              #:trivial? #t))
    (home-page "https://ctan.org/pkg/tex-gyre")
    (synopsis "TeX fonts extending URW fonts")
    (description
     "The TeX-GYRE bundle consist of multiple font families:
@itemize @bullet
@item Adventor, based on the URW Gothic L family of fonts;
@item Bonum, based on the URW Bookman L family;
@item Chorus, based on URW Chancery L Medium Italic;
@item Cursor, based on URW Nimbus Mono L;
@item Heros, based on URW Nimbus Sans L;
@item Pagella, based on URW Palladio L;
@item Schola, based on the URW Century Schoolbook L family;
@item Termes, based on the URW Nimbus Roman No9 L family of fonts.
@end itemize

The constituent standard faces of each family have been greatly extended
(though Chorus omits Greek support and has no small-caps family).  Each
family is available in Adobe Type 1 and Open Type formats, and LaTeX
support (for use with a variety of encodings) is provided.")
    ;; The GUST font license (GFL) is legally identical to the LaTeX Project
    ;; Public License (LPPL), version 1.3c or later, but comes with an
    ;; additional but not legally binding clause.
    (license license:lppl1.3c+)))

(define-public texlive-ctablestack
  (package
    (name "texlive-ctablestack")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/luatex/ctablestack/"
                   "source/luatex/ctablestack/"
                   "tex/luatex/ctablestack/")
             (base32
              "13l779436aj3hlchwvhkpiikbyfa2j4swzfrwqkjh9l8bc2cwg7n")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/ctablestack")
    (synopsis "Catcode table stable support")
    (description
     "This package provides a method for defining category code table stacks
in LuaTeX.  It is required by the @code{luatexbase} package which uses
@code{ctablestack} to provide a back-compatibility form of this concept.")
    (license license:lppl1.3+)))

(define-public texlive-lm
  (package
    (inherit (simple-texlive-package
              "texlive-lm"
              (list "/doc/fonts/lm/"
                    "/fonts/afm/public/lm/"
                    "/fonts/enc/dvips/lm/"
                    "/fonts/map/dvipdfm/lm/"
                    "/fonts/map/dvips/lm/"
                    "/fonts/opentype/public/lm/"
                    "/fonts/tfm/public/lm/"
                    "/fonts/type1/public/lm/"
                    "/tex/latex/lm/")
              (base32
               "0yyk0dr4yms82mwy4dc03zf5igyhgcb65icdah042rk23rlpxygv")
              #:trivial? #t))
    (home-page "https://www.gust.org.pl/projects/e-foundry/latin-modern/")
    (synopsis "Latin Modern family of fonts")
    (description "The Latin Modern fonts are derived from the famous Computer
Modern fonts designed by Donald E. Knuth and described in Volume E of his
Computers & Typesetting series.")
    ;; The GUST font license (GFL) is legally identical to the LaTeX Project
    ;; Public License (LPPL), version 1.3c or later, but comes with an
    ;; additional but not legally binding clause.
    (license license:lppl1.3c+)))

(define-deprecated-package texlive-fonts-lm texlive-lm)

(define-public texlive-lm-math
  (package
    (inherit (simple-texlive-package
              "texlive-lm-math"
              (list "/doc/fonts/lm-math/"
                    "/fonts/opentype/public/lm-math/")
              (base32
               "0gqdk8x3r1iz4n8j6r3pcqbwalxvkihayvmjfq4iv6hwb0pvys8z")
              #:trivial? #t))
    (home-page "https://www.gust.org.pl/projects/e-foundry/latin-modern")
    (synopsis "OpenType maths fonts for Latin Modern")
    (description "Latin Modern Math is a maths companion for the Latin Modern
family of fonts, in OpenType format.  For use with LuaLaTeX or XeLaTeX,
support is available from the @code{unicode-math} package.")
    (license license:gfl1.0)))

(define-public texlive-lwarp
  (package
    (name "texlive-lwarp")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/lwarp/"
                   "scripts/lwarp/"
                   "source/latex/lwarp/"
                   "tex/latex/lwarp/")
             (base32
              "0pv3gvy01zkhk39ybjix5lh3x6q4r9pvabrx1wvqr96ma8gyzr5n")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-minitoc))
    (home-page "https://ctan.org/pkg/lwarp")
    (synopsis "Converts LaTeX to HTML")
    (description
     "This package converts LaTeX to HTML by using LaTeX to process the user's
document and generate HTML tags.  External utility programs are only used for
the final conversion of text and images.  Math may be represented by SVG files
or MathJax.  Hundreds of LaTeX packages are supported, and their load order is
automatically verified.  Documents may be produced by LaTeX, LuaLaTeX,
XeLaTeX, and by several CJK engines, classes, and packages.  A texlua script
automates compilation, index, glossary, and batch image processing, and also
supports latexmk.  Configuration is semi-automatic at the first manual
compile.  Support files are self-generated.  Print and HTML versions of each
document may coexist.  Assistance is provided for HTML import into EPUB
conversion software and word processors.")
    (license license:lppl1.3+)))

(define-public texlive-knuth-lib
  (let ((template (simple-texlive-package
                   "texlive-knuth-lib"
                   (list "/fonts/source/public/knuth-lib/"
                         "/tex/generic/knuth-lib/"
                         "/tex/plain/knuth-lib/")
                   (base32
                    "1cxyqqprp8sj2j4zp9l0wry8cq2awpz3a8i5alzpc4ndg7a6pgdf")
                   #:trivial? #t)))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:modules _ '())
          '((guix build gnu-build-system)
            (guix build utils)
            (srfi srfi-26)))
         ((#:phases phases '())
          `(modify-phases ,phases
             (replace 'build
               (lambda* (#:key inputs #:allow-other-keys)
                 (with-directory-excursion "fonts/source/public/knuth-lib"
                   (let ((mf (assoc-ref inputs "texlive-metafont")))
                     ;; Tell mf where to find mf.base
                     (setenv "MFBASES"
                             (string-append mf "/share/texmf-dist/web2c"))
                     ;; Tell mf where to look for source files
                     (setenv "MFINPUTS"
                             (string-append (getcwd) ":"
                                            mf "/share/texmf-dist/metafont/base")))
                   (mkdir "build")
                   (for-each (lambda (font)
                               (format #t "building font ~a\n" font)
                               (invoke "mf" "-progname=mf"
                                       "-output-directory=build"
                                       (string-append "\\"
                                                      "mode:=ljfour; "
                                                      "mag:=1; "
                                                      "batchmode; "
                                                      "input " font)))
                             (find-files "." "(manfnt|logo.+)\\.mf$")))
                 #t))
             (add-after 'install 'install-fonts
               (lambda* (#:key outputs #:allow-other-keys)
                 (with-directory-excursion "fonts/source/public/knuth-lib"
                   (let* ((out (assoc-ref outputs "out"))
                          (tfm (string-append
                                out "/share/texmf-dist/fonts/tfm/public/knuth-lib")))
                     (for-each (cut install-file <> tfm)
                               (find-files "build" "\\.tfm"))
                     #t))))))))
      (native-inputs
       (list texlive-bin texlive-metafont))
      (home-page "https://www.ctan.org/pkg/knuth-lib")
      (synopsis "Small library of METAFONT sources")
      (description "This is a collection of core TeX and METAFONT macro files
from Donald Knuth, including the plain format, plain base, and the MF logo
fonts.")
      (license license:knuth))))

(define-deprecated-package texlive-fonts-knuth-lib texlive-knuth-lib)

(define-public texlive-latex-fonts
  (package
    (name "texlive-latex-fonts")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/latex-fonts/"
                   "fonts/source/public/latex-fonts/"
                   "fonts/tfm/public/latex-fonts/")
             (base32
              "1bzqzzhs15w7dqz90hfjnaffjqh24q14w2h1h8vnxzvrlsyv21vq")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:texlive-latex-base #f
      #:modules
      '((guix build texlive-build-system)
        (guix build utils)
        (srfi srfi-1)
        (srfi srfi-26))
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'install 'generate-fonts-metrics
            (lambda _
              (let ((cm #$(this-package-native-input "texlive-cm"))
                    (metafont #$(this-package-native-input "texlive-metafont"))
                    (fonts-directories
                     (delete-duplicates
                      (map (lambda (f)
                             (string-drop (dirname f) (string-length "./")))
                           (find-files "." "[0-9]+\\.mf$"))))
                    (root (getcwd)))
                (mkdir-p "build")
                ;; Tell mf where to find mf.base.
                (setenv "MFBASES"
                        (string-append metafont "/share/texmf-dist/web2c/"))
                (for-each
                 (lambda (directory)
                   ;; Tell mf where to look for source files.
                   (setenv "MFINPUTS"
                           (string-append
                            (getcwd) "/" directory ":"
                            metafont "/share/texmf-dist/metafont/base/:"
                            cm "/share/texmf-dist/fonts/source/public/cm/"))
                   ;; Build font metrics (tfm).
                   (with-directory-excursion directory
                     (for-each (lambda (font)
                                 (format #t "building font ~a\n" font)
                                 (invoke "mf" "-progname=mf"
                                         (string-append "-output-directory="
                                                        root "/build")
                                         (string-append "\\"
                                                        "mode:=ljfour; "
                                                        "mag:=1; "
                                                        "batchmode; "
                                                        "input "
                                                        (basename font ".mf"))))
                               (find-files "." "[0-9]+\\.mf$")))
                   ;; Install font metrics at the appropriate location.
                   (let ((destination
                          ;; fonts/source/xxx/yyy/... -> fonts/tfm/xxx/yyy/...
                          (string-append "fonts/tfm"
                                         (string-drop
                                          directory
                                          (string-length "fonts/source")))))
                     (format #t "moving font metrics in ~a\n" destination)
                     (for-each (cut install-file <> destination)
                               (find-files "build/" "\\.tfm$"))))
                 fonts-directories)))))))
    (native-inputs
     (list texlive-bin texlive-cm texlive-metafont))
    (home-page "https://ctan.org/pkg/latex-fonts")
    (synopsis "Collection of fonts used in LaTeX distributions")
    (description
     "This is a collection of fonts for use with standard LaTeX packages and
classes. It includes invisible fonts (for use with the slides class), line and
circle fonts (for use in the picture environment) and LaTeX symbol fonts.")
    (license license:lppl1.2+)))

(define-deprecated-package texlive-fonts-latex texlive-latex-fonts)

(define-public texlive-mflogo
  (let ((template (simple-texlive-package
                   "texlive-mflogo"
                   (list "/doc/latex/mflogo/"
                         "/source/latex/mflogo/"
                         "/fonts/source/public/mflogo/logosl8.mf")
                   (base32
                    "1vb4mg7fh4k54g7nqwiw3qm4iir8whpfnspis76l4sddzar1amh7"))))
    (package
      (inherit template)
      (native-inputs
       (list texlive-bin texlive-metafont texlive-knuth-lib))
      (home-page "http://www.ctan.org/pkg/mflogo")
      (synopsis "LaTeX support for Metafont logo fonts")
      (description
       "This package provides LaTeX and font definition files to access the
Knuthian mflogo fonts described in The Metafontbook and to typeset Metafont
logos in LaTeX documents.")
      (license license:lppl))))

(define-deprecated-package texlive-latex-mflogo texlive-mflogo)

(define-public texlive-mflogo-font
  (package
    (inherit (simple-texlive-package
              "texlive-mflogo-font"
              (list "/doc/fonts/mflogo-font/README"
                    "/fonts/afm/hoekwater/mflogo-font/"
                    "/fonts/map/dvips/mflogo-font/"
                    "/fonts/type1/hoekwater/mflogo-font/")
              (base32
               "094mknjv8ki2pvj1zin0f1z4f1w12g0cfqjiqcsawjsry4yfrmbg")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/mflogo-font")
    (synopsis "Metafont logo font")
    (description
     "These fonts were created in METAFONT by Knuth, for his own publications.
At some stage, the letters P and S were added, so that the METAPOST logo could
also be expressed.  The fonts were originally issued (of course) as METAFONT
source; they have since been autotraced and reissued in Adobe Type 1 format by
Taco Hoekwater.")
    (license license:knuth)))

(define-deprecated-package texlive-fonts-mflogo-font texlive-mflogo-font)

(define-public texlive-amsfonts
  (let ((template (simple-texlive-package
                   "texlive-amsfonts"
                   (list "/source/latex/amsfonts/"
                         "/fonts/source/public/amsfonts/"
                         "/fonts/type1/public/amsfonts/"
                         "/fonts/afm/public/amsfonts/"
                         "/fonts/tfm/public/amsfonts/"
                         "/fonts/map/dvips/amsfonts/"
                         "/tex/plain/amsfonts/"
                         "/doc/fonts/amsfonts/")
                   (base32
                    "1rpl87643q8v6gcqsz68mjha8wac6cqx7mr16ds8f0ccbw7a4w9b"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:build-targets _ #t)
          '(list "amsfonts.ins"))))
      (home-page "https://www.ctan.org/pkg/amsfonts")
      (synopsis "TeX fonts from the American Mathematical Society")
      (description
       "This package provides an extended set of fonts for use in mathematics,
including: extra mathematical symbols; blackboard bold letters (uppercase
only); fraktur letters; subscript sizes of bold math italic and bold Greek
letters; subscript sizes of large symbols such as sum and product; added sizes
of the Computer Modern small caps font; cyrillic fonts (from the University of
Washington); Euler mathematical fonts.  All fonts are provided as Adobe Type 1
files, and all except the Euler fonts are provided as Metafont source.  The
distribution also includes the canonical Type 1 versions of the Computer
Modern family of fonts.  The Euler fonts are supported by separate packages;
details can be found in the documentation.")
      (license license:silofl1.1))))

(define-deprecated-package texlive-fonts-amsfonts texlive-amsfonts)

(define-deprecated-package texlive-latex-amsfonts texlive-amsfonts)

(define-public texlive-mkpattern
  (package
    (inherit (simple-texlive-package
              "texlive-mkpattern"
              (list "/doc/plain/mkpattern/README"
                    "/doc/plain/mkpattern/mkpatdoc.tex"
                    "/doc/plain/mkpattern/mkpatter.pdf"
                    "/doc/plain/mkpattern/mkpattern-exmpl.tex"
                    "/tex/plain/mkpattern/mkpatter.tex")
              (base32
               "0sxnkbcc802jl3fj56x9hvg978bpv15lhrwj0aykb4syq29l47ga")
              #:trivial? #t))
    (home-page "https://ctan.org/pkg/mkpattern")
    (synopsis "Utility for making hyphenation patterns")
    (description "Mkpattern is a general purpose program for the generation of
hyphenation patterns, with definition of letter sets and template-like
constructions.  It also provides an easy way to handle different input and
output encodings, and features generation of clean UTF-8 patterns.")
    (license license:lppl)))

;; This provides etex.src which is needed to build various formats, including
;; luatex.fmt and pdflatex.fmt
(define-public texlive-etex
  (let ((template (simple-texlive-package
                   "texlive-etex"
                   (list "/doc/etex/base/"
                         "/doc/man/man1/etex.1"
                         "/doc/man/man1/etex.man1.pdf"
                         "/tex/plain/etex/"
                         "/fonts/source/public/etex/")
                   (base32
                    "1qv6vxm5a8pw38gas3i69ivmsn79zj2yq5n5vdmh0rzic5hw2hmc")
                   #:trivial? #t)))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:phases phases)
          `(modify-phases ,phases
             ;; Build tfm font.
             (replace 'build
               (lambda* (#:key inputs #:allow-other-keys)
                 (let ((mf (assoc-ref inputs "texlive-metafont")))
                   ;; Tell mf where to find mf.base
                   (setenv "MFBASES" (string-append mf "/share/texmf-dist/web2c"))
                   ;; Tell mf where to look for source files
                   (setenv "MFINPUTS"
                           (string-append (getcwd)
                                          "/fonts/source/public/etex/:"
                                          mf "/share/texmf-dist/metafont/base:"
                                          (assoc-ref inputs "texlive-cm")
                                          "/share/texmf-dist/fonts/source/public/cm")))
                 (invoke "mf" "-progname=mf"
                         (string-append "\\"
                                        "mode:=ljfour; "
                                        "mag:=1; "
                                        "scrollmode; "
                                        "input xbmc10"))
                 #t))
             (add-after 'install 'install-font
               (lambda* (#:key outputs #:allow-other-keys)
                 (install-file
                  "xbmc10.tfm"
                  (string-append (assoc-ref outputs "out")
                                 "/share/texmf-dist/fonts/tfm/public/etex/"))
                 #t))))))
      (native-inputs
       (list texlive-bin texlive-metafont texlive-cm))
      (home-page "https://www.ctan.org/pkg/etex")
      (synopsis "Extended version of TeX")
      (description
       "This package provides an extended version of TeX (which is capable of
running as if it were TeX unmodified).  E-TeX has been specified by the LaTeX
team as the engine for the development of LaTeX2e; as a result, LaTeX
programmers may assume e-TeX functionality.  The pdftex engine directly
incorporates the e-TeX extensions.")
      (license license:knuth))))

(define-public texlive-plain
  (package
    (name "texlive-plain")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "makeindex/plain/" "tex/plain/base/"
                   "tex/plain/config/")
             (base32
              "0zwvrfw8z28c9dy8nby5qfwbyrd2a0cdfwyd5jndscjczhw0yi62")))
    (build-system texlive-build-system)
    (arguments
     (list
      #:tex-engine "tex"
      #:tex-format #f
      #:texlive-latex-base #f))
    (home-page "https://ctan.org/pkg/plain")
    (synopsis "Plain TeX format and supporting files")
    (description
     "This package contains files used to build the Plain TeX format, as
described in the TeXbook, together with various supporting files (some also
discussed in the book).")
    (license license:knuth)))

(define-deprecated-package texlive-tex-plain texlive-plain)

(define-public texlive-halloweenmath
  (let ((template (simple-texlive-package
                   "texlive-halloweenmath"
                   (list "doc/latex/halloweenmath/"
                         "source/latex/halloweenmath/"
                         "tex/latex/halloweenmath/")
                   (base32
                    "1xq72k1p820b5q3haxf936g69p6gv34hr30870l96jnxa3ad7y05"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t) "latex/halloweenmath")
         ((#:build-targets _ '()) '(list "halloweenmath.ins"))
         ((#:phases phases)
          #~(modify-phases #$phases
              (add-after 'chdir 'non-interactive-build
                ;; When it realizes it cannot employ the usedir directive, the
                ;; build process stops and waits for an input before inserting
                ;; generated files in the working directory.  Do not ask for
                ;; an input.
                (lambda _
                  (substitute* "source/latex/halloweenmath/halloweenmath.ins"
                    (("\\Ask.*") "")
                    (("\\(your .*? will be ignored\\).*") ""))))))))
      (native-inputs
       (list texlive-bin
             texlive-kpathsea
             (texlive-updmap.cfg)))     ;for psfonts.map
      (propagated-inputs
       (list texlive-amsmath texlive-pict2e))
      (home-page "https://ctan.org/pkg/halloweenmath")
      (synopsis "Scary and creepy math symbols with AMS-LaTeX integration")
      (description
       "The package defines a handful of commands for typesetting mathematical
symbols of various kinds, ranging from large operators to extensible
arrow-like relations and growing arrow-like math accents that all draw from
the classic Halloween-related iconography (pumpkins, witches, ghosts, cats,
and so on) while being, at the same time, seamlessly integrated within the
rest of the mathematics produced by (AmS-)LaTeX.")
      (license license:lppl1.3+))))

(define-public texlive-hardwrap
  (package
    (inherit (simple-texlive-package
              "texlive-hardwrap"
              (list "doc/latex/hardwrap/"
                    "tex/latex/hardwrap/"
                    "source/latex/hardwrap/")
              (base32
               "0ql3xml1ccll44q945n7w72p6d51y5wcrkawi7cg621gy5d6wzx5")
              #:trivial? #t))
    (home-page "https://ctan.org/macros/latex/contrib/hardwrap")
    (synopsis "Hard wrap text to a certain character length")
    (description
     "The package facilitates wrapping text to a specific character width, breaking
lines by words rather than, as done by TeX, by characters.  The primary use for
these facilities is to aid the generation of messages sent to the log file or
console output to display messages to the user.  Package authors may also find
this useful when writing out arbitrary text to an external file.")
    (license license:lppl1.3+)))

(define-public texlive-helvetic
  (package
    (inherit (simple-texlive-package
              "texlive-helvetic"
              (list "/dvips/helvetic/"
                    "/fonts/afm/adobe/helvetic/"
                    "/fonts/afm/urw/helvetic/"
                    "/fonts/map/dvips/helvetic/"
                    "/fonts/tfm/adobe/helvetic/"
                    "/fonts/tfm/monotype/helvetic/"
                    "/fonts/tfm/urw35vf/helvetic/"
                    "/fonts/type1/urw/helvetic/"
                    "/fonts/vf/adobe/helvetic/"
                    "/fonts/vf/monotype/helvetic/"
                    "/fonts/vf/urw35vf/helvetic/"
                    "/tex/latex/helvetic/")
              (base32
               "0c3f1ly7y6404z0akbfbbfql13sz717v0n0g69qjpr69hi4n0nsl")
              #:trivial? #t))
    (home-page "https://ctan.org/pkg/urw-base35")
    (synopsis "URW Base 35 font pack for LaTeX")
    (description "This package provides a drop-in replacements for the Helvetica
font from Adobe's basic set.")
    ;; No license version specified.
    (license license:gpl3+)))

(define-public texlive-hyphen-afrikaans
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-afrikaans" "af"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-af.tex")
              (base32
               "1k9k27a27bbrb0gz36191w32l2v6d3zbdh8zhrp4l3ild2pj3n4l")))
    (synopsis "Hyphenation patterns for Afrikaans")
    (description "The package provides hyphenation patterns for the Afrikaans
language.")
    (license license:lppl1.3+)))

(define-public texlive-hyphen-ancientgreek
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-ancientgreek" "grc"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-grc.tex"
                    "/tex/generic/hyphen/grahyph5.tex"
                    "/tex/generic/hyphen/ibyhyph.tex")
              (base32
               "01326lb6z0s8krcfgs8i1pnjfrm4gr33rc53gy80f63qbv4ssxrw")))
    (synopsis "Hyphenation patterns for ancient Greek")
    (description "The package provides hyphenation patterns for ancient
Greek.")
    (license license:lppl1.3+)))

(define-public texlive-hyphen-armenian
  (let ((template (texlive-hyphen-package
                   "texlive-hyphen-armenian" "hy"
                   (list "/tex/generic/hyph-utf8/patterns/tex/hyph-hy.tex")
                   (base32
                    "0hzny0npynsb07syxrpbfa5pkpj8r0j51pj64yxyfl1c0bak1fwp"))))
    (package
      (inherit template)
      (synopsis "Hyphenation patterns for Armenian")
      (description "The package provides hyphenation patterns for the Armenian
language.")
      ;; Any version of the LGPL.
      (license license:lgpl3+))))

(define-public texlive-hyphen-basque
  (let ((template (texlive-hyphen-package
                    "texlive-hyphen-basque" "eu"
                    (list "/tex/generic/hyph-utf8/patterns/tex/hyph-eu.tex")
                    (base32
                     "15w969g1jqzn68l2b2lzf7iv7g3kil02aba3if6cag3qcnq92ra9"))))
    (package
      (inherit template)
      (synopsis "Hyphenation patterns for Basque")
      (description "The package provides hyphenation patterns for the Basque
language.")
      ;; Similar to Unicode license.
      (license (license:fsf-free
                "/tex/generic/hyph-utf8/patterns/tex/hyph-eu.tex")))))

(define-public texlive-hyphen-belarusian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-belarusian" "be"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-be.tex")
              (base32
               "0ppm12wndaxv9da62dwkbnk7w9nijikn6jkc97m76xis338g2h02")))
    (synopsis "Hyphenation patterns for Belarusian")
    (description "The package provides hyphenation patterns for the Belarusian
language.")
    (license license:expat)))

(define-public texlive-hyphen-bulgarian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-bulgarian" "bg"
              '("/tex/generic/hyph-utf8/patterns/tex/hyph-bg.tex")
              (base32
               "0m254y71j3qrb71klvfalfmic3kjy31l85b9cgpdm5yznlsq3i8d")))
    (synopsis "Hyphenation patterns for Bulgarian")
    (description "The package provides hyphenation patterns for the Bulgarian
language in T2A and UTF-8 encodings.")
    (license (license:non-copyleft
              "file:///tex/generic/hyph-utf8/patterns/tex/hyph-bg.tex"
              "Ancestral BSD variant"))))

(define-public texlive-hyphen-catalan
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-catalan" "ca"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-ca.tex")
              (base32
               "10zzlfz5v8d9csg85ibpp2vfvmpqa56vbl85qy5gws099vygpayg")))
    (synopsis "Hyphenation patterns for Catalan")
    (description "The package provides hyphenation patterns for Catalan in
T1/EC and UTF-8 encodings.")
    (license license:lppl1.0+)))

(define-public texlive-hyphen-chinese
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-chinese" "zh-latn-pinyin"
              '("/tex/generic/hyph-utf8/patterns/ptex/hyph-zh-latn-pinyin.ec.tex"
                "/tex/generic/hyph-utf8/patterns/tex/hyph-zh-latn-pinyin.tex")
              (base32
               "1hhh30hcjymm2igpllly04cavsfmd6xrjkd9zax6b2wdxn3ka4pm")))
    (synopsis "Hyphenation patterns for unaccented Chinese pinyin")
    (description "The package provides hyphenation patterns for unaccented
Chinese pinyin T1/EC and UTF-8 encodings.")
    (license license:gpl2+)))

(define-public texlive-hyphen-churchslavonic
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-churchslavonic" "cu"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-cu.tex")
              (base32
               "0fhbwaapq2213msbhgr0d1lw06ihmrqirxj092mn73d8ynl13qlh")))
    (synopsis "Hyphenation patterns for Church Slavonic")
    (description "The package provides hyphenation patterns for Church
Slavonic in UTF-8 encoding.")
    (license license:expat)))

(define-public texlive-hyphen-coptic
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-coptic" "cop"
              (list "/tex/generic/hyph-utf8/patterns/tex-8bit/copthyph.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-cop.tex")
              (base32
               "1jlxxvyfa2aljizaa3qlcxyhqsrb4dawv3q3fbyp2lxz6ag9fy6m")))
    (synopsis "Hyphenation patterns for Coptic")
    (description "The package provides hyphenation patterns for Coptic in
UTF-8 encoding as well as in ASCII-based encoding for 8-bit engines.")
    ;; No explicit license declaration, so we use the project license.
    (license license:lppl)))

(define-public texlive-hyphen-croatian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-croatian" "hr"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-hr.tex")
              (base32
               "12n9r2winai15jc622sqdwclgcs1s68r6vcf7ic8vvq0x9qhwc5v")))
    (synopsis "Hyphenation patterns for Croatian")
    (description "The package provides hyphenation patterns for Croatian in
T1/EC and UTF-8 encodings.")
    (license license:lppl1.0+)))

(define-public texlive-hyphen-czech
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-czech" "cs"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-cs.tex")
              (base32
               "1q37s6p8yfyi3rp1azbz421lg4lr4aiki8m631i4x9rmps89m8iq")))
    (synopsis "Hyphenation patterns for Czech")
    (description "The package provides hyphenation patterns for Czech in T1/EC
and UTF-8 encodings.")
    (license license:gpl2+)))

(define-public texlive-hyphen-danish
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-danish" "da"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-da.tex")
              (base32
               "1vj8nip64rzcrcg3skm4vqad1ggqwgan74znrdns610wjcm1z9qd")))
    (synopsis "Hyphenation patterns for Danish")
    (description "The package provides hyphenation patterns for Danish in
T1/EC and UTF-8 encodings.")
    ;; Either LPPL 1.3 or later, or Expat
    (license (list license:lppl1.3+ license:expat))))

(define-public texlive-hyphen-dutch
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-dutch" "nl"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-nl.tex")
              (base32
               "1bg9g790ksq5cn8qihai6pacmkp9vpf35h4771z361nvwa40l8yk")))
    (synopsis "Hyphenation patterns for Dutch")
    (description "The package provides hyphenation patterns for Dutch in T1/EC
and UTF-8 encodings.")
    (license license:lppl1.0+)))

(define-public texlive-hyphen-english
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-english" '("en-gb" "en-us")
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-en-gb.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-en-us.tex")
              (base32
               "08b3jihjaamcl1pvffi0s47nwavkm66l9mrrmby3l32dfpkprrc5")))
    (synopsis "Hyphenation patterns for American and British English")
    (description "The package provides additional hyphenation patterns for
American and British English in ASCII encoding.")
    (license (license:non-copyleft
              "file:///tex/generic/hyph-utf8/patterns/tex/hyph-en-us.tex"
              "FSF all permissive license"))))

(define-public texlive-hyphen-esperanto
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-esperanto" "eo"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-eo.tex")
              (base32
               "1503kzn9bk4mm4ba35cka2hm8rz0v3j5l30v5rrsd4rqgpibcgic")))
    (synopsis "Hyphenation patterns for Esperanto")
    (description "The package provides hyphenation patterns for Esperanto ISO
Latin 3 and UTF-8 encodings.")
    (license license:lppl1.0+)))

(define-public texlive-hyphen-estonian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-estonian" "et"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-et.tex")
              (base32
               "1rdas2450ib02rwy65i69l86nyc9h15bl07xbbwhmhxfnj8zj4v8")))
    (synopsis "Hyphenation patterns for Estonian")
    (description "The package provides hyphenation patterns for Estonian in
T1/EC and UTF-8 encodings.")
    ;; Dual licensed under either license.
    (license (list license:lppl1.3+ license:expat))))

(define-public texlive-hyphen-ethiopic
  (let ((template (texlive-hyphen-package
                   "texlive-hyphen-ethiopic" "mul-ethi"
                   (list "/tex/generic/hyph-utf8/patterns/tex/hyph-mul-ethi.tex")
                   (base32
                    "1b93fc6j4aybh0pgq23hsn1njm6asf7sfz803fbj3ai0whsxd10l"))))
    (package
      (inherit template)
      (synopsis "Hyphenation patterns for Ethiopic scripts")
      (description "The package provides hyphenation patterns for languages
written using the Ethiopic script for Unicode engines.  They are not supposed
to be linguistically relevant in all cases and should, for proper typography,
be replaced by files tailored to individual languages.")
      (license license:expat))))

(define-public texlive-hyphen-finnish
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-finnish" "fi"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-fi.tex")
              (base32
               "1pa8sjs9zvnv1y6dma4s60sf9cr4zrvhxwm6i8cnshm84q16w4bc")))
    (synopsis "Hyphenation patterns for Finnish")
    (description "The package provides hyphenation patterns for Finnish in
T1/EC and UTF-8 encodings.")
    (license license:public-domain)))

(define-public texlive-hyphen-schoolfinnish
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-schoolfinnish" "fi-x-school"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-fi-x-school.tex")
              (base32
               "1w5n6gaclgifbbnafg32vz3mfaibyldvh4yh1ya3sq9fwfmv035c")))
    (synopsis "Hyphenation patterns for Finnish for school")
    (description "The package provides hyphenation patterns for Finnish for
school in T1/EC and UTF-8 encodings.")
    (license license:public-domain)))

(define-public texlive-hyphen-french
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-french" "fr"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-fr.tex")
              (base32
               "0jc3kqys6cxjw8x8pzjln7z78l8s7f5rlyrkv7dzr1kiwnwilk9d")))
    (synopsis "Hyphenation patterns for French")
    (description "The package provides hyphenation patterns for French in
T1/EC and UTF-8 encodings.")
    (license license:expat)))

(define-public texlive-hyphen-friulan
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-friulan" "fur"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-fur.tex")
              (base32
               "1dlnh8slpf50mryxv7zzbx08xp54zkdfs1j7y37ipwbrajvd740f")))
    (synopsis "Hyphenation patterns for Friulan")
    (description "The package provides hyphenation patterns for Friulan in
ASCII encodings.")
    (license license:lppl1.3+)))

(define-public texlive-hyphen-galician
  (let ((template (texlive-hyphen-package
                   "texlive-hyphen-galician" "gl"
                   (list "/tex/generic/hyph-utf8/patterns/tex/hyph-gl.tex")
                   (base32
                    "13zx2r3nrxdr025g2lxrph0ga6wf7cs8dxixn4fhbl6xr1cx028g"))))
    (package
      (inherit template)
      (synopsis "Hyphenation patterns for Galician")
      (description "The package provides hyphenation patterns for Galician in
T1/EC and UTF-8 encodings.")
      (license license:lppl1.3))))

(define-public texlive-hyphen-georgian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-georgian" "ka"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-ka.tex")
              (base32
               "0l0hk7ka04fr8x11nnw95x151cxyycy0fph772m3a3p8qk4x9wp7")))
    (synopsis "Hyphenation patterns for Georgian")
    (description "The package provides hyphenation patterns for Georgian in
T8M, T8K, and UTF-8 encodings.")
    (license license:lppl1.3+)))

(define-public texlive-hyphen-german
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-german" '("de-1901" "de-1996" "de-ch-1901")
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-de-1901.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-de-1996.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-de-ch-1901.tex"
                    "/tex/generic/dehyph/dehyphn.tex"
                    "/tex/generic/dehyph/dehypht.tex"
                    "/tex/generic/dehyph/dehyphtex.tex"
                    "/tex/generic/dehyph/README")
              (base32
               "17cc5hd0fr3ykpgly9nxaiz4sik3kmfn2wyxz1fkdnqqhl3i41a0")))
    (synopsis "Hyphenation patterns for German")
    (description "This package provides hyphenation patterns for German in
T1/EC and UTF-8 encodings, for traditional and reformed spelling, including
Swiss German.")
    ;; The patterns are released under the Expat license; the dehyph* files
    ;; are released under the LPPL version 1 or later.
    (license (list license:expat license:lppl1.0+))))

(define-public texlive-hyphen-greek
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-greek" '("el-monoton" "el-polyton")
              (list "/doc/generic/elhyphen/"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-el-monoton.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-el-polyton.tex"
                    "/tex/generic/hyphen/grmhyph5.tex"
                    "/tex/generic/hyphen/grphyph5.tex")
              (base32
               "1qyr6m1nh6d4wj68616cfxv4wjpiy1w2rlldxlx2ajzba381w3hf")))
    (synopsis "Hyphenation patterns for Greek")
    (description "This package provides hyphenation patterns for Modern Greek
in monotonic and polytonic spelling in LGR and UTF-8 encodings.")
    (license license:lppl)))

(define-public texlive-hyphen-hungarian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-hungarian" "hu"
              (list "/doc/generic/huhyphen/"
                    "/doc/generic/hyph-utf8/languages/hu/"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-hu.tex")
              (base32
               "006d2290lcsqzh9ljansbaj9k52s17zgkw0kpsspn5l7a8n00zcl")))
    (synopsis "Hyphenation patterns for Hungarian")
    (description "This package provides hyphenation patterns for Hungarian in
T1/EC and UTF-8 encodings.")
    ;; Any of these licenses
    (license (list license:gpl2 license:lgpl2.1+ license:mpl1.1))))

(define-public texlive-hyphen-icelandic
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-icelandic" "is"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-is.tex")
              (base32
               "1m9xj41csj3ldym09d82zjbd3345sg2z10d8pxpvhgibf97mb66h")))
    (synopsis "Hyphenation patterns for Icelandic")
    (description "This package provides hyphenation patterns for Icelandic in
T1/EC and UTF-8 encodings.")
    (license license:lppl1.2+)))

(define-public texlive-hyphen-indic
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-indic"
              '("as" "bn" "gu" "hi" "kn" "ml" "mr" "or" "pa" "ta" "te")
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-as.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-bn.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-gu.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-hi.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-kn.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-ml.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-mr.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-or.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-pa.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-ta.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-te.tex")
              (base32
               "02d2kcd3lpk95fykjwhzw9s2a1s2w1skz8h2mmszrz979d1xzhpm")))
    (synopsis "Indic hyphenation patterns")
    (description "This package provides hyphenation patterns for Assamese,
Bengali, Gujarati, Hindi, Kannada, Malayalam, Marathi, Oriya, Panjabi, Tamil
and Telugu for Unicode engines.")
    (license license:expat)))

(define-public texlive-hyphen-indonesian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-indonesian" "id"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-id.tex")
              (base32
               "1r62w02rf0i4z0jgij54d16qjbj0zyfwm9dwdkqka76jrivij83q")))
    (synopsis "Indonesian hyphenation patterns")
    (description "This package provides hyphenation patterns for
Indonesian (Bahasa Indonesia) in ASCII encoding.  They are probably also
usable for Malay (Bahasa Melayu).")
    (license license:gpl2)))

(define-public texlive-hyphen-interlingua
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-interlingua" "ia"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-ia.tex")
              (base32
               "0a9na20vjnzhgjbicaxay0jk4rm5zg1rjyiswr377mjhd9mx5cg3")))
    (synopsis "Interlingua hyphenation patterns")
    (description "This package provides hyphenation patterns for Interlingua
in ASCII encoding.")
    (license license:lppl1.3+)))

(define-public texlive-hyphen-irish
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-irish" "ga"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-ga.tex")
              (base32
               "1h1l9jzkpsb91nyhz6s6c9jfrbz8jx5ip8vyq3dkz0rl6g960i6b")))
    (synopsis "Irish hyphenation patterns")
    (description "This package provides hyphenation patterns for
Irish (Gaeilge) in T1/EC and UTF-8 encodings.")
    ;; Either of these licenses
    (license (list license:gpl2+ license:expat))))

(define-public texlive-hyphen-italian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-italian" "it"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-it.tex")
              (base32
               "03c7jiqslfxvl3gbdx79hggbvrfi2l4z2bnwxc0na8f8lkp1m787")))
    (synopsis "Italian hyphenation patterns")
    (description "This package provides hyphenation patterns for Italian in
ASCII encoding.  Compliant with the Recommendation UNI 6461 on hyphenation
issued by the Italian Standards Institution (Ente Nazionale di Unificazione
UNI).")
    (license license:lppl1.3+)))

(define-public texlive-hyphen-kurmanji
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-kurmanji" "kmr"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-kmr.tex")
              (base32
               "01ylbsi5wymrdrxr9b28nmjmcj72mdhqr657lwsb6m9aj33c9ql6")))
    (synopsis "Kurmanji hyphenation patterns")
    (description "This package provides hyphenation patterns for
Kurmanji (Northern Kurdish) as spoken in Turkey and by the Kurdish diaspora in
Europe, in T1/EC and UTF-8 encodings.")
    (license license:lppl1.3)))

(define-public texlive-hyphen-latin
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-latin" '("la-x-classic" "la-x-liturgic" "la")
              '("/tex/generic/hyph-utf8/patterns/tex/hyph-la-x-classic.tex"
                "/tex/generic/hyph-utf8/patterns/tex/hyph-la-x-liturgic.tex"
                "/tex/generic/hyph-utf8/patterns/tex/hyph-la.tex"
                "/tex/generic/hyph-utf8/patterns/tex-8bit/hyph-la-x-classic.ec.tex")
              (base32
               "119rf6sk1f639ky6zr9njn21nsxzgfmjci94y26745qs8w08ilkl")))
    (synopsis "Liturgical Latin hyphenation patterns")
    (description "This package provides hyphenation patterns for Latin in
T1/EC and UTF-8 encodings, mainly in modern spelling (u when u is needed and v
when v is needed), medieval spelling with the ligatures @code{\\ae} and
@code{\\oe} and the (uncial) lowercase 'v' written as a 'u' is also supported.
Apparently there is no conflict between the patterns of modern Latin and those
of medieval Latin.  It also includes hyphenation patterns for the Classical
Latin in T1/EC and UTF-8 encodings.  Classical Latin hyphenation patterns are
different from those of 'plain' Latin, the latter being more adapted to modern
Latin.  It also provides hyphenation patterns for the Liturgical Latin in
T1/EC and UTF-8 encodings.")
    ;; Either of these licenses
    (license (list license:lppl1.0+ license:expat))))

(define-public texlive-hyphen-latvian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-latvian" "lv"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-lv.tex")
              (base32
               "00jf8xma4ldz0zpqwma97k9q3j0mqx7qdj6b7baph3n5xgc24aaw")))
    (synopsis "Latvian hyphenation patterns")
    (description "This package provides hyphenation patterns for Latvian in
L7X and UTF-8 encodings.")
    ;; Either of these licenses.
    (license (list license:gpl2 license:lgpl2.1))))

(define-public texlive-hyphen-lithuanian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-lithuanian" "lt"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-lt.tex")
              (base32
               "1kfq7j2ajg6nj952s1ygd520sj9z9kl0bqvd291a36ni2b1frzgd")))
    (synopsis "Lithuanian hyphenation patterns")
    (description "This package provides hyphenation patterns for Lithuanian in
L7X and UTF-8 encodings.")
    ;; "Do ... whatever ... as long as you respect the copyright"; as part of
    ;; the hyph-utf8 package we choose the LPPL license.
    (license license:lppl)))

(define-public texlive-hyphen-macedonian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-macedonian" "mk"
              '("/tex/generic/hyph-utf8/patterns/tex/hyph-mk.tex"
                "/tex/generic/hyph-utf8/patterns/tex-8bit/hyph-mk.macedonian.tex")
              (base32
               "1fv6y8gpic5ciw8cclfxc8h3wr5xir1j0a7shixja1pmdyz7db2b")))
    (synopsis "Macedonian hyphenation patterns")
    (description "This package provides hyphenation patterns for Macedonian.")
    ;; XXX: License just says 'GPL'.  Assume GPL2 since the file predates GPL3.
    (license license:gpl2+)))

(define-public texlive-hyphen-mongolian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-mongolian" '("mn-cyrl-x-lmc" "mn-cyrl")
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-mn-cyrl-x-lmc.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-mn-cyrl.tex")
              (base32
               "1y1b91ihrdl9bad3rxlsfjpd9wmyd5zzgci3qv9w8qqk33jxhwya")))
    (synopsis "Mongolian hyphenation patterns in Cyrillic script")
    (description "This package provides hyphenation patterns for Mongolian in
T2A, LMC and UTF-8 encodings.")
    ;; Either of these licenses
    (license (list license:lppl1.3+ license:expat))))

(define-public texlive-hyphen-norwegian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-norwegian" '("nb" "nn" "no")
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-nb.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-nn.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-no.tex")
              (base32
               "08gbwj64p4fckm199k52yp5lx65h9f4wwdkvl4pv4aa7k370jq9y")))
    (synopsis "Norwegian Bokmal and Nynorsk hyphenation patterns")
    (description "This package provides hyphenation patterns for Norwegian
Bokmal and Nynorsk in T1/EC and UTF-8 encodings.")
    (license (license:non-copyleft
              "/tex/generic/hyph-utf8/patterns/tex/hyph-no.tex"
              "FSF All permissive license"))))

(define-public texlive-hyphen-occitan
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-occitan" "oc"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-oc.tex")
              (base32
               "0vhjbq2nr58vhqwwky3cwx4dqiwjmmfwp81rb65mfpf0m8yypdfg")))
    (synopsis "Occitan hyphenation patterns")
    (description "This package provides hyphenation patterns for Occitan in
T1/EC and UTF-8 encodings.  They are supposed to be valid for all the Occitan
variants spoken and written in the wide area called 'Occitanie' by the French.
It ranges from the Val d'Aran within Catalunya, to the South Western Italian
Alps encompassing the southern half of the French pentagon.")
    (license license:lppl1.0+)))

(define-public texlive-hyphen-pali
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-pali" "pi"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-pi.tex")
              (base32
               "1fak853s4ijdqgrnhwymaq1lh8jab3qfyxapdmf6qpg6bqd20kxq")))
    (synopsis "Panjabi hyphenation patterns")
    (description "This package provides hyphenation patterns for Panjabi in
T1/EC encoding.")
    ;; Can be used with either license.
    (license (list license:expat license:lgpl3+ license:gpl3+))))

(define-public texlive-hyphen-piedmontese
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-piedmontese" "pms"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-pms.tex")
              (base32
               "0xva3l2gwzkqw1sz64k5g5iprhdyr27w1mv8rxp8x62i5y3aqr1k")))
    (synopsis "Piedmontese hyphenation patterns")
    (description "This package provides hyphenation patterns for Piedmontese
in ASCII encoding.  Compliant with 'Gramatica dla lengua piemonteisa' by
Camillo Brero.")
    (license license:lppl1.3+)))

(define-public texlive-hyphen-polish
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-polish" "pl"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-pl.tex")
              (base32
               "1c22g99isxapv4xjrmsw24hhp1xb83wbgcxyd8j24mxdnizywxzm")))
    (synopsis "Polish hyphenation patterns")
    (description "This package provides hyphenation patterns for Polish in QX
and UTF-8 encodings.")
    ;; No differing license declared, so we choose the project license.
    (license license:lppl)))

(define-public texlive-hyphen-portuguese
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-portuguese" "pt"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-pt.tex")
              (base32
               "00rkjy4p7893zs940bq3s4hp7al0skgxqggj5qfax0bx8karf30b")))
    (synopsis "Portuguese hyphenation patterns")
    (description "This package provides hyphenation patterns for Portuguese in
T1/EC and UTF-8 encodings.")
    (license license:bsd-3)))

(define-public texlive-hyphen-romanian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-romanian" "ro"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-ro.tex")
              (base32
               "1ykb5v7ip6p3n34wq8qypfyrap4gg946by5rsl6ab0k5gv6ypsbf")))
    (synopsis "Romanian hyphenation patterns")
    (description "This package provides hyphenation patterns for Romanian in
T1/EC and UTF-8 encodings.")
    ;; No differing license declared, so we choose the project license.
    (license license:lppl)))

(define-public texlive-hyphen-romansh
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-romansh" "rm"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-rm.tex")
              (base32
               "0a1q9p6sp5n6a9w6xhwk03vmkrrmnh2md7g1k4qhnf0dc4h7dy9r")))
    (synopsis "Romansh hyphenation patterns")
    (description "This package provides hyphenation patterns for Romansh in
ASCII encodings.  They are supposed to comply with the rules indicated by the
Lia Rumantscha (Romansh language society).")
    (license license:lppl1.3+)))

(define-public texlive-hyphen-russian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-russian" "ru"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-ru.tex")
              (base32
               "00sy7qh5f8ryxw36fwbyd1yi2hxhv7hmk99yp7dwh73n4mxv6lpl")))
    (synopsis "Russian hyphenation patterns")
    (description "This package provides hyphenation patterns for Russian in
T2A and UTF-8 encodings.")
    (license license:lppl1.2+)))

(define-public texlive-hyphen-sanskrit
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-sanskrit" "sa"
              (list "/doc/generic/hyph-utf8/languages/sa/hyphenmin.txt"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-sa.tex")
              (base32
               "1bkzj8swj4lbswf1vr4pb1jg6dixzs7p8h8zm8s8as52h442aida")))
    (synopsis "Sanskrit hyphenation patterns")
    (description "This package provides hyphenation patterns for Sanskrit and
Prakrit in longdesc transliteration, and in Devanagari, Bengali, Kannada,
Malayalam longdesc and Telugu scripts for Unicode engines.")
    ;; "You may freely use, copy, modify and/or distribute this file."
    (license (license:non-copyleft
              "file:///tex/generic/hyph-utf8/patterns/tex/hyph-sa.tex"))))

(define-public texlive-hyphen-serbian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-serbian" '("sh-cyrl" "sh-latn" "sr-cyrl")
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-sh-cyrl.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-sh-latn.tex"
                    "/tex/generic/hyph-utf8/patterns/tex/hyph-sr-cyrl.tex")
              (base32
               "0pwc9z0m5y6acq1vqm0da9akg156jbhxzvsfp2f8bsz5b99y5z45")))
    (synopsis "Serbian hyphenation patterns")
    (description "This package provides hyphenation patterns for Serbian in
T1/EC, T2A and UTF-8 encodings.")
    ;; Any version of the GPL.
    (license license:gpl3+)))

(define-public texlive-hyphen-slovak
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-slovak" "sk"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-sk.tex")
              (base32
               "0ppp53bbclp5c8wvx748krvrp5y5053khgkjnnv966a90fvp3vgd")))
    (synopsis "Slovak hyphenation patterns")
    (description "This package provides hyphenation patterns for Slovak in
T1/EC and UTF-8 encodings.")
    (license license:gpl2+)))

(define-public texlive-hyphen-slovenian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-slovenian" "sl"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-sl.tex")
              (base32
               "02n8l9yf4hqyhbpsc1n6b2mggy09z6lq4dcb8ndiwawb6h0mp7s4")))
    (synopsis "Slovenian hyphenation patterns")
    (description "This package provides hyphenation patterns for Slovenian in
T1/EC and UTF-8 encodings.")
    ;; Either license
    (license (list license:lppl1.0+ license:expat))))

(define-public texlive-hyphen-spanish
  (package
    ;; The source files "eshyph-make.lua" and "eshyph.src" are provided to
    ;; generate obsolete hyphenation patterns, which aren't included in a
    ;; default TeX Live distribution, so we don't include them either.
    (inherit (texlive-hyphen-package
              "texlive-hyphen-spanish" "es"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-es.tex")
              (base32
               "05lbvjkj304xxghyihk8js0kmg97ddlgijld3bp81bc28h4cav0v")))
    (synopsis "Hyphenation patterns for Spanish")
    (description "The package provides hyphenation patterns for Spanish in
T1/EC and UTF-8 encodings.")
    (license license:expat)))

(define-public texlive-hyphen-swedish
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-swedish" "sv"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-sv.tex")
              (base32
               "1n7incy7n24pix1q2i8c3h7i78zpql5ayhskavlmy6mhd7ayncaw")))
    (synopsis "Swedish hyphenation patterns")
    (description "This package provides hyphenation patterns for Swedish in
T1/EC and UTF-8 encodings.")
    (license license:lppl1.2+)))

(define-public texlive-hyphen-thai
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-thai" "th"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-th.tex")
              (base32
               "00gxcs4jfqifd5cnrjipn77m73fmpw2qms4lp216jj3kz4a7h9kf")))
    (synopsis "Thai hyphenation patterns")
    (description "This package provides hyphenation patterns for Thai in LTH
and UTF-8 encodings.")
    (license license:lppl1.3+)))

(define-public texlive-hyphen-turkish
  (let ((template (texlive-hyphen-package
                   "texlive-hyphen-turkish" "tr"
                   (list "/tex/generic/hyph-utf8/patterns/tex/hyph-tr.tex")
                   (base32
                    "04sihjgpm31i5bi67rrfp15w3imn7hxwwk70v0vhx053ghxy72vh"))))
    (package
      (inherit template)
      (synopsis "Hyphenation patterns for Turkish")
      (description "The package provides hyphenation patterns for Turkish in
T1/EC and UTF-8 encodings.  The patterns for Turkish were first produced for
the Ottoman Texts Project in 1987 and were suitable for both Modern Turkish
and Ottoman Turkish in Latin script, however the required character set didn't
fit into EC encoding, so support for Ottoman Turkish had to be dropped to keep
compatibility with 8-bit engines.")
      (license license:lppl1.0+))))

(define-public texlive-hyphen-turkmen
  (let ((template (texlive-hyphen-package
                   "texlive-hyphen-turkmen" "tk"
                   (list "/tex/generic/hyph-utf8/patterns/tex/hyph-tk.tex")
                   (base32
                    "0g5ip2lw9g47s61mv3cypswc6qm7zy9c4iqq4h19ysvds81adzkr"))))
    (package
      (inherit template)
      (synopsis "Hyphenation patterns for Turkmen")
      (description "The package provides hyphenation patterns for Turkmen in
T1/EC and UTF-8 encodings.")
      (license license:expat))))

(define-public texlive-hyphen-ukrainian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-ukrainian" "uk"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-uk.tex")
              (base32
               "0fbfhx1fmbshxr4ihsjaqgx251h69h7i288p8gh3w6ysgxr53p60")))
    (synopsis "Ukrainian hyphenation patterns")
    (description "This package provides hyphenation patterns for Ukrainian in
T2A and UTF-8 encodings.")
    ;; No version specified
    (license license:lppl)))

(define-public texlive-hyphen-uppersorbian
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-uppersorbian" "hsb"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-hsb.tex")
              (base32
               "0x0051wph3sqmzzw6prvjy6bp7gn02rbmys1bmbc210jk3pkylfj")))
    (synopsis "Upper Sorbian hyphenation patterns")
    (description "This package provides hyphenation patterns for Upper Sorbian
in T1/EC and UTF-8 encodings.")
    (license license:lppl1.3a+)))

(define-public texlive-hyphen-welsh
  (package
    (inherit (texlive-hyphen-package
              "texlive-hyphen-welsh" "cy"
              (list "/tex/generic/hyph-utf8/patterns/tex/hyph-cy.tex")
              (base32
               "1bpxp3jiifdw7waw2idz5j9xgi3526nkxm8mbmsspr4mlf2xyr76")))
    (synopsis "Welsh hyphenation patterns")
    (description "This package provides hyphenation patterns for Welsh in
T1/EC and UTF-8 encodings.")
    ;; Either license
    (license (list license:lppl1.0+ license:expat))))

(define-public texlive-hyph-utf8
  (package
    (inherit (simple-texlive-package
              "texlive-hyph-utf8"
              (list "/source/generic/hyph-utf8/"
                    "/source/luatex/hyph-utf8/"
                    "/doc/luatex/hyph-utf8/"
                    "/tex/luatex/hyph-utf8/etex.src"
                    ;; Used to extract luatex-hyphen.lua
                    "/tex/latex/base/docstrip.tex"

                    ;; Documentation; we can't use the whole directory because
                    ;; it includes files from other packages.
                    "/doc/generic/hyph-utf8/CHANGES"
                    "/doc/generic/hyph-utf8/HISTORY"
                    "/doc/generic/hyph-utf8/hyph-utf8.pdf"
                    "/doc/generic/hyph-utf8/hyph-utf8.tex"
                    "/doc/generic/hyph-utf8/hyphenation-distribution.pdf"
                    "/doc/generic/hyph-utf8/hyphenation-distribution.tex"
                    "/doc/generic/hyph-utf8/img/miktex-languages.png"
                    "/doc/generic/hyph-utf8/img/texlive-collection.png")
              (base32
               "0rgp0zn36gwzqwpmjb9h01ns3m19v3r7lpw1h0pc9bx115w6c9jx")))
    (outputs '("out" "doc"))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f ; there are none
       #:modules ((guix build gnu-build-system)
                  (guix build utils)
                  (ice-9 match))
       #:make-flags
       (list "-C" "source/luatex/hyph-utf8/"
             (string-append "DO_TEX = tex --interaction=nonstopmode '&tex' $<")
             (string-append "RUNDIR =" (assoc-ref %outputs "out") "/share/texmf-dist/tex/luatex/hyph-utf8/")
             (string-append "DOCDIR =" (assoc-ref %outputs "doc") "/share/texmf-dist/doc/luatex/hyph-utf8/")
             ;; hyphen.cfg is neither included nor generated, so let's only build the lua file.
             (string-append "UNPACKED = $(NAME).lua"))
       #:phases
       (modify-phases %standard-phases
         ;; TeX isn't usable at this point, so we first need to generate the
         ;; tex.fmt.
         (replace 'configure
           (lambda* (#:key inputs outputs #:allow-other-keys)
             ;; Target directories must exist.
             (mkdir-p (string-append (assoc-ref %outputs "out")
                                     "/share/texmf-dist/tex/luatex/hyph-utf8/"))
             (mkdir-p (string-append (assoc-ref %outputs "doc")
                                     "/share/texmf-dist/doc/luatex/hyph-utf8/"))

             ;; We cannot build the documentation because that requires a
             ;; fully functional pdflatex, which depends on this package.
             (substitute* "source/luatex/hyph-utf8/Makefile"
               (("all: .*") "all: $(RUNFILES)\n"))

             ;; Find required fonts for building tex.fmt
             (setenv "TFMFONTS"
                     (string-append (assoc-ref inputs "texlive-cm")
                                    "/share/texmf-dist/fonts/tfm/public/cm:"
                                    (assoc-ref inputs "texlive-knuth-lib")
                                    "/share/texmf-dist/fonts/tfm/public/knuth-lib"))
             ;; ...and find all tex files in this environment.
             (setenv "TEXINPUTS"
                     (string-append
                      (getcwd) ":"
                      (string-join
                       (map (match-lambda ((_ . dir) dir)) inputs)
                       "//:")))

             ;; Generate tex.fmt.
             (let ((where "source/luatex/hyph-utf8"))
               (mkdir-p where)
               (with-directory-excursion where
                 (invoke "tex" "-ini"
                         (string-append (assoc-ref inputs "texlive-plain")
                                        "/share/texmf-dist/tex/plain/config/tex.ini"))))))
         (add-before 'build 'build-loaders-and-converters
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((root (string-append (assoc-ref outputs "out")
                                         "/share/texmf-dist"))
                    (conv
                     (string-append root
                                    "/tex/generic/hyph-utf8/conversions")))

               ;; Build converters
               (mkdir-p conv)
               (with-directory-excursion "source/generic/hyph-utf8"
                 (substitute* "generate-converters.rb"
                   (("\\$path_root=File.*")
                    (string-append "$path_root=\"" root "\"\n"))
                   ;; Avoid error with newer Ruby.
                   (("#1\\{%") "#1{%%"))
                 (invoke "ruby" "generate-converters.rb"))
               #t)))
         (replace 'install
           (lambda* (#:key source outputs #:allow-other-keys)
             (let ((doc (assoc-ref outputs "doc"))
                   (out (assoc-ref outputs "out")))
               (mkdir-p doc)
               (copy-recursively
                (string-append source "/doc")
                (string-append doc "/doc"))
               (install-file
                (string-append source "/tex/luatex/hyph-utf8/etex.src")
                (string-append out "/share/texmf-dist/tex/luatex/hyph-utf8/")))
             #t)))))
    (native-inputs
     (list ruby-2.7
           texlive-bin
           ;; The following packages are needed for build "tex.fmt", which we
           ;; need for a working "tex".
           texlive-cm
           texlive-knuth-lib
           texlive-hyphen-base
           texlive-plain))
    (home-page "https://ctan.org/pkg/hyph-utf8")
    (synopsis "Hyphenation patterns expressed in UTF-8")
    (description "Modern native UTF-8 engines such as XeTeX and LuaTeX need
hyphenation patterns in UTF-8 format, whereas older systems require
hyphenation patterns in the 8-bit encoding of the font in use (such encodings
are codified in the LaTeX scheme with names like OT1, T2A, TS1, OML, LY1,
etc).  The present package offers a collection of conversions of existing
patterns to UTF-8 format, together with converters for use with 8-bit fonts in
older systems.  Since hyphenation patterns for Knuthian-style TeX systems are
only read at iniTeX time, it is hoped that the UTF-8 patterns, with their
converters, will completely supplant the older patterns.")
    ;; Individual files each have their own license.  Most of these files are
    ;; independent hyphenation patterns.
    (license (list license:lppl1.0+
                   license:lppl1.2+
                   license:lppl1.3
                   license:lppl1.3+
                   license:lppl1.3a+
                   license:lgpl2.1
                   license:lgpl2.1+
                   license:lgpl3+
                   license:gpl2+
                   license:gpl3+
                   license:mpl1.1
                   license:asl2.0
                   license:expat
                   license:bsd-3
                   license:cc0
                   license:public-domain
                   license:wtfpl2))))

(define-deprecated-package texlive-generic-hyph-utf8 texlive-hyph-utf8)

(define-public texlive-dehyph
  (package
    (name "texlive-dehyph")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "tex/generic/dehyph/")
             (base32
              "0fkqlsknrlxk8zazcqy4q3nisxr3a4x21aiwqhz8s237rdf3w39g")))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/dehyph")
    (synopsis "German hyphenation patterns for traditional orthography")
    (description
     "The package provides older hyphenation patterns for the German language.
Please note that by default only pdfLaTeX uses these patterns (mainly for
backwards compatibility).  The older packages ghyphen and gnhyph are now
bundled together with dehyph, and are no longer be updated.  Both XeLaTeX and
LuaLaTeX use the current German hyphenation patterns taken from Hyphenation
patterns in UTF-8, and using the Experimental hyphenation patterns for the
German language package it is possible to make pdfLaTeX use the new German
patterns as well.")
    (license license:lppl1.0+)))

(define-public texlive-dehyph-exptl
  (package
    (inherit (simple-texlive-package
              "texlive-dehyph-exptl"
              (list "/tex/generic/dehyph-exptl/"
                    "/doc/generic/dehyph-exptl/")
              (base32
               "0l57a0r4gycp94kz6lrxqvh9m57j2shmbr2laf5zjb0qnrisq46d")
              #:trivial? #t))
    (propagated-inputs
     (list texlive-hyphen-base texlive-hyph-utf8))
    (home-page "http://projekte.dante.de/Trennmuster/WebHome")
    (synopsis "Hyphenation patterns for German")
    (description "The package provides experimental hyphenation patterns for
the German language, covering both traditional and reformed orthography.  The
patterns can be used with packages Babel and hyphsubst from the Oberdiek
bundle.")
    ;; Hyphenation patterns are under the Expat license; documentation is
    ;; under LPPL.
    (license (list license:expat license:lppl))))

(define-deprecated-package texlive-generic-dehyph-exptl texlive-dehyph-exptl)

(define-public texlive-ukrhyph
  (package
    (inherit (simple-texlive-package
              "texlive-ukrhyph"
              (list "/doc/generic/ukrhyph/"
                    "/tex/generic/ukrhyph/")
              (base32
               "01ma274sixcrbpb7fpqkxwfvrnzfj2srv9b4a42rfnph1pdql74z")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/ukrhyph")
    (synopsis "Hyphenation patterns for Ukrainian")
    (description "The package provides a range of hyphenation patterns for
Ukrainian, depending on the encoding of the output font including the standard
T2A.")
    (license license:lppl)))

(define-public texlive-ruhyphen
  (let ((template (simple-texlive-package
                   "texlive-ruhyphen"
                   (list "/source/generic/ruhyphen/"
                         "/tex/generic/ruhyphen/")
                   (base32
                    "18n1bqhh8jv765vz3a3fjwffy7m71vhwx9yq8zl0p5j7p72q9qcn")
                   #:trivial? #t)))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:phases phases)
          `(modify-phases ,phases
             (replace 'build
               (lambda _
                 (let ((cwd (getcwd)))
                   ;; Remove generated files.
                   (for-each delete-file
                             (find-files "tex/generic/ruhyphen/"
                                         "^cyry.*.tex$"))
                   (substitute* "source/generic/ruhyphen/Makefile"
                     (("./mkcyryo") (string-append cwd "/source/generic/ruhyphen/mkcyryo")))
                   (with-directory-excursion "tex/generic/ruhyphen"
                     (invoke "make" "-f"
                             (string-append cwd "/source/generic/ruhyphen/Makefile"))))))))))
      (native-inputs
       (list coreutils gawk sed grep perl))
      (home-page "https://www.ctan.org/pkg/ruhyphen")
      (synopsis "Hyphenation patterns for Russian")
      (description "The package provides a collection of Russian hyphenation
patterns supporting a number of Cyrillic font encodings, including T2,
UCY (Omega Unicode Cyrillic), LCY, LWN (OT2), and koi8-r.")
      (license license:lppl))))

(define-public texlive-inputenx
  (package
    (inherit (simple-texlive-package
              "texlive-inputenx"
              (list "doc/latex/inputenx/"
                    "tex/latex/inputenx/"
                    "source/latex/inputenx/")
              (base32
               "0snjndrcynm4w8m9iq8gmadzhrbwvsdy4y1ak24ia0hpsicdi4aj")
              #:trivial? #t))
    (home-page "https://ctan.org/macros/latex/contrib/inputenx")
    (synopsis "Enhanced input encoding handling")
    (description
     "This package deals with input encodings.  It provides a wider range of input
encodings using standard mappings, than does inputenc.  It also covers nearly all
slots.  In this way, it serves as more up to date replacement for the inputenc
package.")
    (license license:lppl1.3+)))

(define-public texlive-kpathsea
  (let ((template (simple-texlive-package
                   "texlive-kpathsea"
                   (list "/web2c/amiga-pl.tcx"
                         "/web2c/cp1250cs.tcx"
                         "/web2c/cp1250pl.tcx"
                         "/web2c/cp1250t1.tcx"
                         "/web2c/cp227.tcx"
                         "/web2c/cp852-cs.tcx"
                         "/web2c/cp852-pl.tcx"
                         "/web2c/cp8bit.tcx"
                         "/web2c/empty.tcx"
                         "/web2c/fmtutil.cnf"
                         "/web2c/il1-t1.tcx"
                         "/web2c/il2-cs.tcx"
                         "/web2c/il2-pl.tcx"
                         "/web2c/il2-t1.tcx"
                         "/web2c/kam-cs.tcx"
                         "/web2c/kam-t1.tcx"
                         "/web2c/macce-pl.tcx"
                         "/web2c/macce-t1.tcx"
                         "/web2c/maz-pl.tcx"
                         "/web2c/mktex.cnf"
                         "/web2c/mktex.opt"
                         "/web2c/mktexdir"
                         "/web2c/mktexdir.opt"
                         "/web2c/mktexnam"
                         "/web2c/mktexnam.opt"
                         "/web2c/mktexupd"
                         "/web2c/natural.tcx"
                         "/web2c/tcvn-t5.tcx"
                         "/web2c/viscii-t5.tcx")
                   (base32
                    "08nfk5hicqbvnz73rjbxi97lcakd9i1k2cy4qi2cwghan92650jq")
                   #:trivial? #t)))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:phases phases '%standard-phases)
          `(modify-phases ,phases
             (add-after 'unpack 'patch-references
               (lambda* (#:key inputs #:allow-other-keys)
                 (let ((dirs (map dirname (list (which "sed")
                                                (which "awk")))))
                   (substitute* '("web2c/mktexdir"
                                  "web2c/mktexnam"
                                  "web2c/mktexupd")
                     (("^version=" m)
                      (format #false "PATH=\"~{~a:~}$PATH\"; export PATH~%~a"
                              dirs m))))))))))
      (inputs
       (list sed gawk))
      (home-page "https://www.tug.org/texlive/")
      (synopsis "Files related to the path searching library for TeX")
      (description "Kpathsea is a library and utility programs which provide
path searching facilities for TeX file types, including the self-locating
feature required for movable installations, layered on top of a general search
mechanism.  This package provides supporting files.")
      (license license:lgpl3+))))

(define-public texlive-kpfonts
  (package
    (inherit (simple-texlive-package
              "texlive-kpfonts"
              (list "doc/fonts/kpfonts/"
                    "fonts/enc/dvips/kpfonts/"
                    "fonts/map/dvips/kpfonts/"
                    "fonts/tfm/public/kpfonts/"
                    "fonts/type1/public/kpfonts/"
                    "fonts/vf/public/kpfonts/"
                    "source/fonts/kpfonts/"
                    "tex/latex/kpfonts/")
              (base32 "0inai1p9bbjd5x790nsamakjaj0imvwv21mp9f98dwvdlj58vkqb")
              #:trivial? #t))
    (home-page "https://ctan.org/fonts/kpfonts")
    (synopsis "Complete set of fonts for text and mathematics")
    (description
     "The family contains text fonts in roman, sans-serif and monospaced
shapes, with true small caps and old-style numbers; the package offers full
support of the textcomp package.  The mathematics fonts include all the AMS
fonts, in both normal and bold weights.  Each of the font types is available
in two main versions: default and light.  Each version is available in four
variants: default; oldstyle numbers; oldstyle numbers with old ligatures such
as ct and st, and long-tailed capital Q; and veryoldstyle with long s.  Other
variants include small caps as default or large small caps, and for
mathematics both upright and slanted shapes for Greek letters, as well as
default and narrow versions of multiple integrals.")
    (license license:gpl3+)))

(define-public texlive-latexconfig
  (package
    (inherit (simple-texlive-package
              "texlive-latexconfig"
              (list "/tex/latex/latexconfig/")
              (base32
               "1x5fyr2185nx3qlyariykdz44hcy5azimrk9db2p707dg08bjhsd")
              #:trivial? #t))
    (home-page "https://www.tug.org/")
    (synopsis "Configuration files for LaTeX-related formats")
    (description "The package provides configuration files for LaTeX-related
formats.")
    (license license:lppl)))

(define-public texlive-latex-base
  (let ((template (simple-texlive-package
                   "texlive-latex-base"
                   (list "/doc/latex/base/"
                         "/source/latex/base/"
                         ;; Almost all files in /tex/latex/base are generated, but
                         ;; these are not:
                         "/tex/latex/base/idx.tex"
                         "/tex/latex/base/lablst.tex"
                         "/tex/latex/base/ltnews.cls"
                         "/tex/latex/base/ltxcheck.tex"
                         "/tex/latex/base/ltxguide.cls"
                         "/tex/latex/base/minimal.cls"
                         "/tex/latex/base/sample2e.tex"
                         "/tex/latex/base/small2e.tex"
                         "/tex/latex/base/testpage.tex"
                         "/tex/latex/base/texsys.cfg")
                   (base32
                    "0msyjz0937rc7hs77v6la152sdiwd73qj41z1mlyh0m3dns9qz4g")
                   #:trivial? #t)))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:modules modules '())
          '((guix build gnu-build-system)
            (guix build utils)
            (ice-9 match)
            (srfi srfi-26)))
         ((#:phases phases)
          `(modify-phases ,phases
             ;; The literal tab in the dtx file is translated to the string
             ;; "^^I" in the generated Lua file, which causes a syntax error.
             (add-after 'unpack 'fix-lua-sources
               (lambda _
                 (substitute* "source/latex/base/ltluatex.dtx"
                   (("	") "  "))))
             (replace 'build
               (lambda* (#:key inputs #:allow-other-keys)
                 ;; Find required fonts
                 (setenv "TFMFONTS"
                         (string-join
                          (map (match-lambda
                                 ((pkg-name . dir)
                                  (string-append
                                   (assoc-ref inputs pkg-name)
                                   "/share/texmf-dist/fonts/tfm/public"
                                   dir)))
                               '(("texlive-etex" . "/etex")
                                 ("texlive-cm" . "/cm")
                                 ("texlive-latex-fonts" . "/latex-fonts")
                                 ("texlive-knuth-lib" . "/knuth-lib")))
                          ":"))
                 (let ((cwd (getcwd)))
                   (setenv "TEXINPUTS"
                           (string-append
                            cwd "//:"
                            cwd "/source/latex/base//:"
                            cwd "/build:"
                            (string-join
                             (map (match-lambda ((_ . dir) dir)) inputs)
                             "//:")))
                   (setenv "LUAINPUTS" (string-append cwd "/build:")))

                 ;; This is the actual build step.
                 (mkdir "build")
                 (invoke "tex" "-ini" "-interaction=scrollmode"
                         "-output-directory=build" "unpack.ins")

                 ;; XXX: We can't build all formats at this point, nor are they
                 ;; part of the LaTeX base, so we disable them.  Actually, we
                 ;; should be running this all in a profile hook, so that only
                 ;; selected formats and hyphenation patterns are included, but it
                 ;; takes long and TeX Live isn't designed to be modular like
                 ;; that.  Everything operates on a shared directory, which we
                 ;; would only have at profile generation time.
                 (let ((disabled-formats
                        '("aleph aleph" "lamed aleph" "uptex uptex" "euptex euptex"
                          "eptex eptex" "ptex ptex" "pdfxmltex pdftex" "platex eptex"
                          "platex-dev eptex" "uplatex-dev euptex"
                          "csplain pdftex" "mf mf-nowin" "mex pdftex" "pdfmex pdftex"
                          "luacsplain luatex" "optex luatex"
                          ;; LuaJIT is not ported to powerpc64le* or riscv64 yet and
                          ;; building these fail on powerpc.
                          ,@(if (or (target-powerpc?)
                                    (target-riscv64?))
                              '("luajittex" "luajithbtex" "mfluajit") '())
                          "cont-en xetex" "cont-en pdftex" "pdfcsplain xetex"
                          "pdfcsplain pdftex" "pdfcsplain luatex" "cslatex pdftex"
                          "mptopdf pdftex" "uplatex euptex" "jadetex pdftex"
                          "amstex pdftex" "pdfcslatex pdftex" "lollipop tex"
                          "xmltex pdftex" "pdfjadetex pdftex" "eplain pdftex"
                          "texsis pdftex" "mltex pdftex" "utf8mex pdftex")))
                   (mkdir "web2c")
                   (install-file (string-append
                                  (assoc-ref inputs "texlive-kpathsea")
                                  "/share/texmf-dist/web2c/fmtutil.cnf")
                                 "web2c")
                   (make-file-writable "web2c/fmtutil.cnf")
                   (substitute* "web2c/fmtutil.cnf"
                     (((string-append "^(" (string-join disabled-formats "|") ")") m)
                      (string-append "#! " m))
                     (("translate-file=cp227")
                      (format #f "translate-file=~a/share/texmf-dist/web2c/cp227"
                              (assoc-ref inputs "texlive-kpathsea")))))
                 (invoke "fmtutil-sys" "--all"
                         "--fmtdir=web2c"
                         (string-append "--cnffile=web2c/fmtutil.cnf"))
                 ;; We don't actually want to install it.
                 (delete-file "web2c/fmtutil.cnf")))
             (add-after 'install 'install-more
               (lambda* (#:key inputs outputs #:allow-other-keys)
                 (let* ((out (assoc-ref outputs "out"))
                        (root (string-append out "/share/texmf-dist"))
                        (target (string-append root "/tex/latex/base"))
                        (web2c (string-append root "/web2c"))
                        (makeindex (string-append root "/makeindex/latex")))
                   (for-each delete-file (find-files "." "\\.(log|aux)$"))

                   ;; The usedir directive in docstrip.ins is ignored, so these
                   ;; two files end up in the wrong place.  Move them.
                   (mkdir-p makeindex)
                   (for-each (lambda (file)
                               (install-file file makeindex)
                               (delete-file file))
                             '("build/gglo.ist"
                               "build/gind.ist"))
                   (for-each (cut install-file <> target)
                             (find-files "build" ".*"))
                   (for-each (cut install-file <> web2c)
                             (find-files "web2c" ".*")))))))))
      (native-inputs
       `(("texlive-bin" ,texlive-bin)
         ("texlive-tex-ini-files" ,texlive-tex-ini-files)
         ("texlive-plain" ,texlive-plain)
         ("texlive-kpathsea" ,texlive-kpathsea)
         ("texlive-cm" ,texlive-cm)
         ("texlive-latex-fonts" ,texlive-latex-fonts)
         ("texlive-knuth-lib" ,texlive-knuth-lib)
         ("texlive-luatexconfig"
          ,(texlive-origin
            "texlive-luatexconfig" (number->string %texlive-revision)
            (list "/tex/generic/config/luatex-unicode-letters.tex"
                  "/tex/generic/config/luatexiniconfig.tex"
                  "/web2c/texmfcnf.lua")
            (base32
             "065j47i2785nbj2507pzxlscyrwr4ghv6nksc3a01rp62bq8kkjp")))))
      (propagated-inputs
       (list texlive-dehyph-exptl
             texlive-etex
             texlive-hyph-utf8
             texlive-hyphen-base
             texlive-hyphen-afrikaans
             texlive-hyphen-ancientgreek
             texlive-hyphen-armenian
             texlive-hyphen-basque
             texlive-hyphen-belarusian
             texlive-hyphen-bulgarian
             texlive-hyphen-catalan
             texlive-hyphen-chinese
             texlive-hyphen-churchslavonic
             texlive-hyphen-coptic
             texlive-hyphen-croatian
             texlive-hyphen-czech
             texlive-hyphen-danish
             texlive-hyphen-dutch
             texlive-hyphen-english
             texlive-hyphen-esperanto
             texlive-hyphen-estonian
             texlive-hyphen-ethiopic
             texlive-hyphen-finnish
             texlive-hyphen-schoolfinnish
             texlive-hyphen-french
             texlive-hyphen-friulan
             texlive-hyphen-galician
             texlive-hyphen-georgian
             texlive-hyphen-german
             texlive-hyphen-greek
             texlive-hyphen-hungarian
             texlive-hyphen-icelandic
             texlive-hyphen-indic
             texlive-hyphen-indonesian
             texlive-hyphen-interlingua
             texlive-hyphen-irish
             texlive-hyphen-italian
             texlive-hyphen-kurmanji
             texlive-hyphen-latin
             texlive-hyphen-latvian
             texlive-hyphen-lithuanian
             texlive-hyphen-macedonian
             texlive-hyphen-mongolian
             texlive-hyphen-norwegian
             texlive-hyphen-occitan
             texlive-hyphen-pali
             texlive-hyphen-piedmontese
             texlive-hyphen-polish
             texlive-hyphen-portuguese
             texlive-hyphen-romanian
             texlive-hyphen-romansh
             texlive-hyphen-russian
             texlive-hyphen-sanskrit
             texlive-hyphen-serbian
             texlive-hyphen-slovak
             texlive-hyphen-slovenian
             texlive-hyphen-spanish
             texlive-hyphen-swedish
             texlive-hyphen-thai
             texlive-hyphen-turkish
             texlive-hyphen-turkmen
             texlive-hyphen-ukrainian
             texlive-hyphen-uppersorbian
             texlive-hyphen-welsh
             texlive-unicode-data
             texlive-ukrhyph
             texlive-ruhyphen
             texlive-l3kernel
             texlive-l3backend
             ;; TODO: This dependency isn't needed for LaTeX version 2021-06-01
             ;; and later. See:
             ;; https://tug.org/pipermail/tex-live/2021-June/047180.html
             texlive-l3packages
             texlive-latexconfig))
      (home-page "https://www.ctan.org/pkg/latex-base")
      (synopsis "Base sources of LaTeX")
      (description
       "This bundle comprises the source of LaTeX itself, together with several
packages which are considered \"part of the kernel\".  This bundle, together
with the required packages, constitutes what every LaTeX distribution should
contain.")
      (license license:lppl1.3c+))))

(define-public texlive-atenddvi
  (package
    (name "texlive-atenddvi")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/atenddvi/"
                   "source/latex/atenddvi/"
                   "tex/latex/atenddvi/")
             (base32
              "1fwa5233mdgvixhl2rzn9s06zz52j6ml7hfzd4194bn389n9syhk")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-atbegshi texlive-zref))
    (home-page "https://ctan.org/pkg/atenddvi")
    (synopsis "Provide the @code{\\AtEndDvi} command for older LaTeX format")
    (description
     "This package is unneeded and does nothing when used with a LaTeX format
2020-10-01 or newer as in this case the format provides the @code{\\AtEndDvi}
command.  For older formats it implements @code{\\AtEndDvi}, a counterpart to
@code{\\AtBeginDvi}.  The execution of its argument is delayed to the end of
the document at the end of the last page.  Thus @code{\\special} and
@code{\\write} remain effective, because they are put into the last page.
This is the main difference to @code{\\AtEndDocument}.")
    (license license:lppl1.3c+)))

(define-public texlive-attachfile
  (package
    (name "texlive-attachfile")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "bibtex/bib/attachfile/"
                   "doc/latex/attachfile/"
                   "source/latex/attachfile/"
                   "tex/latex/attachfile/")
             (base32
              "0340c4rvxhhk95wlhf54n9akiwhj6pj0bslys6bkq29x9903zx5h")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics
           texlive-hyperref
           texlive-iftex))
    (home-page "https://ctan.org/pkg/attachfile")
    (synopsis "Attach arbitrary files to a PDF document")
    (description
     "Starting with PDF 1.3, PDF files can contain file attachments, i.e.,
arbitrary files that a reader can extract, just like attachments to an e-mail
message.  The @code{attachfile} package brings this functionality to pdfLaTeX
and provides some additional features such as the ability to use arbitrary
LaTeX code for the file icon.  Settings can be made either globally or on
a per-attachment basis.  @code{attachfile} makes it easy to attach files and
customize their appearance in the enclosing document.")
    (license license:lppl1.3+)))

(define-public texlive-atveryend
  (let ((template (simple-texlive-package
                   "texlive-atveryend"
                   (list "doc/latex/atveryend/"
                         "source/latex/atveryend/"
                         "tex/latex/atveryend/")
                   (base32 "1rp805h0m99rxs107a798l951lyahlnp7irfklfadn2a2ljzhafn"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:build-targets _ #t)
          #~(list "atveryend.dtx"))))
      (home-page "https://ctan.org/macros/latex/contrib/atveryend")
      (synopsis "Hooks at the very end of a document")
      (description
       "This LaTeX packages provides two hooks for @code{\\end{document}} that
are executed after the hook of @code{\\AtEndDocument}:
@code{\\AfterLastShipout} can be used for code that is to be executed right
after the last @code{\\clearpage} before the @file{.aux} file is closed.
@code{\\AtVeryEndDocument} is used for code after closing and final reading of
the @file{.aux} file.")
      (license license:lppl1.3+))))

(define-deprecated-package texlive-latex-atveryend texlive-atveryend)

(define-public texlive-auxhook
  (let ((template (simple-texlive-package
                   "texlive-auxhook"
                   (list "doc/latex/auxhook/"
                         "source/latex/auxhook/"
                         "tex/latex/auxhook/")
                   (base32
                    "1qfs7bz8ryp4prr2fw4hwypnfc6yr4rc4wd8qy4rpmab0hab0vdy"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:build-targets _ '())
          #~(list "auxhook.dtx"))))
      (home-page "https://www.ctan.org/pkg/auxhook")
      (synopsis "Hooks for auxiliary files")
      (description
       "This package provides hooks for adding code at the beginning of
@file{.aux} files.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-latex-auxhook texlive-auxhook)

(define-public texlive-epstopdf-pkg
  (let ((template (simple-texlive-package
                   "texlive-epstopdf-pkg"
                   (list "doc/latex/epstopdf-pkg/"
                         "source/latex/epstopdf-pkg/"
                         "tex/latex/epstopdf-pkg/")
                   (base32
                    "1ajyc5pkn1niifz5asyf09vbdqvmy05xwl0vxcdl7ik0ll0jcaxp"))))
    (package
     (inherit template)
     (arguments
      (substitute-keyword-arguments (package-arguments template)
        ((#:tex-directory _ '())
         "latex/epstopdf-pkg")
        ((#:build-targets _ '())
         #~(list "epstopdf.ins"))))
     (propagated-inputs
      (list texlive-grfext
            texlive-infwarerr
            texlive-kvoptions
            texlive-pdftexcmds))
     (home-page "https://www.ctan.org/pkg/epstopdf-pkg")
     (synopsis "Call @command{epstopdf} on the fly")
     (description
      "The package adds support for EPS files in the @code{graphicx} package
when running under pdfTeX.  If an EPS graphic is detected, the package spawns
a process to convert the EPS to PDF, using the script @command{epstopdf}.")
     (license license:lppl1.3c+))))

(define-deprecated-package texlive-latex-epstopdf-pkg texlive-epstopdf-pkg)

(define-public texlive-filecontents
  (let ((template (simple-texlive-package
                   "texlive-filecontents"
                   (list "doc/latex/filecontents/"
                         "source/latex/filecontents/"
                         "tex/latex/filecontents/")
                   (base32
                    "0ifhqfdzx91hrmndhg5441rpmv9k4lxrql02kd5yx75xpplxryzw"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '()) "latex/filecontents")))
      (home-page "https://ctan.org/pkg/filecontents")
      (synopsis "Create an external file from within a LaTeX document")
      (description
       "LaTeX2e's @code{filecontents} and @code{filecontents*} environments
enable a LaTeX source file to generate external files as it runs through
LaTeX.  However, there are two limitations of these environments: they refuse
to overwrite existing files, and they can only be used in the preamble of
a document.  The filecontents package removes these limitations, letting you
overwrite existing files and letting you use @code{filecontents}
@code{filecontents*} anywhere.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-latex-filecontents texlive-filecontents)

(define-public texlive-filehook
  (package
    (name "texlive-filehook")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/filehook/"
                   "source/latex/filehook/"
                   "tex/latex/filehook/")
             (base32
              "03dsnv8fn111kn8h2fa281w2jvcdrqag1im6mkkfahvjgl1apk6k")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (native-inputs
     (list texlive-ydoc))
    (propagated-inputs
     (list texlive-kvoptions
           texlive-pgf))
    (home-page "https://ctan.org/pkg/filehook")
    (synopsis "Hooks for input files")
    (description
     "The package provides several file hooks (@code{AtBegin}, @code{AtEnd},
...) for files read by @code{\\input}, @code{\\include} and
@code{\\InputIfFileExists}.  General hooks for all such files (e.g., all
@code{\\included} ones) and file specific hooks only used for named files are
provided; two hooks are provided for the end of @code{\\included} files ---
one before, and one after the final @code{\\clearpage}.")
    (license license:lppl1.3+)))

(define-public texlive-epsf
  (package
    (inherit (simple-texlive-package
              "texlive-epsf"
              (list "/doc/generic/epsf/"
                    "/tex/generic/epsf/")
              (base32
               "03jcf0kqh47is965d2590miwj7d5kif3c4mgsnvkyl664jzjkh92")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/epsf")
    (synopsis "Simple macros for EPS inclusion")
    (description
     "This package provides the original (and now obsolescent) graphics
inclusion macros for use with dvips, still widely used by Plain TeX users (in
particular).  For LaTeX users, the package is nowadays (rather strongly)
deprecated in favour of the more sophisticated standard LaTeX latex-graphics
bundle of packages.  (The latex-graphics bundle is also available to Plain TeX
users, via its Plain TeX version.)")
    (license license:public-domain)))

(define-deprecated-package texlive-generic-epsf texlive-epsf)

(define-public texlive-fancyvrb
  (package
    (inherit (simple-texlive-package
              "texlive-fancyvrb"
              (list "/doc/latex/fancyvrb/README"
                    "/tex/latex/fancyvrb/")
              (base32
               "0pdilgpw4zc0ipp4z9kdi61nymifyjy2mfpk74xk2cw9vhynkk3w")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/fancyvrb")
    (synopsis "Sophisticated verbatim text")
    (description
     "This package provides tools for the flexible handling of verbatim text
including: verbatim commands in footnotes; a variety of verbatim environments
with many parameters; ability to define new customized verbatim environments;
save and restore verbatim text and environments; write and read files in
verbatim mode; build \"example\" environments (showing both result and
verbatim source).")
    (license license:lppl1.0+)))

(define-deprecated-package texlive-latex-fancyvrb texlive-fancyvrb)

(define-public texlive-gincltex
  (package
    (name "texlive-gincltex")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/gincltex/" "source/latex/gincltex/"
                   "tex/latex/gincltex/")
             (base32
              "1x6bsf445dp8wc5hfgyywlal8vky5w23d69zlpybkp2d9am9a71p")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-adjustbox
           texlive-svn-prov))
    (home-page "https://ctan.org/pkg/gincltex")
    (synopsis "Include TeX files as graphics")
    (description
     "The package builds on the standard LaTeX packages @code{graphics} and
allows external LaTeX source files to be included, in the same way as graphic
files, by @code{\\includegraphics}.  In effect, then package adds support for
the @file{.tex} extension.")
    (license license:lppl1.3+)))

(define-public texlive-glyphlist
  (package
    (inherit (simple-texlive-package
              "texlive-glyphlist"
              (list "fonts/map/glyphlist/")
              (base32
               "12nmmyh77vr2622lzi11nm1z1k2bxs7jz018yl4rwjlpg0sxg1ja")
              #:trivial? #t))
    (home-page "https://www.tug.org/texlive/")
    (synopsis "Adobe glyph list and TeX extensions")
    (description
     "This package provides a map between traditional Adobe glyph names and
Unicode points; it is maintained by Adobe.  The additional
@file{texglyphlist.txt} is maintained as part of lcdf-typetools.")
    (license license:asl2.0)))

(define-public texlive-graphics-def
  (package
    (inherit (simple-texlive-package
              "texlive-graphics-def"
              (list "/doc/latex/graphics-def/README.md"
                    "/tex/latex/graphics-def/")
              (base32
               "0b66fy06safyrd717rfr476g1gz6nqfv1vqvam7ac2yy0g0djb17")
              #:trivial? #t))
    (propagated-inputs
     (list texlive-epstopdf-pkg))
    (home-page "https://www.ctan.org/pkg/latex-graphics")
    (synopsis "Color and graphics option files")
    (description
     "This bundle is a combined distribution consisting of @file{dvips.def},
@file{pdftex.def}, @file{luatex.def}, @file{xetex.def}, @file{dvipdfmx.def},
and @file{dvisvgm.def} driver option files for the LaTeX graphics and color
packages.")
    (license license:lppl1.3c+)))

(define-public texlive-graphics-cfg
  (package
    (inherit (simple-texlive-package
              "texlive-graphics-cfg"
              (list "/doc/latex/graphics-cfg/README.md"
                    "/tex/latex/graphics-cfg/")
              (base32
               "00n63adb2laf43lzix39xl68aq0k5k80mmrw602w99w5n7f96gsf")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/latex-graphics")
    (synopsis "Sample configuration files for LaTeX color and graphics")
    (description
     "This bundle includes @file{color.cfg} and @file{graphics.cfg} files that
set default \"driver\" options for the color and graphics packages.")
    (license license:public-domain)))

(define-public texlive-graphics
  (let ((template (simple-texlive-package
                   "texlive-graphics"
                   (list "doc/latex/graphics/"
                         "source/latex/graphics/"
                         "tex/latex/graphics/")
                   (base32
                    "0prw1zcv4fcj3zg0kyhj0k7ax0530adl60bajzvbv3fi16d7rqlq"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/graphics")
         ((#:build-targets _ '())
          #~(list "graphics-drivers.ins" "graphics.ins"))))
      (propagated-inputs (list texlive-graphics-def texlive-graphics-cfg))
      (home-page "https://ctan.org/macros/latex/required/graphics")
      (synopsis "The LaTeX standard graphics bundle")
      (description
       "This is a collection of LaTeX packages for: producing colour including
graphics (e.g., PostScript) files rotation and scaling of text in LaTeX
documents.  It comprises the packages color, graphics, graphicx, trig, epsfig,
keyval, and lscape.")
      (license license:lppl1.3c))))

(define-deprecated-package texlive-latex-graphics texlive-graphics)

(define-public texlive-greek-fontenc
  (package
    (inherit (simple-texlive-package
              "texlive-greek-fontenc"
              (list "doc/latex/greek-fontenc/"
                    "tex/latex/greek-fontenc/"
                    "source/latex/greek-fontenc/")
              (base32
               "1ncsvj5mlnkgllrvqdnbkv0qwpv2y7jkq3x2wdmm7d3daqq0ka5h")
              #:trivial? #t))
    (home-page "https://ctan.org/language/greek/greek-fontenc")
    (synopsis "LICR macros and encoding definition files for Greek")
    (description
     "The package provides Greek LICR macro definitions and encoding definition files
for Greek text font encodings for use with fontenc.")
    (license license:lppl1.3+)))

(define-public texlive-hycolor
  (let ((template  (simple-texlive-package
                    "texlive-hycolor"
                    (list "doc/latex/hycolor/"
                          "source/latex/hycolor/"
                          "tex/latex/hycolor/")
                    (base32
                     "0hmkx37wwmznxjqqnca87shy7qrgqrh2cn5r941ddgivnym31xbh"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/hycolor")
         ((#:build-targets _ '())
          #~(list "hycolor.dtx"))))
      (home-page "https://www.ctan.org/pkg/latex-graphics")
      (synopsis "Color for hyperref and bookmark")
      (description
       "This package provides the code for the @code{color} option that is
used by @code{hyperref} and @code{bookmark}.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-latex-hycolor texlive-hycolor)

(define-public texlive-xcolor
  (let ((template (simple-texlive-package
                   "texlive-xcolor"
                   (list "doc/latex/xcolor/"
                         "dvips/xcolor/"
                         "source/latex/xcolor/"
                         "tex/latex/xcolor/")
                   (base32
                    "1d7108b67fcaf1sgyk43ph18l0z5m35iqg3aahqs1ymzwdfnd3f7"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/xcolor")
         ((#:build-targets _ '())
          #~(list "xcolor.ins"))))
      ;; TODO: Propagate texlive-hyperref and many others in the next rebuild
      ;; cycle.  Grep for '\usepackage' to see what packages it requires.
      ;; (propagated-inputs (list texlive-hyperref ...))
      (home-page "https://www.ctan.org/pkg/xcolor")
      (synopsis "Driver-independent color extensions for LaTeX and pdfLaTeX")
      (description
       "The package starts from the basic facilities of the colorcolor package,
and provides easy driver-independent access to several kinds of color tints,
shades, tones, and mixes of arbitrary colors.  It allows a user to select a
document-wide target color model and offers complete tools for conversion
between eight color models.  Additionally, there is a command for alternating
row colors plus repeated non-aligned material (like horizontal lines) in
tables.")
      (license license:lppl1.2+))))

(define-deprecated-package texlive-latex-xcolor texlive-xcolor)

(define-public texlive-xmltex
  (let ((template (simple-texlive-package
                   "texlive-xmltex"
                   (list
                    "/doc/otherformats/xmltex/"
                    "/tex/xmltex/")
                   (base32
                    "023gv9axq05vwqz50fnkig24dzahwlc4raks2s8xc4pzrv2dv1zy"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t)
          "tex/xmltex/base")
         ((#:phases phases '%standard-phases)
          `(modify-phases ,phases
             (add-before 'install 'generate-formats
               (lambda* (#:key inputs #:allow-other-keys)
                 (mkdir "web2c")
                 (for-each (lambda (f)
                             (copy-file f (basename f)))
                           (find-files "tex" "\\.(ini|tex)$"))
                 (invoke "fmtutil-sys" "--byfmt" "xmltex"
                         "--fmtdir=web2c")
                 (invoke "fmtutil-sys" "--byfmt" "pdfxmltex"
                         "--fmtdir=web2c")))
             (add-after 'install 'install-formats-and-wrappers
               (lambda* (#:key inputs outputs #:allow-other-keys)
                 (let* ((out (assoc-ref outputs "out"))
                        (texlive-bin (assoc-ref inputs "texlive-bin"))
                        (pdftex (string-append texlive-bin "/bin/pdftex"))
                        (web2c (string-append out "/share/texmf-dist/web2c")))
                   (mkdir-p web2c)
                   (copy-recursively "web2c" web2c)
                   ;; Create convenience command wrappers.
                   (mkdir-p (string-append out "/bin"))
                   (symlink pdftex (string-append out "/bin/xmltex"))
                   (symlink pdftex (string-append out "/bin/pdfxmltex"))
                   #t)))))))
      (propagated-inputs
       ;; The following fonts are propagated as a texlive-updmap.cfg as the font
       ;; maps need to be recreated for the fonts to be usable.  They are
       ;; required by xmltex through mlnames.sty and unicode.sty.
       `(("texlive" ,(texlive-updmap.cfg
                      (list
                       texlive-amsfonts
                       texlive-babel
                       texlive-courier
                       texlive-helvetic
                       texlive-hyperref
                       texlive-symbol
                       texlive-tipa
                       texlive-times
                       texlive-zapfding
                       ;; The following fonts, while not required, are used if
                       ;; available:
                       texlive-stmaryrd
                       texlive-wasy)))))
      (native-inputs
       (list texlive-tex-ini-files))
      (home-page "https://www.ctan.org/pkg/xmltex/")
      (synopsis "Support for parsing XML documents")
      (description "The package provides an implementation of a parser for
documents matching the XML 1.0 and XML Namespace Recommendations.  Element and
attribute names, as well as character data, may use any characters allowed in
XML, using UTF-8 or a suitable 8-bit encoding.")
      (license license:lppl1.0+))))        ;per xmltex/base/readme.txt

(define-public texlive-hyperref
  (let ((template (simple-texlive-package
                   "texlive-hyperref"
                   (list "doc/latex/hyperref/"
                         "source/latex/hyperref/"
                         "tex/latex/hyperref/")
                   (base32 "052k1nygm4msaivn8245n86km4h41knivigw80q58b7rc13s6hrk"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/hyperref")
         ((#:build-targets _ '())
          #~(list "hyperref.ins"))))
      (propagated-inputs
       (list texlive-atbegshi
             texlive-auxhook
             texlive-bitset
             texlive-cm
             texlive-etexcmds
             texlive-gettitlestring
             texlive-graphics           ;for keyval
             texlive-hycolor
             texlive-intcalc
             texlive-kvdefinekeys
             texlive-kvsetkeys
             texlive-letltxmacro
             texlive-ltxcmds
             texlive-pdfescape
             texlive-refcount
             texlive-rerunfilecheck
             texlive-stringenc
             texlive-url
             texlive-zapfding))
      (home-page "https://www.ctan.org/pkg/hyperref")
      (synopsis "Extensive support for hypertext in LaTeX")
      (description
       "The @code{hyperref} package is used to handle cross-referencing commands
in LaTeX to produce hypertext links in the document.  The package provides
backends for the @code{\\special} set defined for HyperTeX DVI processors; for
embedded @code{pdfmark} commands for processing by Acrobat
Distiller (@code{dvips} and Y&Y's @code{dvipsone}); for Y&Y's @code{dviwindo};
for PDF control within pdfTeX and @code{dvipdfm}; for TeX4ht; and for VTeX's
pdf and HTML backends.  The package is distributed with the @code{backref} and
@code{nameref} packages, which make use of the facilities of @code{hyperref}.")
      (license license:lppl1.3+))))

(define-deprecated-package texlive-latex-hyperref texlive-hyperref)

(define-public texlive-hyperxmp
  (package
    (name "texlive-hyperxmp")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/hyperxmp/"
                   "doc/man/man1/hyperxmp-add-bytecount.1"
                   "doc/man/man1/hyperxmp-add-bytecount.man1.pdf"
                   "scripts/hyperxmp/"
                   "source/latex/hyperxmp/"
                   "tex/latex/hyperxmp/")
             (base32
              "177wx80mc6ipl0ciddnwgjjfg9vqv71y9ql0y69sviplyy533ng7")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'fix-build
            (lambda _
              (delete-file "source/latex/hyperxmp/hyperxmp-stds.tex"))))))
    (propagated-inputs
     (list texlive-atenddvi
           texlive-etoolbox
           texlive-hyperref
           texlive-ifmtarg
           texlive-iftex
           texlive-intcalc
           texlive-kvoptions
           texlive-luacode
           texlive-oberdiek             ;for ifdraft
           texlive-pdfescape
           texlive-stringenc
           texlive-totpages))
    (home-page "https://ctan.org/pkg/hyperxmp")
    (synopsis "Embed XMP metadata within a LaTeX document")
    (description
     "XMP (eXtensible Metadata Platform) is a mechanism proposed by Adobe for
embedding document metadata, within the document itself.  The metadata is
designed to be easy to extract, even by programs that are oblivious to the
document's file format.  The @code{hyperxmp} package makes it trivial for
LaTeX document authors to store XMP metadata in their documents as well.  It
is compatible with pdfLaTeX, XeLaTeX, LaTeX+dvipdfm, and LaTeX+dvips+ps2pdf.")
    (license license:lppl1.3c)))

(define-public texlive-oberdiek
  (let ((template (simple-texlive-package
                   "texlive-oberdiek"
                   (list "bibtex/bib/oberdiek/"
                         "doc/latex/oberdiek/"
                         "source/latex/oberdiek/"
                         "tex/generic/oberdiek/"
                         "tex/latex/oberdiek/")
                   (base32
                    "00lp24fckawpy997j7zagsxv89jif40wgjq8fw502v06d225ikp3"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/oberdiek")
         ((#:build-targets _ '())
          #~(list "oberdiek.ins"))))
      (propagated-inputs
       (list texlive-auxhook
             texlive-grfext
             texlive-grffile
             texlive-iftex
             texlive-infwarerr
             texlive-kvoptions
             texlive-pdftexcmds))
      (home-page "https://www.ctan.org/pkg/oberdiek")
      (synopsis "Bundle of packages submitted by Heiko Oberdiek")
      (description
       "The bundle comprises various LaTeX packages, providing among others:
better accessibility support for PDF files; extensible chemists reaction
arrows; record information about document class(es) used; and many more.")
      (license license:lppl1.3+))))

(define-deprecated-package texlive-latex-oberdiek texlive-oberdiek)

(define-public texlive-regexpatch
  (package
    (name "texlive-regexpatch")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/regexpatch/"
                   "source/latex/regexpatch/"
                   "tex/latex/regexpatch/")
             (base32
              "1jv8hvkvq0yvc8mh68ybj8fvhf6kcdzwjin1czs45i26s0dpsngj")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-l3kernel
           texlive-l3packages))
    (home-page "https://ctan.org/pkg/regexpatch")
    (synopsis "High level patching of commands")
    (description
     "The package generalises the macro patching commands provided by
P. Lehmann's @code{etoolbox}.  The difference between this package and its
sibling @code{xpatch} is that this package sports a very powerful
@code{\\regexpatchcmd} based on the @code{l3regex} module of the LaTeX3
experimental packages.")
    (license license:lppl1.3c)))

(define-public texlive-rerunfilecheck
  (let ((template (simple-texlive-package
                   "texlive-rerunfilecheck"
                   (list "doc/latex/rerunfilecheck/"
                         "source/latex/rerunfilecheck/"
                         "tex/latex/rerunfilecheck/")
                   (base32
                    "0f53b6dlnlrxkzj7h7x750p0489i2gg3isfqn0dlpncpq23w1r36"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/rerunfilecheck")
         ((#:build-targets _ '())
          #~(list "rerunfilecheck.dtx"))))
      (propagated-inputs
       (list texlive-atveryend
             texlive-infwarerr
             texlive-kvoptions
             texlive-pdftexcmds
             texlive-uniquecounter))
      (home-page "https://www.ctan.org/pkg/rerunfilecheck")
      (synopsis "Checksum based rerun checks on auxiliary files")
      (description
       "This package provides additional rerun warnings if some auxiliary
files have changed.  It is based on MD5 checksum, provided by pdfTeX.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-latex-rerunfilecheck texlive-rerunfilecheck)

(define-public texlive-onedown
  (let ((template
         (simple-texlive-package
          "texlive-onedown"
          (list "doc/latex/onedown/"
                "source/latex/onedown/"
                "tex/latex/onedown/")
          (base32
           "04ih7i4v96ggwk4k1mpfx3dzcpi2siqablv93wryg7dk4cks5wkl"))))
    (package
      (inherit template)
      (outputs '("doc" "out"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t) "latex/onedown")))
      (home-page "https://ctan.org/pkg/onedown")
      (synopsis "Typeset bridge diagrams")
      (description
       "This is a comprehensive package to draw all sorts of bridge diagrams,
including hands, bidding tables, trick tables, and expert quizzes.

It works for all font sizes.  Different fonts for hands, bidding diagrams and
compass are possible.  It also provides annotations to card and bidding
diagrams, automated check on consistency of suit and hands, and multilingual
output of bridge terms.")
      (license license:lppl1.3+))))

(define-public texlive-tools
  (let ((template (simple-texlive-package
                   "texlive-tools"
                   (list "doc/latex/tools/"
                         "source/latex/tools/"
                         "tex/latex/tools/")
                   (base32
                    "0c0ixkcvrlzx6sdj25ak3bx0j65qghf51w66yg5wlnpg08d3awrs"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/tools")
         ((#:build-targets _ '())
          #~(list "tools.ins"))))
      (home-page "https://www.ctan.org/tex-archive/macros/latex/required/tools/")
      (synopsis "LaTeX standard tools bundle")
      (description "This package provides a collection of simple tools that
are part of the LaTeX required tools distribution, comprising the packages:
@code{afterpage}, @code{array}, @code{bm}, @code{calc}, @code{dcolumn},
@code{delarray}, @code{enumerate}, @code{fileerr}, @code{fontsmpl},
@code{ftnright}, @code{hhline}, @code{indentfirst}, @code{layout},
@code{longtable}, @code{multicol}, @code{rawfonts}, @code{showkeys},
@code{somedefs}, @code{tabularx}, @code{theorem}, @code{trace},
@code{varioref}, @code{verbatim}, @code{xr}, and @code{xspace}.")
      (license license:lppl1.3+))))

(define-deprecated-package texlive-latex-tools texlive-tools)

(define-public texlive-url
  (package
    (inherit (simple-texlive-package
              "texlive-url"
              (list "/doc/latex/url/"
                    "/tex/latex/url/")
              (base32
               "184m40wgnx939ky2hbxnj0v9aak023ldrhgffp0lgyk9wdqpxlqg")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/url")
    (synopsis "Verbatim with URL-sensitive line breaks")
    (description "The command @code{\\url} is a form of verbatim command that
allows linebreaks at certain characters or combinations of characters, accepts
reconfiguration, and can usually be used in the argument to another command.
The command is intended for email addresses, hypertext links,
directories/paths, etc., which normally have no spaces, so by default the
package ignores spaces in its argument.  However, a package option allows
spaces, which is useful for operating systems where spaces are a common part
of file names.")
    ;; The license header states that it is under LPPL version 2 or later, but
    ;; the latest version is 1.3c.
    (license license:lppl1.3c+)))

(define-deprecated-package texlive-latex-url texlive-url)

(define-public texlive-tetex
  (package
    (inherit (simple-texlive-package
              "texlive-tetex"
              (list "/dvips/tetex/"
                    "/fonts/enc/dvips/tetex/"
                    "/fonts/map/dvips/tetex/")
              (base32
               "05mf8yqdj2wrc1zm3al2j4aam2wx0ky6a7slxw17pkd1c7rmvjrq")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/tetex")
    (synopsis "Font maps originally from teTeX")
    (description "This package provides font maps that were originally part of
the now obsolete teTeX distributions but are still used at the core of the TeX
Live distribution.")
    (license license:public-domain)))

(define-public texlive-l3kernel
  (package
    (name "texlive-l3kernel")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/l3kernel/"
                   "source/latex/l3kernel/"
                   "tex/latex/l3kernel/")
             (base32
              "1y7wcb2643cfwda86f5zpbbw3hj01rji7r143ln77k8nr1919jj1")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:tex-engine "tex"
      #:tex-format #f
      #:texlive-latex-base #f))
    (native-inputs
     (list texlive-docstrip))
    (propagated-inputs
     (list texlive-l3backend))
    (home-page "https://ctan.org/pkg/l3kernel")
    (synopsis "LaTeX3 programming conventions")
    (description
     "The l3kernel bundle provides an implementation of the LaTeX3 programmers
interface, as a set of packages that run under LaTeX2e.  The interface
provides the foundation on which the LaTeX3 kernel and other future code are
built: it is an API for TeX programmers.  The packages are set up so that the
LaTeX3 conventions can be used with regular LaTeX2e packages.")
    (license license:lppl1.3c+)))

(define-deprecated-package texlive-latex-l3kernel texlive-l3kernel)

(define-public texlive-l3backend
  (package
    (name "texlive-l3backend")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/l3backend/"
                   "dvips/l3backend/"
                   "source/latex/l3backend/"
                   "tex/latex/l3backend/")
             (base32
              "18i6aczhj7pvqgdwfgkbmjz7a8xgd5w2jhibrv8khqlvxp62in94")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:tex-engine "tex"
      #:tex-format #f
      #:texlive-latex-base #f))
    (native-inputs
     (list texlive-docstrip))
    (home-page "https://ctan.org/pkg/l3backend")
    (synopsis "LaTeX3 backend drivers")
    (description
     "This package forms parts of expl3, and contains the code used to
interface with backends (drivers) across the expl3 codebase.  The functions
here are defined differently depending on the engine in use.  As such, these
are distributed separately from l3kernel to allow this code to be updated on
an independent schedule.")
    (license license:lppl1.3c)))

(define-deprecated-package texlive-dvips-l3backend texlive-l3backend)
(define-deprecated-package texlive-latex-l3backend texlive-l3backend)

(define-public texlive-l3packages
  (package
    (name "texlive-l3packages")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/l3packages/"
                   "source/latex/l3packages/l3keys2e/"
                   "source/latex/l3packages/xfp/"
                   "source/latex/l3packages/xfrac/"
                   "source/latex/l3packages/xparse/"
                   "source/latex/l3packages/xtemplate/"
                   "tex/latex/l3packages/l3keys2e/"
                   "tex/latex/l3packages/xfp/"
                   "tex/latex/l3packages/xfrac/"
                   "tex/latex/l3packages/xparse/"
                   "tex/latex/l3packages/xtemplate/")
             (base32
              "1k9zms255qz6i24k74g7wnyrdvshl52jgb198pmg6mj9ajhw9sks")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:build-targets
      '(list "l3keys2e.ins"
             "xparse.ins"
             "xfrac.ins"
             "xfp.ins"
             "xtemplate.ins")
      #:tex-engine "tex"
      #:tex-format #f
      #:texlive-latex-base #f))
    (native-inputs
     (list texlive-docstrip))
    (propagated-inputs
     (list texlive-l3kernel))
    (home-page "https://ctan.org/pkg/l3packages")
    (synopsis "High-level LaTeX3 concepts")
    (description
     "This collection contains implementations for aspects of the LaTeX3
kernel, dealing with higher-level ideas such as the Designer Interface.  The
packages here are considered broadly stable (The LaTeX3 Project does not
expect the interfaces to alter radically).  These packages are built on
LaTeX2e conventions at the interface level, and so may not migrate in the
current form to a stand-alone LaTeX3 format.

Packages provided are @code{xparse}, which provides a high-level interface for
declaring document commands @code{xfp}, an expandable IEEE 754 FPU for LaTeX,
@code{l3keys2e}, which makes the facilities of the kernel module l3keys
available for use by LaTeX 2e packages, @code{xtemplate}, which provides
a means of defining generic functions using a key-value syntax, and
@code{xfrac}, which provides flexible split-level fractions.")
    (license license:lppl1.3c)))

(define-deprecated-package texlive-latex-l3packages texlive-l3packages)

(define-public texlive-fontspec
  (let ((template (simple-texlive-package
                   "texlive-fontspec"
                   (list "/doc/latex/fontspec/"
                         "/source/latex/fontspec/"
                         "/tex/latex/fontspec/fontspec.cfg")
                   (base32
                    "06rms8dw1j67v3rgv6xmfykdmgbxi5rp78yxc782cy1sw07blgsg"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t)
          "latex/fontspec")))
      (propagated-inputs
       (list texlive-cm texlive-l3packages texlive-lm))
      (home-page "https://www.ctan.org/pkg/fontspec")
      (synopsis "Advanced font selection in XeLaTeX and LuaLaTeX")
      (description
       "Fontspec is a package for XeLaTeX and LuaLaTeX.  It provides an
automatic and unified interface to feature-rich AAT and OpenType fonts through
the NFSS in LaTeX running on XeTeX or LuaTeX engines.  The package requires
the l3kernel and xparse bundles from the LaTeX 3 development team.")
      (license license:lppl1.3+))))

(define-deprecated-package texlive-latex-fontspec texlive-fontspec)

(define-public texlive-grffile
  (package
    (name "texlive-grffile")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/grffile/"
                   "source/latex/grffile/"
                   "tex/latex/grffile/")
             (base32
              "01mlvdhqwfwj1l91jfvkdfbn1hj95rlb6xhwikzx1r8qrz5whw7n")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://www.ctan.org/pkg/grffile")
    (synopsis "Extended file name support for graphics (legacy package)")
    (description
     "The original @code{grffile} package extended the file name processing
of the @code{graphics} package to support a larger range of file names.  The
base LaTeX code now supports multiple dots and spaces, and this package by
default is a stub that just loads @code{graphicx}.")
    (license license:lppl1.3c+)))

(define-public texlive-stringenc
  (package
    (name "texlive-stringenc")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/stringenc/"
                   "source/latex/stringenc/"
                   "tex/generic/stringenc/")
             (base32
              "1pz9fgn3zc1brbpkw2kkphsv8q6vpvbn51n0smmfl1n2m97fni9j")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/stringenc")
    (synopsis "Converting a string between different encodings")
    (description
     "This package provides @code{\\StringEncodingConvert} for converting a
string between different encodings.  Both LaTeX and plain-TeX are supported.")
    (license license:lppl1.3c+)))

(define-public texlive-svn-prov
  (package
    (name "texlive-svn-prov")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/svn-prov/" "source/latex/svn-prov/"
                   "tex/latex/svn-prov/")
             (base32
              "1w416cf1yb1m2j9y38002zq6rbhbmkafi7w100y9m9lrzya0ws06")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/svn-prov")
    (synopsis "Subversion variants of @code{\\Provides}... macros")
    (description
     "The package introduces Subversion variants of the standard LaTeX macros
@code{\\ProvidesPackage}, @code{\\ProvidesClass} and @code{\\ProvidesFile}
where the file name and date is extracted from Subversion Id keywords.  The
file name may also be given explicitly as an optional argument.")
    (license license:lppl)))

(define-public texlive-l3build
  (let ((template (simple-texlive-package
                   "texlive-l3build"
                   (list "/doc/latex/l3build/"
                         "/doc/man/man1/l3build.1"
                         "/scripts/l3build/"
                         "/tex/latex/l3build/"
                         ;; TODO: The dtx file builds only the documentation.
                         ;; We avoid this for a simpler package definition,
                         ;; but it may be possible to exclude
                         ;; /doc/latex/l3build and the man page in the future.
                         "/source/latex/l3build/")
                   (base32
                    "1fcay05jj53qgp2b98jpawi0id298fs5xc4y1r5krrfr4sp4hd59")
                   #:trivial? #t)))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:phases phases)
          `(modify-phases ,phases
             (add-after 'install 'patch-shebangs-again
               (lambda* (#:key inputs outputs #:allow-other-keys)
                 ;; XXX: Since the 'patch-shebangs' phase cannot change the
                 ;; original source files patch the shebangs again here.
                 (let* ((coreutils (assoc-ref inputs "coreutils"))
                        (texlive-bin (assoc-ref inputs "texlive-bin"))
                        (path (list (string-append coreutils "/bin")
                                    (string-append texlive-bin "/bin"))))
                   (for-each (lambda (file)
                               (format #t "~a~%" file)
                               (patch-shebang file path))
                             (find-files (assoc-ref outputs "out")))
                   #t)))))))
      (inputs
       (list coreutils texlive-bin))
      (home-page "https://github.com/latex3/luaotfload")
      (synopsis "Testing and building system for LaTeX")
      (description
       "The l3build module is designed to support the development of
high-quality LaTeX code by providing: a unit testing system, automated
typesetting of code sources, and a reliable packaging system for CTAN
releases.  The bundle consists of a Lua script to run the tasks and a
@code{.tex} file which provides the testing environment.")
      (license license:lppl1.3c+))))

(define-public texlive-luabidi
  (package
    (name "texlive-luabidi")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/lualatex/luabidi/"
                   "tex/lualatex/luabidi/")
             (base32
              "1dwdiwsdfhgwpx8r2271i5kqphcpkh69y3rx1wxfr9hl17lzw2cp")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-bigfoot              ;for "perpage.sty"
           texlive-etoolbox))
    (home-page "https://ctan.org/pkg/luabidi")
    (synopsis "Bidi functions for LuaTeX")
    (description
     "The package attempts to emulate the XeTeX @code{bidi} package, in the
context of LuaTeX.")
    (license (list license:lppl1.3c license:expat))))

(define-public texlive-luacode
  (package
    (name "texlive-luacode")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/lualatex/luacode/"
                   "source/lualatex/luacode/"
                   "tex/lualatex/luacode/")
             (base32
              "1dyld5yb57p3j7wz591plbgjy7dk7ngn8cxw1lfmvx8iprgk1f8d")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-iftex
           texlive-luatexbase))
    (home-page "https://ctan.org/pkg/luacode")
    (synopsis "Helper for executing Lua code from within TeX")
    (description
     "Executing Lua code from within TeX with directlua can sometimes be
tricky: there is no easy way to use the percent character, counting
backslashes may be hard, and Lua comments don't work the way you expect.  The
package provides the @code{\\luaexec} command and the @code{luacode}
environments to help with these problems.")
    (license license:lppl1.3+)))

(define-public texlive-lualatex-math
  (package
    (name "texlive-lualatex-math")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/lualatex/lualatex-math/"
                   "source/lualatex/lualatex-math/"
                   "tex/lualatex/lualatex-math/")
             (base32
              "1xfr31rwr7zc6d5bsc3v5lwvcfrg109rzfgvvs69w4xs61j06jcg")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-etoolbox texlive-filehook))
    (home-page "https://ctan.org/pkg/lualatex-math")
    (synopsis "Fixes for mathematics-related LuaLaTeX issues")
    (description
     "The package patches a few commands of the LaTeX2e kernel and the
@code{amsmath} and @code{mathtools} packages to be more compatible with the
LuaTeX engine.  It is only meaningful for LuaLaTeX documents containing
mathematical formulas, and does not exhibit any new functionality.  The fixes
are mostly moved from the @code{unicode-math} package to this package since
they are not directly related to Unicode mathematics typesetting.")
    (license license:lppl1.3c)))

(define-public texlive-lualibs
  (package
    (inherit
     (simple-texlive-package
      "texlive-lualibs"
      (list "doc/luatex/lualibs/"
            "source/luatex/lualibs/"
            "tex/luatex/lualibs/")
      (base32 "0gf60vj9y75a7dlrmpbyqgsa00s1717r6if3lm5ldm41i9fm8ywz")
      ;; The source dtx file only unpacks three files.  This is why we
      ;; install all the files as they are, because there is no clear
      ;; way to generate them all.
      #:trivial? #true))
    (home-page "https://ctan.org/macros/luatex/generic/lualibs")
    (synopsis "Additional Lua functions for LuaTeX macro programmers")
    (description
     "Lualibs is a collection of Lua modules useful for general programming.
The bundle is based on Lua modules shipped with ConTeXt, and made available in
this bundle for use independent of ConTeXt.")
    ;; GPL version 2 only
    (license license:gpl2)))

(define-deprecated-package texlive-luatex-lualibs texlive-lualibs)

(define-public texlive-lua-alt-getopt
  (package
    (inherit
     (simple-texlive-package
      "texlive-lua-alt-getopt"
      (list "doc/support/lua-alt-getopt/" "scripts/lua-alt-getopt/")
      (base32 "0cizxzn33n3pn98xkqnxb8s6vdwkar3xrwhraqrs05pjfdn9d4wz")
      #:trivial? #t))
    (home-page "https://ctan.org/support/lualibs/lua-alt-getopt")
    (synopsis "Process application arguments the same way as getopt_long")
    (description
     "This package provides a Lua module for processing application arguments
in the same way as BSD/GNU @code{getopt_long(3)} functions do.")
    (license license:expat)))

(define-public texlive-luatexbase
  (package
    (name "texlive-luatexbase")
    (version (number->string %texlive-revision))
    (source (texlive-origin

             name version
             (list "doc/luatex/luatexbase/"
                   "source/luatex/luatexbase/"
                   "tex/luatex/luatexbase/")
             (base32
              "1nz2k9czqdmn08v75qa2bwanvcvyp9jmqcgwaxcy4fy4mpbrn8ra")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-ctablestack))
    (home-page "https://ctan.org/pkg/luatexbase")
    (synopsis "Basic resource management for LuaTeX code")
    (description
     "The LaTeX kernel builds in support for LuaTeX functionality, also
available as @file{ltluatex.tex} for users of plain TeX and those with older
LaTeX kernel implementations.  This support is based on ideas taken from the
original @code{luatexbase} package, but there are interface differences.  This
stub package provides a compatibility layer to allow existing packages to
upgrade smoothly to the new support structure.")
    (license license:lppl1.3+)))

;; TODO: We should be able to build this from the sources on Github with
;; texlive-l3build, but I haven't been able to get it to work.
(define-public texlive-luaotfload
  (let ((template (simple-texlive-package
                   "texlive-luaotfload"
                   (list "/doc/luatex/luaotfload/"
                         "/doc/man/man1/luaotfload-tool.1"
                         "/doc/man/man5/luaotfload.conf.5"
                         "/source/luatex/luaotfload/fontloader-reference-load-order.lua"
                         "/source/luatex/luaotfload/fontloader-reference-load-order.tex"
                         "/scripts/luaotfload/luaotfload-tool.lua"
                         "/tex/luatex/luaotfload/")
                   (base32
                    "10wznvxx3qsl88n560py5vyx5r3a3914anbqfhwcmhmwg097xxl4")
                   #:trivial? #t)))
    (package
      (inherit template)
      (propagated-inputs
       (list texlive-lua-alt-getopt ;for luaotfload-tool
             texlive-lualibs))
      (home-page "https://github.com/lualatex/luaotfload")
      (synopsis "OpenType font loader for LuaTeX")
      (description
       "Luaotfload is an adaptation of the ConTeXt font loading system for the
Plain and LaTeX formats.  It allows OpenType fonts to be loaded with font
features accessible using an extended font request syntax while providing
compatibilitywith XeTeX.  By indexing metadata in a database it facilitates
loading fonts by their proper names instead of file names.")
      ;; GPL version 2 only
      (license license:gpl2))))

(define-deprecated-package texlive-luatex-luaotfload texlive-luaotfload)

(define-public texlive-amsmath
  (let ((template (simple-texlive-package
                   "texlive-amsmath"
                   (list "/doc/latex/amsmath/"
                         "/source/latex/amsmath/"
                         ;; These two files are not generated from any of the
                         ;; dtx/ins files.
                         "/tex/latex/amsmath/amsmath-2018-12-01.sty"
                         "/tex/latex/amsmath/amstex.sty")
                   (base32
                    "0gmdzhgr0h57xhsl61c5jsp4fj4pbmdr8p6k96am5jbyrbbx121q"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t)
          "latex/amsmath")))
      (propagated-inputs
       (list texlive-amsfonts))
      (home-page "https://www.ctan.org/pkg/amsmath")
      (synopsis "AMS mathematical facilities for LaTeX")
      (description
       "This is the principal package in the AMS-LaTeX distribution.  It adapts
for use in LaTeX most of the mathematical features found in AMS-TeX; it is
highly recommended as an adjunct to serious mathematical typesetting in LaTeX.
When amsmath is loaded, AMS-LaTeX packages @code{amsbsyamsbsy} (for bold
symbols), @code{amsopnamsopn} (for operator names) and
@code{amstextamstext} (for text embedded in mathematics) are also loaded.
This package is part of the LaTeX required distribution; however, several
contributed packages add still further to its appeal; examples are
@code{empheqempheq}, which provides functions for decorating and highlighting
mathematics, and @code{ntheoremntheorem}, for specifying theorem (and similar)
definitions.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-latex-amsmath texlive-amsmath)

(define-public texlive-mathdots
  (let ((template
         (simple-texlive-package
          "texlive-mathdots"
          (list "doc/generic/mathdots/"
                "source/generic/mathdots/"
                "tex/generic/mathdots/")
          (base32"1jaffj343p1chdxs2g7s6lpckvihk0jfw22nw0vmijyjxfiy9yg0"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/mathdots")
         ((#:build-targets _ '())
          '(list "mathdots.ins"))))
      (home-page "https://ctan.org/macros/generic/mathdots")
      (synopsis "Commands to produce dots in math that respect font size")
      (description
       "Mathdots redefines @code{\\ddots} and @code{\\vdots}, and defines
@code{\\iddots}.  The dots produced by @code{\\iddots} slant in the opposite
direction to @code{\\ddots}.  All the commands are designed to change size
appropriately in scripts, as well as in response to LaTeX size changing
commands.  The commands may also be used in plain TeX.")
      (license license:lppl))))

(define-public texlive-amscls
  (let ((template (simple-texlive-package
                   "texlive-amscls"
                   (list "/doc/latex/amscls/"
                         "/source/latex/amscls/"
                         "/bibtex/bst/amscls/")
                   (base32
                    "0vw0b815slvfqfd8qffyfzb3xfvyv6k77m12xp0l67hs8p08s5b7"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t)
          "latex/amscls")))
      (home-page "https://www.ctan.org/pkg/amscls")
      (synopsis "AMS document classes for LaTeX")
      (description
       "This bundle contains three AMS classes: @code{amsartamsart} (for writing
articles for the AMS), @code{amsbookamsbook} (for books) and
@code{amsprocamsproc} (for proceedings), together with some supporting
material.  The material is made available as part of the AMS-LaTeX
distribution.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-latex-amscls texlive-amscls)

(define-public texlive-babel
  (let ((template (simple-texlive-package
                   "texlive-babel"
                   (list "/doc/latex/babel/"
                         "/source/latex/babel/"
                         "/makeindex/babel/")
                   (base32
                    "0qr5vjp79g1c1l6k173qhfdfabgbky73wymzhm56pazx4a8r08wz"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t)
          "generic/babel")
         ((#:phases phases)
          `(modify-phases ,phases
             ;; This package tries to produce babel.aux twice but refuses to
             ;; overwrite the first one.
             (add-before 'build 'fix-ins
               (lambda _
                 (substitute* "source/latex/babel/babel.ins"
                   (("askonceonly") "askforoverwritefalse"))))
             (add-after 'install 'install-locales
               (lambda* (#:key outputs #:allow-other-keys)
                 (let ((locale-directory
                        (string-append (assoc-ref outputs "out")
                                       "/share/texmf-dist/tex/generic/babel/locale/")))
                   (mkdir-p locale-directory)
                   (invoke "unzip" "locale.zip" "-d"
                           locale-directory))))))))
      (native-inputs
       (list unzip))
      (home-page "https://www.ctan.org/pkg/babel")
      (synopsis "Multilingual support for Plain TeX or LaTeX")
      (description
       "The package manages culturally-determined typographical (and other)
rules, and hyphenation patterns for a wide range of languages.  A document may
select a single language to be supported, or it may select several, in which
case the document may switch from one language to another in a variety of
ways.  Babel uses contributed configuration files that provide the detail of
what has to be done for each language.  Users of XeTeX are advised to use the
polyglossia package rather than Babel.")
      (license license:lppl1.3+))))

(define-deprecated-package texlive-latex-babel texlive-babel)

(define-public texlive-cs
  (package
    (inherit (simple-texlive-package
              "texlive-cs"
              (list
               "fonts/enc/dvips/cs/"
               "fonts/map/dvips/cs/"
               "fonts/source/public/cs/"
               ;; TODO: Remove these pre-built files after the manual
               ;; build below is fixed.
               ;; The font fails to build from the Metafont sources, with
               ;; errors such as:
               ;; This is METAFONT, Version 2.71828182 (TeX Live 2021/GNU Guix) [...]
               ;; (./csaccent.mf
               ;; >> cap_curve#-dot_size#
               ;; ! Unknown relation will be considered false.
               ;; <to be read again>
               "fonts/tfm/cs/cs-a35/"
               "fonts/tfm/cs/cs-charter/"
               "fonts/tfm/public/cs/"
               "fonts/type1/public/cs/"
               "fonts/vf/cs/cs-a35/")
              (base32 "1ww5lrqja051fh0ygmfdyy5a6bhwq9k5zv857vwiqf5syvw5djps")
              #:trivial? #t))
    (home-page "https://petr.olsak.net/cstex/")
    (synopsis "Czech/Slovak-tuned Computer Modern fonts")
    (description "This package provides Czech/Slovak-tuned Computer Modern
fonts in the Metafont format; Type 1 format versions (csfonts-t1) are also
available.")
    (license license:gpl2+)))           ;see fonts/source/public/cs/cscode.mf

;;; Note: if this package is modified, its name must be changed to comply with
;;; its license.
(define-public texlive-csplain
  (package
    (inherit (simple-texlive-package
              "texlive-csplain"
              (list "tex/csplain/base/")
              (base32 "0cgrwc8lgf2x2hq6bb4kqxw597card985zdd9ipn7k98mmwrxhz3")
              #:trivial? #t))
    (home-page "https://petr.olsak.net/csplain-e.html")
    (synopsis "Plain TeX multilanguage support")
    (description "CSplain is a small extension of basic Plain TeX macros from
which the formats @code{csplain} and @code{pdfcsplain} can be generated.  It
supports: hyphenation of words for 50+ languages, simple and powerful font
loading system (various sizes of fonts), TeX, pdfTeX, XeTeX and LuaTeX
engines, math fonts simply loaded with full amstex-like features, three
internal encodings (IL2 for Czech/Slovak languages, T1 for many languages with
latin alphabet and Unicode in new TeX engines), natural UTF-8 input in pdfTeX
using encTeX without any active characters, Czech and Slovak special
typesetting features.  An important part of the package is OPmac, which
implements most of LaTeX's features (sectioning, font selection, color, hyper
reference and URLs, bibliography, index, table of contents, tables, etc.) by
Plain TeX macros.  The OPmac macros can generate a bibliography without any
external program.")
    ;; This custom permissive license includes as a redistribution condition
    ;; that says the package must be renamed from 'csplain' if it is modified.
    (license (license:non-copyleft "file:///tex/csplain/base/csplain.ini"))))

(define-public texlive-babel-english
  (package
    (name "texlive-babel-english")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/generic/babel-english/"
                   "source/generic/babel-english/"
                   "tex/generic/babel-english/")
             (base32
              "0fh8xxxh79za80yvgypf8clzj0lk237lfyqfkl233id9rlias08d")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/babel-english")
    (synopsis "Babel support for English")
    (description
     "The package provides the language definition file for support of
English in @code{babel}.  Care is taken to select british hyphenation patterns
for British English and Australian text, and default (american) patterns for
Canadian and USA text.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-generic-babel-english texlive-babel-english)

(define-public texlive-babel-french
  (let ((template
         (simple-texlive-package
          "texlive-babel-french"
          (list "doc/generic/babel-french/"
                "source/generic/babel-french/"
                "tex/generic/babel-french/")
          (base32 "0cgn4dq5wnlfh9wddjzxsf7p56pk29lyndg56zg6558y7xf67cw8"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/babel-french")
         ((#:build-targets _ '())
          ;; TODO: use dtx and build documentation.
          '(list "frenchb.ins"))))
      (home-page "https://ctan.org/macros/latex/contrib/babel-contrib/french")
      (synopsis "Babel contributed support for French")
      (description
       "The package, formerly known as frenchb, establishes French conventions
in a document (or a subset of the conventions, if French is not the main
language of the document).")
      (license license:lppl1.3+))))

(define-deprecated-package texlive-generic-babel-french texlive-babel-french)

(define-public texlive-babel-german
  (package
    (name "texlive-babel-german")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/generic/babel-german/"
                   "source/generic/babel-german/"
                   "tex/generic/babel-german/")
             (base32
              "0iwnn35xnpczi2gxrzrgyilh30qbnj6w05p3q0gvcmnisawfva9q")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/babel-german")
    (synopsis "Babel support for documents written in German")
    (description
     "This bundle is an extension to the babel package for multilingual typesetting.
It provides all the necessary macros, definitions and settings to typeset
German documents.  The bundle includes support for the traditional and
reformed German orthography as well as for the Austrian and Swiss varieties of
German.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-generic-babel-german texlive-babel-german)

(define-public texlive-babel-swedish
  (let ((template (simple-texlive-package
                   "texlive-babel-swedish"
                   (list "/source/generic/babel-swedish/")
                   (base32
                    "03rp4n9wkqyckman765r8v8j2pg5fg9frbfxsnhq0i2mr0yhbr6v"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/babel-swedish")
         ((#:build-targets _ '())
          ''("swedish.ins"))))
      (home-page "https://www.ctan.org/pkg/babel-swedish")
      (synopsis "Babel support for Swedish")
      (description "This package provides the language definition file for
support of Swedish in @code{babel}.  It provides all the necessary macros,
definitions and settings to typeset Swedish documents.")
      (license license:lppl1.3c+))))

(define-public texlive-cyrillic
  (package
    (name "texlive-cyrillic")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/cyrillic/"
                   "source/latex/cyrillic/"
                   "tex/latex/cyrillic/")
             (base32
              "0a1dcpdgnzf08cd1b9ihdk4229aw19ar0f5sfjr44fqqwkav3l5i")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:tex-engine "tex"
      #:tex-format #f
      #:texlive-latex-base #f))
    (native-inputs
     (list texlive-docstrip))
    (home-page "https://ctan.org/pkg/cyrillic")
    (synopsis "Support for Cyrillic fonts in LaTeX")
    (description
     "This bundle of macros files provides macro support (including font
encoding macros) for the use of Cyrillic characters in fonts encoded under the
T2* and X2 encodings.  These encodings cover (between them) pretty much every
language that is written in a Cyrillic alphabet.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-cyrillic texlive-cyrillic)

(define-public texlive-passivetex
  (package
    (name "texlive-passivetex")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "tex/xmltex/passivetex/")
             (base32
              "1h49v6sqbm27isfwwcql9dzxn4vmcn2algkqh7f1pzj860xw3ygn")))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-amsfonts
           texlive-graphics
           texlive-hyperref
           texlive-marvosym
           texlive-psnfss
           texlive-tipa
           texlive-times
           texlive-tools
           texlive-ulem
           texlive-url))
    (home-page "https://ctan.org/pkg/passivetex")
    (synopsis "Support package for XML/SGML typesetting")
    (description
     "This is a set of packages providing XML parsing, UTF-8 parsing,
Unicode entities, and common formatting object definitions for JadeTeX.")
    ;; License given in "tex/xmltex/passivetex/mlnames.sty".
    (license license:lppl1.0+)))

(define-public texlive-pict2e
  (let ((template (simple-texlive-package
                   "texlive-pict2e"
                   (list "doc/latex/pict2e/"
                         "source/latex/pict2e/"
                         "tex/latex/pict2e/")
                   (base32
                    "0pazv1khsgjhxc673qrhjrbzlkgmcj53qccb9hw7ygdajxrjc2ba"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t) "latex/pict2e")
         ((#:build-targets _ '()) '(list "pict2e.ins"))
         ((#:phases phases)
          #~(modify-phases #$phases
              (add-after 'build 'build-doc
                (lambda _
                  (copy-file "p2e-drivers.dtx" "build/p2e-drivers.dtx")
                  (with-directory-excursion "build"
                    (invoke "pdflatex" "p2e-drivers.dtx")
                    (delete-file "p2e-drivers.dtx")
                    ;; texlive.tlpbd expects a "pict2e.cfg" configuration file
                    ;; instead of "pict2e-example.cfg".  Please it.
                    (rename-file "pict2e-example.cfg" "pict2e.cfg"))))))))
      (home-page "https://ctan.org/pkg/pict2e")
      (native-inputs
       (list (texlive-updmap.cfg)))
      (synopsis "New implementation of picture commands")
      (description
       "This package extends the existing LaTeX @code{picture} environment,
using the familiar technique (the @code{graphics} and @code{color} packages)
of driver files (at present, drivers for dvips, pdfTeX, LuaTeX, XeTeX, VTeX,
dvipdfm, and dvipdfmx are available).  The package documentation has a fair
number of examples of use, showing where things are improved by comparison
with the LaTeX @code{picture} environment.")
      (license license:lppl1.3+))))

(define-public texlive-psnfss
  (let ((template (simple-texlive-package
                   "texlive-psnfss"
                   (list "/doc/latex/psnfss/"
                         "/source/latex/psnfss/"
                         "/fonts/map/dvips/psnfss/"

                         ;; Only the .sty files are generated from the sources.
                         "/tex/latex/psnfss/8rbch.fd"
                         "/tex/latex/psnfss/8rpag.fd"
                         "/tex/latex/psnfss/8rpbk.fd"
                         "/tex/latex/psnfss/8rpcr.fd"
                         "/tex/latex/psnfss/8rphv.fd"
                         "/tex/latex/psnfss/8rpnc.fd"
                         "/tex/latex/psnfss/8rppl.fd"
                         "/tex/latex/psnfss/8rptm.fd"
                         "/tex/latex/psnfss/8rput.fd"
                         "/tex/latex/psnfss/8rpzc.fd"
                         "/tex/latex/psnfss/omlbch.fd"
                         "/tex/latex/psnfss/omlpag.fd"
                         "/tex/latex/psnfss/omlpbk.fd"
                         "/tex/latex/psnfss/omlpcr.fd"
                         "/tex/latex/psnfss/omlphv.fd"
                         "/tex/latex/psnfss/omlpnc.fd"
                         "/tex/latex/psnfss/omlppl.fd"
                         "/tex/latex/psnfss/omlptm.fd"
                         "/tex/latex/psnfss/omlptmcm.fd"
                         "/tex/latex/psnfss/omlput.fd"
                         "/tex/latex/psnfss/omlpzc.fd"
                         "/tex/latex/psnfss/omlzplm.fd"
                         "/tex/latex/psnfss/omlzpple.fd"
                         "/tex/latex/psnfss/omlztmcm.fd"
                         "/tex/latex/psnfss/omsbch.fd"
                         "/tex/latex/psnfss/omspag.fd"
                         "/tex/latex/psnfss/omspbk.fd"
                         "/tex/latex/psnfss/omspcr.fd"
                         "/tex/latex/psnfss/omsphv.fd"
                         "/tex/latex/psnfss/omspnc.fd"
                         "/tex/latex/psnfss/omsppl.fd"
                         "/tex/latex/psnfss/omsptm.fd"
                         "/tex/latex/psnfss/omsput.fd"
                         "/tex/latex/psnfss/omspzc.fd"
                         "/tex/latex/psnfss/omspzccm.fd"
                         "/tex/latex/psnfss/omszplm.fd"
                         "/tex/latex/psnfss/omszpple.fd"
                         "/tex/latex/psnfss/omsztmcm.fd"
                         "/tex/latex/psnfss/omxpsycm.fd"
                         "/tex/latex/psnfss/omxzplm.fd"
                         "/tex/latex/psnfss/omxzpple.fd"
                         "/tex/latex/psnfss/omxztmcm.fd"
                         "/tex/latex/psnfss/ot1bch.fd"
                         "/tex/latex/psnfss/ot1pag.fd"
                         "/tex/latex/psnfss/ot1pbk.fd"
                         "/tex/latex/psnfss/ot1pcr.fd"
                         "/tex/latex/psnfss/ot1phv.fd"
                         "/tex/latex/psnfss/ot1pnc.fd"
                         "/tex/latex/psnfss/ot1ppl.fd"
                         "/tex/latex/psnfss/ot1pplj.fd"
                         "/tex/latex/psnfss/ot1pplx.fd"
                         "/tex/latex/psnfss/ot1ptm.fd"
                         "/tex/latex/psnfss/ot1ptmcm.fd"
                         "/tex/latex/psnfss/ot1put.fd"
                         "/tex/latex/psnfss/ot1pzc.fd"
                         "/tex/latex/psnfss/ot1zplm.fd"
                         "/tex/latex/psnfss/ot1zpple.fd"
                         "/tex/latex/psnfss/ot1ztmcm.fd"
                         "/tex/latex/psnfss/t1bch.fd"
                         "/tex/latex/psnfss/t1pag.fd"
                         "/tex/latex/psnfss/t1pbk.fd"
                         "/tex/latex/psnfss/t1pcr.fd"
                         "/tex/latex/psnfss/t1phv.fd"
                         "/tex/latex/psnfss/t1pnc.fd"
                         "/tex/latex/psnfss/t1ppl.fd"
                         "/tex/latex/psnfss/t1pplj.fd"
                         "/tex/latex/psnfss/t1pplx.fd"
                         "/tex/latex/psnfss/t1ptm.fd"
                         "/tex/latex/psnfss/t1put.fd"
                         "/tex/latex/psnfss/t1pzc.fd"
                         "/tex/latex/psnfss/ts1bch.fd"
                         "/tex/latex/psnfss/ts1pag.fd"
                         "/tex/latex/psnfss/ts1pbk.fd"
                         "/tex/latex/psnfss/ts1pcr.fd"
                         "/tex/latex/psnfss/ts1phv.fd"
                         "/tex/latex/psnfss/ts1pnc.fd"
                         "/tex/latex/psnfss/ts1ppl.fd"
                         "/tex/latex/psnfss/ts1pplj.fd"
                         "/tex/latex/psnfss/ts1pplx.fd"
                         "/tex/latex/psnfss/ts1ptm.fd"
                         "/tex/latex/psnfss/ts1put.fd"
                         "/tex/latex/psnfss/ts1pzc.fd"
                         "/tex/latex/psnfss/ufplm.fd"
                         "/tex/latex/psnfss/ufplmbb.fd"
                         "/tex/latex/psnfss/upsy.fd"
                         "/tex/latex/psnfss/upzd.fd")
                   (base32
                    "11f14dzhwsy4pli21acccip43d36nf3pac33ihjffnps1i2mhqkd"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t)
          "latex/psnfss")))
      (native-inputs
       (list texlive-cm))
      (home-page "https://www.ctan.org/pkg/psnfss")
      (synopsis "Font support for common PostScript fonts")
      (description
       "The PSNFSS collection includes a set of files that provide a complete
working setup of the LaTeX font selection scheme (NFSS2) for use with common
PostScript fonts.  The base set of text fonts covered by PSNFSS includes the
AvantGarde, Bookman, Courier, Helvetica, New Century Schoolbook, Palatino,
Symbol, Times Roman and Zapf Dingbats fonts.  In addition, the fonts Bitstream
Charter and Adobe Utopia are covered.  Separate packages are provided to load
each font for use as the main text font.  The package @code{helvet} allows
Helvetica to be loaded with its size scaled to something more appropriate for
use as a Sans-Serif font to match Times, while @code{pifont} provides the
means to select single glyphs from symbol fonts.  The bundle as a whole is
part of the LaTeX required set of packages.")
      (license license:lppl1.2+))))

(define-deprecated-package texlive-latex-psnfss texlive-psnfss)

;; For user profiles
(define-public texlive-base
  (let ((default-packages
          (list texlive-bin
                texlive-cm
                texlive-cm-super        ; to avoid bitmap fonts
                texlive-dvips
                texlive-fontname
                texlive-graphics
                texlive-kpathsea        ;for mktex.opt
                texlive-latex-base
                texlive-latex-fonts
                texlive-metafont
                ;; LaTeX packages from the "required" set.
                texlive-amsmath
                texlive-amscls
                texlive-babel
                texlive-babel-english
                texlive-cyrillic
                texlive-psnfss
                texlive-tools
                texlive-tetex)))
    (package
      (name "texlive-base")
      (version (number->string %texlive-revision))
      (source #f)
      (build-system trivial-build-system)
      (arguments
       '(#:builder
         (begin (mkdir (assoc-ref %outputs "out")))))
      (propagated-inputs
       (map (lambda (package)
              (list (package-name package) package))
            default-packages))
      (home-page (package-home-page texlive-bin))
      (synopsis "TeX Live base packages")
      (description "This is a very limited subset of the TeX Live distribution.
It includes little more than the required set of LaTeX packages.")
      (license (fold (lambda (package result)
                       (match (package-license package)
                         ((lst ...)
                          (append lst result))
                         ((? license:license? license)
                          (cons license result))))
                     '()
                     default-packages)))))

(define-public texlive-default-updmap.cfg
  (origin
    (method url-fetch)
    (uri (string-append "https://tug.org/svn/texlive/tags/"
                        %texlive-tag "/Master/texmf-dist/web2c/updmap.cfg"
                        "?revision=" (number->string %texlive-revision)))
    (file-name (string-append "updmap.cfg-"
                              (number->string %texlive-revision)))
    (sha256
     (base32
      "0zhpyld702im6352fwp41f2hgfkpj2b4j1kfsjqbkijlcmvb6w2c"))))

;;; TODO: Add a TeX Live profile hook computing fonts maps (and others?)
;;; configuration from the packages in the profile, similar to what's done
;;; below.
(define-public texlive-updmap.cfg
  (lambda* (#:optional (packages '()))
    "Return a 'texlive-updmap.cfg' package which contains the fonts map
configuration of a base set of packages plus PACKAGES."
    (let ((default-packages (match (package-propagated-inputs texlive-base)
                              (((labels packages) ...) packages))))
      (package
        (version (number->string %texlive-revision))
        (source (origin
                  (method url-fetch)
                  (uri (string-append "https://tug.org/svn/texlive/tags/"
                                      %texlive-tag
                                      "/Master/texmf-dist/web2c/updmap.cfg"
                                      "?revision=" version))
                  (file-name "updmap.cfg")
                  (sha256
                   (base32
                    "0zhpyld702im6352fwp41f2hgfkpj2b4j1kfsjqbkijlcmvb6w2c"))))
        (name "texlive-updmap.cfg")
        (build-system copy-build-system)
        (arguments
         '(#:modules ((guix build copy-build-system)
                      (guix build utils)
                      (ice-9 popen)
                      (ice-9 textual-ports))
           #:install-plan '(("updmap.cfg" "share/texmf-config/web2c/")
                            ("map" "share/texmf-dist/fonts/map"))
           #:phases
           (modify-phases %standard-phases
             (add-before 'install 'regenerate-updmap.cfg
               (lambda _
                 (make-file-writable "updmap.cfg")

                 ;; Disable unavailable map files.
                 (let* ((port (open-pipe* OPEN_WRITE "updmap-sys"
                                          "--syncwithtrees"
                                          "--nohash"
                                          "--cnffile" "updmap.cfg")))
                   (display "Y\n" port)
                   (when (not (zero? (status:exit-val (close-pipe port))))
                     (error "failed to filter updmap.cfg")))

                 ;; Set TEXMFSYSVAR to a sane and writable value; updmap fails
                 ;; if it cannot create its log file there.
                 (setenv "TEXMFSYSVAR" (getcwd))

                 ;; Generate maps.
                 (invoke "updmap-sys"
                         "--cnffile"           "updmap.cfg"
                         "--dvipdfmxoutputdir" "map/dvipdfmx/updmap/"
                         "--dvipsoutputdir"    "map/dvips/updmap/"
                         "--pdftexoutputdir"   "map/pdftex/updmap/"))))))
        (propagated-inputs (map (lambda (package)
                                  (list (package-name package) package))
                                (append default-packages packages)))
        (home-page (package-home-page texlive-bin))
        (synopsis "TeX Live fonts map configuration")
        (description "This package contains the fonts map configuration file
generated for the base TeX Live packages as well as, optionally, user-provided
ones.")
        (license (delete-duplicates
                  (fold (lambda (package result)
                          (match (package-license package)
                            ((lst ...)
                             (append lst result))
                            ((? license:license? license)
                             (cons license result))))
                        '()
                        (append default-packages packages))))))))

(define-deprecated/alias texlive-union texlive-updmap.cfg)
(export texlive-union)

;; For use in package definitions only
(define-public texlive-tiny
  (package
    (inherit (texlive-updmap.cfg))
    (name "texlive-tiny")
    (description "This is a very limited subset of the TeX Live distribution.
It includes little more than the required set of LaTeX packages.")))

(define-public texlive-tipa
  (package
    (inherit (simple-texlive-package
              "texlive-tipa"
              (list "/tex4ht/ht-fonts/alias/tipa/"
                    "/doc/fonts/tipa/"
                    "/fonts/map/dvips/tipa/"
                    "/fonts/source/public/tipa/"
                    "/fonts/tfm/public/tipa/"
                    "/fonts/type1/public/tipa/"
                    "/tex/latex/tipa/")
              (base32
               "0cqzf8vb10b8jw99m9gflskxa4c3rpiznxglix6chl5lai5sgw44")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/tipa")
    (synopsis "Fonts and macros for IPA phonetics characters")
    (description "These fonts are considered the \"ultimate answer\" to IPA
typesetting.  The encoding of these 8-bit fonts has been registered as LaTeX
standard encoding T3, and the set of addendum symbols as encoding
TS3. \"Times-like\" Adobe Type 1 versions are provided for both the T3 and the
TS3 fonts.")
    (license license:lppl)))

(define-public texlive-amsrefs
  (package
    (name "texlive-amsrefs")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "bibtex/bib/amsrefs/" "bibtex/bst/amsrefs/"
                   "doc/latex/amsrefs/" "source/latex/amsrefs/"
                   "tex/latex/amsrefs/")
             (base32
              "12la66vz5ic6jc1cy96b2zh2fxsbaii9kbs4wrz1ii8v508wdkhv")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-hyperref texlive-url))
    (home-page "https://ctan.org/pkg/amsrefs")
    (synopsis "LaTeX-based replacement for BibTeX")
    (description
     "Amsrefs is a LaTeX package for bibliographies that provides an
archival data format similar to the format of BibTeX database files, but
adapted to make direct processing by LaTeX easier.  The package can be used
either in conjunction with BibTeX or as a replacement for BibTeX.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-amsrefs texlive-amsrefs)

(define-public texlive-bigfoot
  (let ((template (simple-texlive-package
                   "texlive-bigfoot"
                   (list "doc/latex/bigfoot/"
                         "source/latex/bigfoot/"
                         "tex/latex/bigfoot/")
                   (base32
                    "140b4bbjcgajd1flznmi3ga6lx5pna2nxybr2dqm9515lny8gwf0"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t) "latex/bigfoot")
         ((#:build-targets _ '()) '(list "bigfoot.ins"))
         ((#:phases phases)
          #~(modify-phases #$phases
              (add-after 'chdir 'delete-drv-files
                (lambda _
                  (for-each delete-file (find-files "." "\\.drv$"))))))))
      (propagated-inputs
       (list texlive-etex texlive-ncctools))
      (home-page "https://ctan.org/pkg/bigfoot")
      (synopsis "Footnotes for critical editions")
      (description
       "The package aims to provide a one-stop solution to requirements for
footnotes.  It offers multiple footnote apparatus superior to that of
@code{manyfoot}.  Footnotes can be formatted in separate paragraphs, or be run
into a single paragraph.  Note that the majority of the @code{bigfoot}
package's interface is identical to that of @code{manyfoot}; users should seek
information from that package's documentation.

The @code{bigfoot} bundle also provides the @code{perpage} and @code{suffix}
packages.")
      (license license:gpl2+))))

(define-deprecated-package texlive-latex-bigfoot texlive-bigfoot)

(define-public texlive-blindtext
  (package
    (name "texlive-blindtext")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/blindtext/"
                   "source/latex/blindtext/"
                   "tex/latex/blindtext/")
             (base32
              "1gakawih3mzm5jh01kb44sjpsa4r8c3zwzig5bac37g4ha2vqska")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-tools))
    (home-page "https://ctan.org/pkg/blindtext")
    (synopsis "Producing 'blind' text for testing")
    (description
     "The package provides the commands @code{\\blindtext} and
@code{\\Blindtext} for creating \"blind\" text useful in testing new classes
and packages, and @code{\\blinddocument}, @code{\\Blinddocument} for creating
an entire random document with sections, lists, mathematics, etc.  The package
supports three languages, @code{english}, @code{(n)german} and @code{latin};
the @code{latin} option provides a short \"lorem ipsum\" (for a fuller \"lorem
ipsum\" text, see the @code{lipsum} package).")
    (license license:lppl)))

(define-deprecated-package texlive-latex-blindtext texlive-blindtext)

(define-public texlive-dinbrief
  (package
    (name "texlive-dinbrief")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/dinbrief/"
                   "source/latex/dinbrief/"
                   "tex/latex/dinbrief/")
             (base32
              "0l6mmn3y07xglmh3h5f7pnpmyacqb2g6nqgq3q1p6k97kf708c5s")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'fix-build
            (lambda _
              (with-fluids ((%default-port-encoding "ISO-8859-1"))
                (with-directory-excursion "source/latex/dinbrief"
                  (delete-file "dinbrief.drv")
                  (substitute* "dinbrief.dtx"
                    (("zur Verf.+ung. In der Pr\"aambel")
                     "zur Verf\"ung. In der Pr\"aambel")))))))))
    (home-page "https://ctan.org/pkg/dinbrief")
    (synopsis "German letter DIN style")
    (description
     "This package implements a document layout for writing letters according
to the rules of DIN (Deutsches Institut für Normung, German standardisation
institute).  A style file for LaTeX 2.09 (with limited support of the
features) is part of the package.  Since the letter layout is based on a
German standard, the user guide is written in German, but most macros have
English names from which the user can recognize what they are used for.  In
addition there are example files showing how letters may be created with the
package.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-dinbrief texlive-dinbrief)

(define-public texlive-draftwatermark
  (package
    (name "texlive-draftwatermark")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/draftwatermark/"
                   "source/latex/draftwatermark/"
                   "tex/latex/draftwatermark/")
             (base32
              "04l3gqiq0bhzbz8zxr7428fap2x1skkaq5ppbambc4lk8c7iw6da")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-everypage texlive-graphics texlive-kvoptions))
    (home-page "https://ctan.org/pkg/draftwatermark")
    (synopsis "Put a grey textual watermark on document pages")
    (description
     "This package provides a means to add a textual, light grey watermark
on every page or on the first page of a document.  Typical usage may consist
in writing words such as DRAFT or CONFIDENTIAL across document pages.  The
package performs a similar function to that of @code{draftcopy}, but its
implementation is output device independent, and made very simple by relying
on @code{everypage}.")
    (license license:lppl1.3+)))

(define-public texlive-enctex
  (package
    (name "texlive-enctex")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/generic/enctex/"
                   "tex/generic/enctex/")
             (base32
              "1j8ji1ka8vhskm5kn0iwmkhjfp88ly6rva30pr1c9llsmsac5sf2")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/enctex")
    (synopsis "TeX extension that translates input on its way into TeX")
    (description
     "EncTeX is (another) TeX extension, written at the change-file level.  It
provides means of translating input on the way into TeX.  It allows, for
example, translation of multibyte sequences, such as utf-8 encoding.")
    (license license:gpl3+)))

(define-public texlive-environ
  (package
    (name "texlive-environ")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/environ/"
                   "source/latex/environ/"
                   "tex/latex/environ/")
             (base32
              "08a3vhyzc647b9zp3yifdklj0vch9cv2vajh7ig3y01jcdqhjy41")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs (list texlive-trimspaces))
    (home-page "https://ctan.org/pkg/environ")
    (synopsis "A new interface for environments in LaTeX")
    (description
     "This package provides the @code{\\collect@@body} command (as in
@code{amsmath}), as well as a @code{\\long} version @code{\\Collect@@Body},
for collecting the body text of an environment.  These commands are used to
define a new author interface to creating new environments.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-environ texlive-environ)

(define-public texlive-eqparbox
  (package
    (name "texlive-eqparbox")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/eqparbox/"
                   "source/latex/eqparbox/"
                   "tex/latex/eqparbox/")
             (base32
              "16c5dyd4bz45a2c1ppbq05h9ixg15srk5az5pld5gpv4j0zwzrqw")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-environ texlive-tools))
    (home-page "https://ctan.org/pkg/eqparbox")
    (synopsis "Create equal-widthed parboxes")
    (description
     "LaTeX users sometimes need to ensure that two or more blocks of text
occupy the same amount of horizontal space on the page.  To that end, the
@code{eqparbox} package defines a new command, @code{\\eqparbox}, which works
just like @code{\\parbox}, except that instead of specifying a width, one
specifies a tag.  All @code{eqparbox}es with the same tag---regardless of
where they are in the document---will stretch to fit the widest
@code{eqparbox} with that tag.  This simple, equal-width mechanism can be used
for a variety of alignment purposes, as is evidenced by the examples in
@code{eqparbox}'s documentation.  Various derivatives of @code{\\eqparbox} are
also provided.")
    (license license:lppl1.3c)))

(define-deprecated-package texlive-latex-eqparbox texlive-eqparbox)

(define-public texlive-etoc
  (package
    (name "texlive-etoc")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/etoc/"
                   "source/latex/etoc/"
                   "tex/latex/etoc/")
             (base32
              "04vjfn4jadxbc38r08r9pwvpj7szvk88hiav35iqhl3p78xri7z4")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/etoc")
    (synopsis "Customisable table of contents")
    (description
     "This package gives the user complete control of how the entries of the
table of contents should be constituted from the name, number, and page number
of each sectioning unit.  The layout is controlled by the definition of line
styles for each sectioning level used in the document.

The package provides its own custom line styles (which may be used as
examples), and continues to support the standard formatting inherited from the
LaTeX document classes, but the package can also allow the user to delegate
the details to packages dealing with list making environments (such as
@code{enumitem}).  The package's default global style typesets tables of
contents in a multi-column format, with either a standard heading, or a ruled
title
(optionally with a frame around the table).

The @code{\\tableofcontents} command may be used arbitrarily many times in the
same document, while @code{\\localtableofcontents} provides a local table of
contents.")
    (license license:lppl1.3c)))

(define-deprecated-package texlive-latex-etoc texlive-etoc)

(define-public texlive-expdlist
  (package
    (name "texlive-expdlist")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/expdlist/"
                   "source/latex/expdlist/"
                   "tex/latex/expdlist/")
             (base32
              "1kylmj615hmbmjbynn5bfzhfz0wk1drxmg0kjqljnglffkb6irv6")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/expdlist")
    (synopsis "Expanded description environments")
    (description
     "The package provides additional features for the LaTeX @code{description} environment,
including adjustable left margin.  The package also allows the user to break
a list (for example, to interpose a comment) without affecting the structure
of the list (this works for itemize and eumerate lists and numbered lists
remain in sequence).")
    (license license:lppl)))

(define-deprecated-package texlive-latex-expdlist texlive-expdlist)

(define-public texlive-filemod
  (package
    (inherit (simple-texlive-package
              "texlive-filemod"
              (list "/doc/latex/filemod/"
                    "/tex/latex/filemod/"
                    "/tex/generic/filemod/")
              (base32
               "1snsj7kblkj1ig3x3845lsypz7ab04lf0dcpdh946xakgjnz4fb5")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/filemod")
    (synopsis "Provide file modification times, and compare them")
    (description
     "This package provides macros to read and compare the modification dates
of files.  The files may be @code{.tex} files, images or other files (as long
as they can be found by LaTeX).  It uses the @code{\\pdffilemoddate} primitive
of pdfLaTeX to find the file modification date as PDF date string, parses the
string and returns the value to the user.  The package will also work for DVI
output with recent versions of the LaTeX compiler which uses pdfLaTeX in DVI
mode.  The functionality is provided by purely expandable macros or by faster
but non-expandable ones.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-filemod texlive-filemod)

(define-public texlive-hanging
  (package
    (name "texlive-hanging")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/hanging"
                   "source/latex/hanging"
                   "tex/latex/hanging/")
             (base32
              "1d9kr163vn9sm9p9dyppnnffdcdjlgrm7848d97s678hdb9cp962")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://www.ctan.org/pkg/hanging")
    (synopsis "Typeset hanging paragraphs")
    (description
     "The @code{hanging} package facilitates the typesetting of hanging
paragraphs.  The package also enables typesetting with hanging punctuation,
by making punctuation characters active.")
    (license license:lppl1.3c+)))

(define-deprecated-package texlive-latex-hanging texlive-hanging)

(define-public texlive-fira
  (package
    (inherit (simple-texlive-package
              "texlive-fira"
              (list "doc/fonts/fira/"
                    "tex/latex/fira/"
                    "fonts/vf/public/fira/"
                    "fonts/type1/public/fira/"
                    "fonts/tfm/public/fira/"
                    "fonts/opentype/public/fira/"
                    "fonts/map/dvips/fira/"
                    "fonts/enc/dvips/fira/")
              (base32 "1v3688hziqz4jywfysiv19vsdzfkknrf83zfbi7lhiqpgkpsfsm2")
              #:trivial? #t))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/fonts/fira")
    (synopsis "Fira fonts with LaTeX support")
    (description
     "This package provides LaTeX, pdfLaTeX, XeLaTeX and LuaLaTeX support for
the Fira Sans family of fonts designed by Erik Spiekermann and Ralph du
Carrois of Carrois Type Design.  Fira Sans is available in eleven weights with
corresponding italics: light, regular, medium, bold, ...")
    (license (list license:lppl
                   license:silofl1.1))))

(define-public texlive-firstaid
  (let ((template (simple-texlive-package
                   "texlive-firstaid"
                   (list "/doc/latex/firstaid/"
                         "/source/latex/firstaid/"
                         "/tex/latex/firstaid/")
                   (base32
                    "1ahn47kz8a2qdmzdfdgjanf6h5bn8f2rzp1zvwgjpk1plcix8k90"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t) "tex/latex/firstaid")
         ((#:build-targets _ '()) '(list "firstaid.ins"))))
      (home-page "https://ctan.org/macros/latex/required/firstaid")
      (synopsis
       "First aid for external LaTeX files and packages that need updating")
      (description
       "This package contains some first aid for LaTeX packages or classes
that require updates because of internal changes to the LaTeX kernel that are
not yet reflected in the package's or class's code.  The file
@file{latex2e-first-aid-for-external-files.ltx} provided by this package is
meant to be loaded during format generation and not by the user.")
      (license license:lppl1.3c))))

(define-public texlive-ifplatform
  (package
    (name "texlive-ifplatform")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/ifplatform/"
                   "source/latex/ifplatform/"
                   "tex/latex/ifplatform/")
             (base32
              "1llas0xwq3y9nk7gblg40l99cgmkl9r7rbfazrhpnbaz5cshl8pl")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-catchfile
           texlive-iftex
           texlive-pdftexcmds
           texlive-tools))
    (home-page "https://ctan.org/pkg/ifplatform")
    (synopsis "Conditionals to test which platform is being used")
    (description
     "This package uses the (La)TeX extension @samp{-shell-escape} to
establish whether the document is being processed on a Windows or on
a Unix-like system, or on Cygwin.

Booleans provided are: @code{\\ifwindows}, @code{\\iflinux}, @code{\\ifmacosx}
and @code{\\ifcygwin}.  The package also preserves the output of
@command{uname} on a Unix-like system, which may be used to distinguish
between various classes of Unix systems.")
    (license license:lppl1.3c)))

(define-deprecated-package texlive-latex-ifplatform texlive-ifplatform)

(define-public texlive-natbib
  (package
    (name "texlive-natbib")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "bibtex/bst/natbib/" "doc/latex/natbib/"
                   "source/latex/natbib/" "tex/latex/natbib/")
             (base32
              "17hyba6v24wrbjvakgjxkndjb418mmi2wmnhrm7zmfwb0bvy6f2j")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/natbib")
    (synopsis "Flexible bibliography support")
    (description
     "The bundle provides a package that implements both author-year and
numbered references, as well as much detailed of support for other
bibliography use.  Also Provided are versions of the standard BibTeX styles
that are compatible with natbib--plainnat, unsrtnat, abbrnat.  The
bibliography styles produced by custom-bib are designed from the start to be
compatible with @code{natbib}.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-natbib texlive-natbib)

(define-public texlive-newfloat
  (package
    (name "texlive-newfloat")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/newfloat/"
                   "source/latex/newfloat/"
                   "tex/latex/newfloat/")
             (base32
              "1hrackdfrzad8cgbl3f3yaagk4p4zjbvq710rm8b1z02fr9z2zkq")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics))
    (home-page "https://ctan.org/pkg/newfloat")
    (synopsis "Define new floating environments")
    (description
     "This package offers the command @code{\\DeclareFloatingEnvironment},
which the user may use to define new floating environments which behave like
the LaTeX standard foating environments @code{figure} and @code{table}.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-newfloat texlive-newfloat)

(define-public texlive-newunicodechar
  (package
    (name "texlive-newunicodechar")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/newunicodechar/" "source/latex/newunicodechar"
                   "tex/latex/newunicodechar/")
             (base32
              "0mybqah1n9vmxvi6f587jlxbn7pv3624qw83psq5vwfnddw3n70y")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://www.ctan.org/pkg/newunicodechar")
    (synopsis "Definitions of the meaning of Unicode characters")
    (description
     "This package provides a friendly interface for defining the meaning of
Unicode characters.  The document should be processed by (pdf)LaTeX with the
Unicode option of @code{inputenc} or @code{inputenx}, or by XeLaTeX/LuaLaTeX.")
    (license license:lppl1.3c+)))

(define-deprecated-package texlive-latex-newunicodechar texlive-newunicodechar)

(define-public texlive-newverbs
  (package
    (name "texlive-newverbs")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/newverbs/" "source/latex/newverbs/"
                   "tex/latex/newverbs/")
             (base32
              "1m3afrpyc75g5gdxfknad565r5jgmwks98skkqycm66i92ky9dqr")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (native-inputs
     (list texlive-ydoc))
    (home-page "https://ctan.org/pkg/newverbs")
    (synopsis "Define new versions of @code{\\verb}")
    (description
     "The package allows the definition of @code{\\verb} variants which add
TeX code before and after the verbatim text (e.g., quotes or surrounding
@code{\\fbox@{@}}).  When used together with the @code{shortvrb} package it
allows the definition of short verbatim characters which use this package's
variant instead of the normal @code{\\verb}.  In addition, it is possible to
collect an argument verbatim to either typeset or write it into a file.  The
@code{\\Verbdef} command defines verbatim text to a macro which can later be
used to write the verbatim text to a file.")
    (license license:lppl1.3+)))

(define-public texlive-pdftexcmds
  (let ((template (simple-texlive-package
                   "texlive-pdftexcmds"
                   (list "doc/generic/pdftexcmds/"
                         "source/generic/pdftexcmds/"
                         "tex/generic/pdftexcmds/")
                   (base32
                    "0gad1vi0r5xw7gyj1cb2cp58j4dqrw4awcfxmfrna9xbz91g4sn9"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/pdftexcmds")
         ((#:build-targets _ '())
          #~(list "pdftexcmds.dtx"))))
      (propagated-inputs
       (list texlive-iftex texlive-infwarerr texlive-ltxcmds))
      (home-page "https://www.ctan.org/pkg/pdftexcmds")
      (synopsis "LuaTeX support for pdfTeX utility functions")
      (description
       "This package makes a number of utility functions from pdfTeX
available for LuaTeX by reimplementing them using Lua.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-latex-pdftexcmds texlive-pdftexcmds)

(define-public texlive-psfrag
  (package
    (name "texlive-psfrag")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/psfrag/"
                   "dvips/psfrag/"
                   "source/latex/psfrag/"
                   "tex/latex/psfrag/")
             (base32
              "06vp5x6rnl4gqwxzzynbl169q23k8pmaxjhb0lbzdcm3ihvzp47z")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics))
    (home-page "https://ctan.org/pkg/psfrag")
    (synopsis "Replace strings in encapsulated PostScript figures")
    (description
     "This package allows LaTeX constructions (equations, picture
environments, etc.) to be precisely superimposed over Encapsulated PostScript
figures, using your own favorite drawing tool to create an EPS figure and
placing simple text tags where each replacement is to be placed, with PSfrag
automatically removing these tags from the figure and replacing them with
a user specified LaTeX construction, properly aligned, scaled, and/or
rotated.")
    (license (license:fsf-free "file://psfrag.dtx"))))

(define-deprecated-package texlive-latex-psfrag texlive-psfrag)

(define-public texlive-pstool
  (package
    (inherit (simple-texlive-package
              "texlive-pstool"
              (list "/doc/latex/pstool/"
                    "/tex/latex/pstool/")
              (base32
               "12clzcw2cl7g2chr2phgmmiwxw4859cln1gbx1wgp8bl9iw590nc")
              #:trivial? #t))
    (propagated-inputs
     (list texlive-bigfoot ; for suffix
           texlive-filemod
           texlive-graphics
           texlive-ifplatform
           texlive-l3kernel ; for expl3
           texlive-oberdiek
           texlive-psfrag
           texlive-tools                ; for shellesc
           texlive-trimspaces
           texlive-xkeyval))
    (home-page "https://www.ctan.org/pkg/pstool")
    (synopsis "Process PostScript graphics within pdfLaTeX documents")
    (description
     "This is a package for processing PostScript graphics with @code{psfrag}
labels within pdfLaTeX documents.  Every graphic is compiled individually,
drastically speeding up compilation time when only a single figure needs
re-processing.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-pstool texlive-pstool)

(define-public texlive-refcount
  (let ((template (simple-texlive-package
                   "texlive-refcount"
                   (list "doc/latex/refcount/"
                         "source/latex/refcount/"
                         "tex/latex/refcount/")
                   (base32
                    "128cvwdl4wcdshvs59yn5iljdxxdrc5jircbxav77y7kc3l33z7z"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/refcount")
         ((#:build-targets _ '())
          #~(list "refcount.dtx"))))
      (home-page "https://www.ctan.org/pkg/refcount")
      (synopsis "Counter operations with label references")
      (description
       "This package provides the @code{\\setcounterref} and
@code{\\addtocounterref} commands which use the section (or other) number
from the reference as the value to put into the counter.  It also provides
@code{\\setcounterpageref} and @code{\\addtocounterpageref} that do the
corresponding thing with the page reference of the label.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-latex-refcount texlive-refcount)

(define-public texlive-selinput
  (package
    (name "texlive-selinput")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/selinput/" "source/latex/selinput/"
                   "tex/latex/selinput/")
             (base32
              "0x8l98r6xzyi4lc909bv7ii2nbpff8j7j3q4z86l7rrjk1jkx9qi")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-kvoptions
           texlive-kvsetkeys
           texlive-stringenc))
    (home-page "https://ctan.org/pkg/selinput")
    (synopsis "Semi-automatic detection of input encoding")
    (description
     "This package selects the input encoding by specifying pairs of input
characters and their glyph names.")
    (license license:lppl1.3+)))

(define-public texlive-seminar
  (package
    (inherit (simple-texlive-package
              "texlive-seminar"
              (list "/doc/latex/seminar/"
                    "/tex/latex/seminar/")
              (base32
               "1clgw5xy867khzfn8d210rc5hsw5s7r0pznhk84niybvw4zc7r3f")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/seminar")
    (synopsis "Make overhead slides")
    ;; TODO: This package may need fancybox and xcomment at runtime.
    (description
     "This package provides a class that produces overhead
slides (transparencies), with many facilities.  Seminar is not nowadays
reckoned a good basis for a presentation — users are advised to use more
recent classes such as powerdot or beamer, both of which are tuned to
21st-century presentation styles.")
    (license license:lppl1.2+)))

(define-deprecated-package texlive-latex-seminar texlive-seminar)

(define-public texlive-seqsplit
  (package
    (name "texlive-seqsplit")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
              (list "doc/latex/seqsplit/"
                    "source/latex/seqsplit/"
                    "tex/latex/seqsplit/")
              (base32
               "0x6xcism9s9mhpr278xi4c1gimz3mlqnrpr40vkx5abglr0gzm0j")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/seqsplit")
    (synopsis "Split long sequences of characters in a neutral way")
    (description
     "@code{seqsplit} provides a command @code{\\seqsplit}, which makes its
argument splittable anywhere, and then leaves the TeX paragraph-maker to do the
splitting.  The package is suitable for situations when one needs to type long
sequences of letters or of numbers in which there is no obvious break points to
be found, such as in base-sequences in genes or calculations of transcendental
numbers.  While the package may obviously be used to typeset DNA sequences, the
user may consider the @code{dnaseq} as a rather more powerful alternative.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-seqsplit texlive-seqsplit)

(define-public texlive-showexpl
  (package
    (name "texlive-showexpl")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/showexpl/" "source/latex/showexpl/"
                   "tex/latex/showexpl/")
             (base32
              "0vff1yk7a3f4csxibfk6r37s3h6n4wdpnk3qj4dsx7kh5zrcysha")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-attachfile
           texlive-float
           texlive-graphics
           texlive-listings
           texlive-refcount
           texlive-varwidth))
    (home-page "https://ctan.org/pkg/showexpl")
    (synopsis "Typesetting LaTeX source code")
    (description
     "This package provides a way to typeset LaTeX source code and the related
result in the same document.")
    (license license:lppl1.2+)))

(define-public texlive-stackengine
  (package
    (name "texlive-stackengine")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/stackengine/"
                   "tex/latex/stackengine/")
             (base32
              "1rbw3dmb6kl3wlnpxacr8cmp2ivac1kpnb33k7r5s3lp1q59ck38")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-etoolbox
           texlive-listofitems))
    (home-page "https://ctan.org/pkg/stackengine")
    (synopsis "Customised stacking of objects")
    (description
     "The package provides a versatile way to stack objects vertically in a
variety of customizable ways.  A number of useful macros are provided, all
of which make use of the @code{stackengine} core.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-stackengine texlive-stackengine)

(define-public texlive-tocloft
  (package
    (name "texlive-tocloft")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/tocloft/"
                   "source/latex/tocloft/"
                   "tex/latex/tocloft/")
             (base32
              "1s09g02pq2zi5ywm3yhyp4lpzq77n9aahr6wnm1c0wb9zawq2mpk")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://www.ctan.org/pkg/tocloft")
    (synopsis "Control table of contents")
    (description
     "This package provides control over the typography of the @dfn{Table of
Contents}, @dfn{List of Figures} and @dfn{List of Tables}, and the ability to
create new @samp{List of ...}.  The ToC @code{\\parskip} may be changed.")
    (license license:lppl1.3c+)))

(define-deprecated-package texlive-latex-tocloft texlive-tocloft)

(define-public texlive-trimspaces
  (package
    (name "texlive-trimspaces")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/trimspaces/"
                   "source/latex/trimspaces/"
                   "tex/latex/trimspaces/")
             (base32
              "0if7pqaib533fbrj9r62mmr4h012hrpszdxs759rwhmyycikg6dk")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:tex-format "latex"
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'fix-bug
            (lambda _
              ;; The "ins" file refers to the wrong source file.
              (substitute* "source/latex/trimspaces/trimspaces.ins"
                (("pstool\\.tex") "trimspaces.tex")))))))
    (propagated-inputs
     (list texlive-filecontents))
    (home-page "https://ctan.org/pkg/trimspaces")
    (synopsis "Trim spaces around an argument or within a macro")
    (description
     "This package provides a very short package that allows you to expandably
remove spaces around a token list (commands are provided to remove spaces
before, spaces after, or both); or to remove surrounding spaces within a macro
definition, or to define space-stripped macros.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-trimspaces texlive-trimspaces)

(define-public texlive-currfile
  (package
    (name "texlive-currfile")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/currfile/" "source/latex/currfile/"
                   "tex/latex/currfile/")
             (base32
              "1l9win5msf80yzgzfx580d1hw8lza1advhqkhpz83i080020asji")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (native-inputs
     (list texlive-ydoc))
    (propagated-inputs
     (list texlive-filehook
           texlive-kvoptions))
    (home-page "https://ctan.org/pkg/currfile")
    (synopsis "Provide file name and path of input files")
    (description
     "The package provides macros holding file name information (directory,
base name, extension, full name and full path) for files read by LaTeX
@code{\\input} and @code{\\include} macros; it uses the file hooks provided by
the author's @code{filehook}.  In particular, it restores the parent file name
after the trailing @code{\\clearpage} of an @code{\\included} file; as
a result, the macros may be usefully employed in the page header and footer of
the last printed page of such a file.  The depth of inclusion is made
available, together with the parent (including file) and parents (all
including files to the root of the tree).  The package supersedes FiNK.")
    (license license:lppl1.3+)))

(define-public texlive-calrsfs
  (package
    (inherit
     (simple-texlive-package
      "texlive-calrsfs"
      (list "doc/latex/calrsfs/" "tex/latex/calrsfs/")
      (base32 "0aqa0k0zzzicx5nynd29i9pdb7a4j6fvf1xwrbm4qg64pl55i6xa")
      #:trivial? #t))
    (home-page "https://ctan.org/macros/latex/contrib/calrsfs")
    (synopsis "Copperplate calligraphic letters in LaTeX")
    (description "This package provides a math interface to the Rsfs fonts.")
    (license license:public-domain)))

(define-public texlive-capt-of
  (let ((template
         (simple-texlive-package
          "texlive-capt-of"
          (list "doc/latex/capt-of/"
                "source/latex/capt-of/"
                "tex/latex/capt-of/")
          (base32 "0bf0cdd9ca3kkqxqqkq6jalh5ybs60l80l5gfkl2whk2v4bnzfvz"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/capt-of")
         ((#:build-targets _ '())
          '(list "capt-of.ins"))))
      (home-page "https://www.ctan.org/pkg/capt-of")
      (synopsis "Captions on more than floats")
      (description
       "This package defines a command @code{\\captionof} for putting a caption
to something that's not a float.")
      (license license:lppl))))

(define-deprecated-package texlive-latex-capt-of texlive-capt-of)

(define-public texlive-carlisle
  (package
    (inherit (simple-texlive-package
              "texlive-carlisle"
              (list "doc/latex/carlisle/"
                    "source/latex/carlisle/"
                    "tex/latex/carlisle/")
              (base32 "139k4n8dv6pbal1mx4m8b239x3i9cw61f6digk9mxscbxwvxfngb")
              #:trivial? #t))
    (home-page "https://ctan.org/macros/latex/contrib/carlisle")
    (synopsis "David Carlisle's small packages")
    (description
     "Many of David Carlisle's more substantial packages stand on their own,
or as part of the LaTeX latex-tools set; this set contains: making dotless
@emph{j} characters for fonts that don't have them; a method for combining the
capabilities of longtable and tabularx; an environment for including plain TeX
in LaTeX documents; a jiffy to create slashed characters for physicists.")
    (license license:lppl)))

(define-public texlive-catchfile
  (let ((template (simple-texlive-package
                   "texlive-catchfile"
                   (list "/doc/latex/catchfile/"
                         "/source/latex/catchfile/"
                         "/tex/generic/catchfile/")
                   (base32
                    "1dpxy64hs0bjp8d2dmikflc995vazf7fi6z92w51fnj2fidgl8gx"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t)
          "latex/catchfile")))
      (home-page "https://ctan.org/macros/latex/contrib/catchfile")
      (synopsis "Catch an external file into a macro")
      (description
       "Catchfile catches the contents of a file and puts it in a macro.")
      (license license:lppl1.3+))))

(define-public texlive-ddphonism
  (package
    (inherit (simple-texlive-package
              "texlive-ddphonism"
              (list "doc/latex/ddphonism/"
                    "tex/latex/ddphonism/")
              (base32 "1p02ai76nnh6042pnmqv4n30z6yxsvyyk2nb9jk7xlyyc87zzbdd")
              #:trivial? #t))
    (propagated-inputs
     (list texlive-etoolbox
           texlive-hyperref
           texlive-l3packages
           texlive-listings
           texlive-pgf
           texlive-tools
           texlive-xstring))
    (home-page "https://www.ctan.org/pkg/ddphonism")
    (synopsis "Dodecaphonic diagrams for LaTeX")
    (description
     "This is a music-related package which is focused on notation from the
twelve-tone system, also called dodecaphonism.  It provides LaTeX algorithms
that produce typical dodecaphonic notation based off a musical series, or row
sequence, of variable length.")
    (license license:lppl1.3c)))

(define-public texlive-doi
  (package
    (inherit (simple-texlive-package
              "texlive-doi"
              (list "/doc/latex/doi/README.md"
                    "/tex/latex/doi/")
              (base32
               "18z9922lqb3hliqn95h883fndqs4lgyi5yqbnq2932ya0imc3j7h")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/doi")
    (synopsis "Create correct hyperlinks for DOI numbers")
    (description
     "You can hyperlink DOI numbers to doi.org.  However, some publishers have
elected to use nasty characters in their DOI numbering scheme (@code{<},
@code{>}, @code{_} and @code{;} have all been spotted).  This will either
upset LaTeX, or your PDF reader.  This package contains a single user-level
command @code{\\doi{}}, which takes a DOI number, and creates a correct
hyperlink to the target of the DOI.")
    ;; Any version of the LPPL.
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-doi texlive-doi)

(define-public texlive-etoolbox
  (package
    (inherit (simple-texlive-package
              "texlive-etoolbox"
              (list "/doc/latex/etoolbox/"
                    "/tex/latex/etoolbox/")
              (base32
               "070iaj540rglf0c80l0hjkwg6aa7qyskhh4iwyhf7n8vrg5cjjab")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/etoolbox")
    (synopsis "e-TeX tools for LaTeX")
    (description
     "This package is a toolbox of programming facilities geared primarily
towards LaTeX class and package authors.  It provides LaTeX frontends to some
of the new primitives provided by e-TeX as well as some generic tools which
are not strictly related to e-TeX but match the profile of this package.  The
package provides functions that seem to offer alternative ways of implementing
some LaTeX kernel commands; nevertheless, the package will not modify any part
of the LaTeX kernel.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-etoolbox texlive-etoolbox)

(define-public texlive-fncychap
  (package
    (name "texlive-fncychap")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/fncychap/"
                   "tex/latex/fncychap/")
             (base32
              "1javlws18ncrf7rz7qfbx1db9jwk45lm6sa0s67hlr6hqnyjxf94")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics))
    (home-page "https://ctan.org/pkg/fncychap")
    (synopsis "Seven predefined chapter heading styles")
    (description
     "This package provides seven predefined chapter heading styles.  Each
style can be modified using a set of simple commands.  Optionally one can
modify the formatting routines in order to create additional chapter
headings.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-fncychap texlive-fncychap)

(define-public texlive-framed
  (package
    (name "texlive-framed")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/framed/"
                   "tex/latex/framed/")
             (base32
              "09hlzjlhz3q3l62h6gj997pfx1hc4726frhcdc6y5g66c3gh621g")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/framed")
    (synopsis "Framed or shaded regions that can break across pages")
    (description
     "The package creates three environments: @code{framed}, which puts an
ordinary frame box around the region, @code{shaded}, which shades the region,
and @code{leftbar}, which places a line at the left side.  The environments
allow a break at their start (the @code{\\FrameCommand} enables creation of
a title that is “attached” to the environment); breaks are also allowed in the
course of the framed/shaded matter.  There is also a command
@code{\\MakeFramed} to make your own framed-style environments.")
    ;; The header states: "These macros may be freely transmitted, reproduced,
    ;; or modified for any purpose provided that this notice is left intact."
    (license (license:fsf-free "file://framed.sty"))))

(define-deprecated-package texlive-latex-framed texlive-framed)

(define-public texlive-g-brief
  (package
    (name "texlive-g-brief")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/g-brief/"
                   "source/latex/g-brief/"
                   "tex/latex/g-brief/")
             (base32
              "0sicgf3wjw5jymh5xjxby2hsilakhw2lqgywx0f2zax1z854xc2m")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-babel
           texlive-eurosym
           texlive-marvosym))
    (home-page "https://www.ctan.org/pkg/g-brief")
    (synopsis "Letter document class")
    (description
     "This package is designed for formatting formless letters in German; it
can also be used for English (by those who can read the documentation).  There
are LaTeX 2.09 @code{documentstyle} and LaTeX 2e class files for both an old
and a new version of @code{g-brief}.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-g-brief texlive-g-brief)

(define-public texlive-galois
  (package
    (name "texlive-galois")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/galois/"
                   "source/latex/galois/"
                   "tex/latex/galois/")
             (base32
              "1324nw1r1aj6khz6fvrhd1p1sinadrd83j0s2q2fhnsgwp6sw94f")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics))
    (home-page "https://www.ctan.org/pkg/galois")
    (synopsis "Typeset Galois connections")
    (description
     "The package deals with connections in two-dimensional style, optionally
in colour.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-galois texlive-galois)

(define-public texlive-gcite
  (package
    (name "texlive-gcite")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/gcite/"
                   "source/latex/gcite/"
                   "tex/latex/gcite/")
             (base32
              "0yb7sid13bx25yar3aw6pbf4jmmfi0gdmcd7ynf5hjh9qdfb3zyh")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-biblatex))
    (home-page "https://www.ctan.org/pkg/gcite")
    (synopsis "Citations in a reader-friendly style")
    (description
     "The package allows citations in the German style, which is considered by
many to be particularly reader-friendly.  The citation provides a small amount
of bibliographic information in a footnote on the page where each citation is
made.  It combines a desire to eliminate unnecessary page-turning with the
look-up efficiency afforded by numeric citations.  The package makes use of
BibLaTeX, and is considered experimental.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-gcite texlive-gcite)

(define-public texlive-geometry
  (package
    (name "texlive-geometry")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/geometry/"
                   "source/latex/geometry/"
                   "tex/latex/geometry/")
             (base32
              "09jwdrg4s1c0gqmx7s57byw5kc09cna3li85y9ix0vxa6f6iqzi1")))
    (build-system texlive-build-system)
    (outputs '("out" "doc"))
    (propagated-inputs
     (list texlive-atbegshi
           texlive-graphics             ;for keyval
           texlive-iftex))
    (home-page "https://www.ctan.org/pkg/geometry")
    (synopsis "Flexible and complete interface to document dimensions")
    (description
     "This package provides an easy and flexible user interface to customize
page layout, implementing auto-centering and auto-balancing mechanisms so that
the users have only to give the least description for the page layout.  The
package knows about all the standard paper sizes, so that the user need not
know what the nominal real dimensions of the paper are, just its standard
name (such as a4, letter, etc.).  An important feature is the package's
ability to communicate the paper size it's set up to the output.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-geometry texlive-geometry)

(define-public texlive-mdwtools
  (package
    (name "texlive-mdwtools")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/mdwtools/"
                   "source/latex/mdwtools/"
                   "tex/latex/mdwtools/")
             (base32
              "08wyw0k6r3fv7vdgwbcpq9ckifldy17fzhpar51s1qn0yib93zdg")))
    (build-system texlive-build-system)
    (outputs '("out" "doc"))
    (home-page "https://www.ctan.org/pkg/mdwtools")
    (synopsis "Miscellaneous tools by Mark Wooding")
    (description
     "This collection of tools includes: @code{atsupport} for short commands
starting with @code{@@}, macros to sanitize the OT1 encoding of the
@code{cmtt} fonts; a @code{doafter} command; improved @code{footnote} support;
@code{mathenv} for various alignment in maths; list handling; @code{mdwmath}
which adds some minor changes to LaTeX maths; a rewrite of LaTeX's
@code{tabular} and @code{array} environments; verbatim handling; and syntax
diagrams.")
    (license license:gpl3+)))

(define-deprecated-package texlive-latex-mdwtools texlive-mdwtools)

(define-public texlive-makecmds
  (package
    (inherit (simple-texlive-package
              "texlive-makecmds"
              (list "doc/latex/makecmds/README"
                    "source/latex/makecmds/makecmds.dtx"
                    "source/latex/makecmds/makecmds.ins")
              (base32 "0znx80x6ic7a25v9dw8yjibq7lx65wangcyii18kk5x5z4jljba9")))
    (outputs '("out" "doc"))
    (arguments
     (list
      #:tex-directory "latex/makecmds"))
    (native-inputs (list (texlive-updmap.cfg
                          (list texlive-amsfonts
                                texlive-cm))))
    (home-page "https://www.ctan.org/pkg/makecmds")
    (synopsis "TeX macro to define or redefine a command")
    (description "The package provides a @code{\\makecommand} command, which
is like @code{\\newcommand} or @code{\\renewcommand} except it
always (re)defines a command.  There is also @code{\\makeenvironment} and
@code{\\provideenvironment} for environments.")
    (license license:lppl1.3c+)))

(define-public texlive-marginfix
  (package
    (name "texlive-marginfix")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/marginfix/"
                   "source/latex/marginfix/"
                   "tex/latex/marginfix/")
             (base32
              "0y6lmxm5ws2g0rqisvgdc8kg3whnvabrkl662sb4jvvaz02y3qdi")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/marginfix")
    (synopsis "Patch @code{\\marginpar} to avoid overfull margins")
    (description
     "Authors using LaTeX to typeset books with significant margin material
often run into the problem of long notes running off the bottom of the page.
This package implements a solution to make @code{marginpars} just work by
keeping a list of floating inserts and arranging them intelligently in the
output routine.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-marginfix texlive-marginfix)

(define-public texlive-metalogo
  (package
    (inherit (simple-texlive-package
              "texlive-metalogo"
              (list "doc/latex/metalogo/README"
                    ;; These PDFs are apparently used as graphic files, not
                    ;; built.
                    "doc/latex/metalogo/TeXoutline.pdf"
                    "doc/latex/metalogo/eLaToutline.pdf"
                    "source/latex/metalogo/metalogo.dtx"
                    "source/latex/metalogo/metalogo.ins")
              (base32 "0v1jwp8xhzwn0a4apiyya17s4r1kpn6q9nmv38jj1wwdvgia0jpi")))
    (outputs '("out" "doc"))
    (arguments
     (list
      #:tex-directory "latex/metalogo"
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'patch-metalogo.dtx
            (lambda _
              (substitute* "source/latex/metalogo/metalogo.dtx"
                ;; Prevent embedding a build time date, for reproducibility.
                (("^% \\\\date.*") "")
                ;; These fonts are not free.
                (("^\\\\setmainfont.*") "")
                (("^\\\\DeclareSymbolFont\\{SabonMaths}.*") "")
                (("^\\\\AtBeginDocument\\{.*") "")
                ((".*\\\\expandafter.*\\\\symSabonMaths.*") "")
                (("^\\\\setsansfont.*MgOpen Cosmetica.*") "")
                (("^\\\\setmonofont.*Consolas.*") "")
                ;; The 'stix' texlive font package has been obsoleted by
                ;; stix2.
                (("^\\\\newfontfamily\\\\stixgeneral\\{STIXGeneral}")
                 "\\newfontfamily\\stixgeneral{STIX Two Text}")))))))
    (native-inputs (list fontconfig    ;for XDG_DATA_DIRS, to locate OTF fonts
                         texlive-booktabs
                         texlive-cm
                         texlive-eukdate
                         texlive-fontspec
                         texlive-iftex
                         texlive-latex-base
                         texlive-graphics
                         texlive-multirow
                         texlive-lm     ;for lmroman10-regular
                         texlive-stix2-otf))
    (propagated-inputs (list texlive-fontspec texlive-iftex
                             texlive-graphics))
    (home-page "https://ctan.org/pkg/metalogo")
    (synopsis "Extended TeX logo macros")
    (description "This package exposes spacing parameters for various TeX
logos to the end user, to optimise the logos for different fonts.  It is
written especially for XeLaTeX users.")
    (license license:lppl1.3c+)))

(define-public texlive-paralist
  (package
    (inherit (simple-texlive-package
              "texlive-paralist"
              (list "doc/latex/paralist/README"
                    "source/latex/paralist/paralist.dtx"
                    "source/latex/paralist/paralist.ins")
              (base32 "1lz8yds2i64wkb89a9amydwkzsdbc09s1kbgn7vgh2qsxqrrgwam")))
    (outputs '("out" "doc"))
    (arguments
     (list
      #:tex-directory "latex/paralist"))
    (native-inputs (list texlive-latex-base
                         (texlive-updmap.cfg
                          (list texlive-cm
                                texlive-jknappen))))
    (home-page "https://ctan.org/pkg/paralist")
    (synopsis "Enumerate and itemize within paragraphs")
    (description "The @code{paralist} package provides enumerate and itemize
environments that can be used within paragraphs to format the items either as
running text or as separate paragraphs with a preceding number or symbol.  It
also provides compacted versions of enumerate and itemize.")
    (license license:lppl1.0+)))

(define-public texlive-polyglossia
  (package
    (inherit (simple-texlive-package
              "texlive-polyglossia"
              (list "source/latex/polyglossia/"
                    ;; These files are not part of polyglossia.dtx
                    "tex/latex/polyglossia/arabicnumbers.sty"
                    "tex/latex/polyglossia/xpg-cyrillicnumbers.sty")
              (base32 "1p0hhclypv2zbs8h64c6sd689m9ym3vvpn966qpwpjxbymsrc49g")))
    (outputs '("out" "doc"))
    (arguments
     (list
      #:tex-directory "latex/polyglossia"
      #:tex-format "xelatex"
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'build-and-install-xelatex.fmt
            (lambda* (#:key tex-format #:allow-other-keys)
              (invoke "fmtutil-sys" "--byfmt" tex-format "--fmtdir=web2c")
              ;; Extend the current TEXMF environment variable to make
              ;; available the newly built formats.
              (setenv "GUIX_TEXMF" (string-append (getcwd) ":"
                                                  (getenv "GUIX_TEXMF")))
              ;; XXX: Extend the base (more limited) xelatex.fmt provided by
              ;; texlive-latex-base, otherwise packages using Polyglossia
              ;; would encounter the same lack of hyphenation support problem.
              (install-file "web2c/xetex/xelatex.fmt"
                            (string-append #$output
                                           "/share/texmf-dist/web2c/xetex"))))
          (add-before 'build 'chdir
            (lambda _
              ;; This is so the build can find the files not part of the .dtx.
              (setenv "TEXINPUTS" (string-append (getcwd)
                                                 "/tex/latex/polyglossia:"))))
          (add-after 'chdir 'substitute-nonfree-fonts
            (lambda _
              (substitute* "polyglossia.dtx"
                (("\\{Serto Jerusalem}")
                 "{FreeSans}"))))
          (add-after 'substitute-nonfree-fonts 'extract-dtx
            (lambda* (#:key tex-format #:allow-other-keys)
              (invoke tex-format "polyglossia.dtx"))))))
    (native-inputs (list fontconfig     ;for XDG_DATA_DIRS (to locate fonts)
                         font-amiri
                         font-dejavu
                         font-gfs-ambrosia
                         font-gnu-freefont
                         font-linuxlibertine
                         font-sil-ezra
                         texlive-latex-base
                         texlive-babel
                         texlive-bin    ;for fmtutil.cnf
                         texlive-bidi
                         texlive-booktabs
                         texlive-caption
                         texlive-context
                         texlive-fancyvrb
                         texlive-etoolbox
                         texlive-latex-fonts
                         texlive-fontspec
                         texlive-hyperref
                         ;; TODO: Remove texlive-stringenc and
                         ;; texlive-zapfding after texlive-hyperref propagates
                         ;; them.
                         texlive-stringenc
                         texlive-zapfding
                         texlive-graphics
                         texlive-kpathsea ;for cp227.tcx & friends
                         texlive-makecmds
                         texlive-metalogo
                         texlive-microtype
                         texlive-paralist
                         texlive-tools
                         texlive-tex-ini-files)) ;for pdftexconfig
    ;; polyglossia.sty \RequirePackage or \\usepackage these other TexLive
    ;; packages.
    (propagated-inputs
     (list texlive-bidi
           texlive-etoolbox
           texlive-fontspec
           texlive-hyperref
           ;; TODO: Remove texlive-stringenc and
           ;; texlive-zapfding after texlive-hyperref propagates
           ;; them.
           texlive-stringenc
           texlive-zapfding
           texlive-makecmds
           texlive-l3packages           ;expl3, l3keys2e, xparse
           texlive-tools
           texlive-xkeyval))
    (home-page "https://www.ctan.org/pkg/polyglossia")
    (synopsis "Alternative to Babel for XeLaTeX and LuaLaTeX")
    (description "This package provides a complete Babel replacement for users
of LuaLaTeX and XeLaTeX.  It includes support for over 70 different languages,
some of which in different regional or national varieties, or using a
different writing system.  It enables:
@itemize
@item
Loading the appropriate hyphenation patterns.
@item
Setting the script and language tags of the current font (if possible and
available), using the package fontspec.
@item
Switching to a font assigned by the user to a particular script or language.
@item
Adjusting some typographical conventions in function of the current language
(such as afterindent, frenchindent, spaces before or after punctuation marks,
etc.)
@item
Redefining the document strings (like @samp{chapter}, @samp{figure},
@samp{bibliography}).  Adapting the formatting of dates (for non-gregorian
calendars via external packages bundled with polyglossia: currently the
Hebrew, Islamic and Farsi calendars are supported).
@item
For languages that have their own numeration system, modifying the formatting
of numbers appropriately.
@item
Ensuring the proper directionality if the document contains languages
written from right to left (via the packages bidi and luabidi, available
separately).
@end itemize")
    (license license:expat)))

(define-deprecated-package texlive-latex-polyglossia texlive-polyglossia)

(define-public texlive-supertabular
  (package
    (name "texlive-supertabular")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/supertabular/"
                   "source/latex/supertabular/"
                   "tex/latex/supertabular/")
             (base32
              "1z4kyx20w2zvn6c5a7p702pxj254f2pwlk7x815gzlcc6563js6a")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://www.ctan.org/pkg/supertabular")
    (synopsis "Multi-page tables package")
    (description
     "This package was a predecessor of @code{longtable}; the newer
package (designed on quite different principles) is easier to use and more
flexible, in many cases, but @code{supertabular} retains its usefulness in
a few situations where longtable has problems.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-supertabular texlive-supertabular)

(define-public texlive-texinfo
  (package
    (name "texlive-texinfo")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "tex/texinfo/")
             (base32
              "0wbbhjr1jqiicnssiy6n5s4v5p6axhlilpkfhix4kavbj8mb6mfn")))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/texinfo")
    (synopsis "Texinfo documentation system")
    (description
     "Texinfo is the preferred format for documentation in the GNU project;
the format may be used to produce online or printed output from a single
source.  The Texinfo macros may be used to produce printable output using TeX;
other programs in the distribution offer online interactive use (with
hypertext linkages in some cases).")
    (license license:gpl3+)))

(define-deprecated-package texlive-tex-texinfo texlive-texinfo)

(define-public texlive-textcase
  (package
    (inherit (simple-texlive-package
              "texlive-textcase"
              (list "doc/latex/textcase/"
                    "tex/latex/textcase/"
                    "source/latex/textcase/")
              (base32
               "185fibd41wd0v51gnai29ygi32snkk00p00110kcnk1bcnmpiw82")
              #:trivial? #t))
    (home-page "https://ctan.org/macros/latex/contrib/textcase")
    (synopsis "Case conversion ignoring mathematics, etc")
    (description
     "The textcase package offers commands @code{\\MakeTextUppercase} and
@code{\\MakeTextLowercase} are similar to the standard @code{\\MakeUppercase}
and @code{\\MakeLowercase}, but they do not change the case of any sections of
mathematics, or the arguments of @code{\\cite}, @code{\\label} and
@code{\\ref} commands within the argument.  A further command
@code{\\NoCaseChange} does nothing but suppress case change within its
argument, so to force uppercase of a section including an environment, one
might say:

@example
\\MakeTextUppercase{...\\NoCaseChange{\\begin{foo}} ...\\NoCaseChange{\\end{foo}}...}
@end example\n")
    (license license:lppl)))

(define-public texlive-upquote
  (package
    (name "texlive-upquote")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/upquote/"
                   "source/latex/upquote/"
                   "tex/latex/upquote/")
             (base32
              "1manbljqx2859wq9by6bpcx4rnxvc596a05d21cw464484f8a8z2")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://www.ctan.org/pkg/upquote")
    (synopsis "Show realistic quotes in verbatim")
    (description
     "Typewriter-style fonts are best for program listings, but Computer
Modern Typewriter prints @samp{`} and @samp{'} as bent opening and closing
single quotes.  Other fonts, and most programming languages, print @samp{`} as
a grave accent and @samp{'} upright; @samp{'} is used both to open and to
close quoted strings.  The package switches the typewriter font to Computer
Modern Typewriter in OT1 encoding, and modifies the behaviour of
@code{verbatim}, @code{verbatim*}, @code{\\verb}, and @code{\\verb*} to print
in the expected way.  It does this regardless of other fonts or encodings in
use, so long as the package is loaded after the other fonts were.  The package
does not affect @code{\\tt}, @code{\\texttt}, etc.")
    (license license:lppl1.2+)))

(define-deprecated-package texlive-latex-upquote texlive-upquote)

(define-public texlive-anysize
  (package
    (name "texlive-anysize")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/anysize/"
                   "tex/latex/anysize/")
             (base32
              "155s0v82zpkmv97kwqhhfw52230hka9zl3wzjw1d5ayxd4n11bxq")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/anysize")
    (synopsis "Simple package to set up document margins")
    (description
     "This is a simple package to set up document margins.  This package is
considered obsolete; alternatives are the @code{typearea} package from the
@code{koma-script} bundle, or the @code{geometry} package.")
    (license license:public-domain)))

(define-deprecated-package texlive-latex-anysize texlive-anysize)

(define-public texlive-appendix
  (package
    (name "texlive-appendix")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/appendix/"
                   "source/latex/appendix/"
                   "tex/latex/appendix/")
             (base32
              "1vqkqpzs7bc6pbjnafakrwayjyfx9mvadrqxccdf549m8172qvzk")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/appendix")
    (synopsis "Extra control of appendices")
    (description
     "The @code{appendix} package provides various ways of formatting the
titles of appendices.  Also (sub)appendices environments are provided that can
be used, for example, for per chapter/section appendices.  An
@code{appendices} environment is provided which can be used instead of the
@code{\\appendix} command.")
    (license license:lppl1.3c)))

(define-deprecated-package texlive-latex-appendix texlive-appendix)

(define-public texlive-bookmark
  (package
    (name "texlive-bookmark")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/bookmark/"
                   "source/latex/bookmark/"
                   "tex/latex/bookmark/")
             (base32
              "111sjwabcbr8ry8fh94ywpzska032y8r4iz4waxa4kf5l3k0p4bs")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list #:build-targets #~(list "bookmark.dtx")))
    (propagated-inputs
     (list texlive-atenddvi
           texlive-atveryend
           texlive-auxhook
           texlive-hyperref))
    (home-page "https://www.ctan.org/pkg/bookmark")
    (synopsis "Bookmark (outline) organization for @code{hyperref}")
    (description
     "This package implements a new bookmark (outline) organization for the
@code{hyperref} package.  Bookmark properties such as style and color.  Other
action types are available (URI, GoToR, Named).")
    (license license:lppl1.3c+)))

(define-deprecated-package texlive-latex-bookmark texlive-bookmark)

(define-public texlive-changebar
  (package
    (name "texlive-changebar")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/changebar/"
                   "source/latex/changebar/"
                   "tex/latex/changebar/")
             (base32
              "0y32inrdpki6v3dwyymfglf78wbfd29b6xa8vjn337dr4gxlma85")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://www.ctan.org/pkg/changebar")
    (synopsis "Generate changebars in LaTeX documents")
    (description
     "Identify areas of text to be marked with changebars with the
@code{\\cbstart} and @code{\\cbend} commands; the bars may be coloured.  The
package uses drivers to place the bars; the available drivers can work with
@code{dvitoln03}, @code{dvitops}, @code{dvips}, the emTeX and TeXtures DVI
drivers, and VTeX and pdfTeX.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-changebar texlive-changebar)

(define-public texlive-cmap
  (package
    (name "texlive-cmap")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/cmap/"
                   "tex/latex/cmap/")
             (base32
              "1hag26l3g9mpmmy1kn7lrnfzzr8k0hpm259qp087smggykvsjc4v")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/cmap")
    (synopsis "Make PDF files searchable and copyable")
    (description
     "This package embeds CMap tables into PDF files to make search and
copy-and-paste functions work properly.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-cmap texlive-cmap)

(define-public texlive-colortbl
  (package
    (name "texlive-colortbl")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/colortbl/"
                   "source/latex/colortbl/"
                   "tex/latex/colortbl/")
             (base32
              "0fb4a5l3yqk6l5gr0hlkqwpy004wi8zymyicdzjyhqwcib4jnzjs")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics
           texlive-tools))
    (home-page "https://ctan.org/pkg/colortbl")
    (synopsis "Add colour to LaTeX tables")
    (description
     "The package allows rows and columns to be coloured, and even
individual cells.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-colortbl texlive-colortbl)

(define-public texlive-fancybox
  (package
    (name "texlive-fancybox")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/fancybox/"
                   "tex/latex/fancybox/")
             (base32
              "0pb1j0a1va8yhrzig7dwrd8jgq39mbcpygl810jhrv8pl473mfmn")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/fancybox")
    (synopsis "Variants of @code{\\fbox} and other games with boxes")
    (description
     "This package provides variants of @code{\\fbox}: @code{\\shadowbox},
@code{\\doublebox}, @code{\\ovalbox}, @code{\\Ovalbox}, with helpful tools for
using box macros and flexible verbatim macros.  You can box mathematics,
floats, center, flushleft, and flushright, lists, and pages.")
    (license license:lppl1.2+)))

(define-deprecated-package texlive-latex-fancybox texlive-fancybox)

(define-public texlive-fancyhdr
  (let ((template (simple-texlive-package
                   "texlive-fancyhdr"
                   (list "doc/latex/fancyhdr/"
                         "source/latex/fancyhdr/"
                         "tex/latex/fancyhdr/")
                   (base32
                    "15fainwxs22gg4xhwsv1vmjgdhg34dbkir26nnk4pb6jprpwb83f"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/fancyhdr")
         ((#:build-targets _ '())
          #~(list "fancyhdr.ins"))))
      (home-page "https://www.ctan.org/pkg/fancyhdr")
      (synopsis "Extensive control of page headers and footers in LaTeX2e")
      (description
       "This package provides extensive facilities, both for constructing
headers and footers, and for controlling their use (for example, at times when
LaTeX would automatically change the heading style in use).")
      (license license:lppl))))

(define-deprecated-package texlive-latex-fancyhdr texlive-fancyhdr)

(define-public texlive-float
  (package
    (name "texlive-float")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/float/"
                   "source/latex/float/"
                   "tex/latex/float/")
             (base32
              "1rfyvk1n83zsmrrp0x643052nrjb00cj935d2cpm37x4pz649f5d")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/float")
    (synopsis "Improved interface for floating objects")
    (description
     "The @code{float} package improves the interface for defining floating
objects such as figures and tables.  It introduces the boxed float, the ruled
float and the plaintop float.  You can define your own floats and improve the
behaviour of the old ones.  The package also provides the @samp{H} float
modifier option of the obsolete @code{here} package.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-float texlive-float)

(define-public texlive-footmisc
  (package
    (name "texlive-footmisc")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/footmisc/"
                   "source/latex/footmisc/"
                   "tex/latex/footmisc/")
             (base32
              "1v1hkf0xcq6hyz3b32z3hvs53lmwrnkn79y9wxq6pqmhcgilqji3")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/footmisc")
    (synopsis "Range of footnote options")
    (description
     "This is a collection of ways to change the typesetting of footnotes.
The package provides means of changing the layout of the footnotes themselves,
a way to number footnotes per page, to make footnotes disappear in a
\"moving\" argument, and to deal with multiple references to footnotes from
the same place.  The package also has a range of techniques for labelling
footnotes with symbols rather than numbers.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-footmisc texlive-footmisc)

(define-public texlive-letltxmacro
  (let ((template (simple-texlive-package
                   "texlive-letltxmacro"
                   (list "doc/latex/letltxmacro/"
                         "source/latex/letltxmacro/"
                         "tex/latex/letltxmacro/")
                   (base32
                    "16bmwsng9p80jf78sdmib24apwnw3raw306cs1ms50z5s9dsfdby"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/letltxmacro")
         ((#:build-targets _ '())
          #~(list "letltxmacro.dtx"))))
      (home-page "https://www.ctan.org/pkg/letltxmacro")
      (synopsis "Let assignment for macros")
      (description
       "TeX’s @code{\\let} assignment does not work for LaTeX macros with
optional arguments, or for macros that are defined as robust macros by
@code{\\DeclareRobustCommand}.  This package defines @code{\\LetLtxMacro}
that also takes care of the involved internal macros.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-latex-letltxmacro texlive-letltxmacro)

(define-public texlive-frankenstein
  (package
    (name "texlive-frankenstein")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "bibtex/bib/frankenstein/"
                   "bibtex/bst/frankenstein/"
                   "doc/latex/frankenstein/"
                   "source/latex/frankenstein/"
                   "tex/latex/frankenstein/")
             (base32
              "1x494vl4acl0bhfshs96ap8j47xk4m4njfincfhg2b0mi7l5mj1i")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:modules '((guix build texlive-build-system)
                  (guix build utils)
                  (ice-9 match))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'set-TEXINPUTS
            ;; The ".ins" files strip comments from ".sty", turning them into
            ;; faster ".stq" (and ".bsq") files.  Unfortunately, the ".ins"
            ;; and the ".sty" files are not located in the same
            ;; directory. This phase extends TEXINPUTS so everyone can see
            ;; each other, including the docstrip utility.
            (lambda* (#:key inputs #:allow-other-keys)
              (setenv "TEXINPUTS"
                      (let ((cwd (getcwd)))
                        (string-append
                         cwd "/tex/latex/frankenstein//:"
                         cwd "/source/latex/frankenstein//:"
                         (string-join
                          (map (match-lambda ((_ . dir) dir)) inputs)
                          "//:"))))))
          (add-before 'install 'install-faster-files
            (lambda _
              ;; Replace ".sty" and ".bst" files with their faster
              ;; counterpart.
              (copy-file "build/achicago.bsq"
                         "bibtex/bst/frankenstein/achicago.bst")
              ;; "build/tex/.../xxx.stq" -> "tex/.../xxx.sty"
              (for-each (lambda (file)
                          (copy-file file
                                     (string-append "tex/latex/frankenstein/"
                                                    (basename file ".stq")
                                                    ".sty")))
                        (find-files "build/tex" "\\.stq$")))))))
    (propagated-inputs
     (list texlive-relsize texlive-tools texlive-url))
    (home-page "https://ctan.org/pkg/frankenstein")
    (synopsis "Collection of LaTeX packages")
    (description
     "Frankenstein is a bundle of LaTeX packages serving various purposes
and a BibTeX bibliography style.  The individual packages are: @code{abbrevs},
@code{achicago}, @code{achicago} bibstyle, @code{attrib}, @code{blkcntrl},
@code{compsci}, @code{dialogue}, @code{lips}, @code{moredefs},
@code{newclude}, @code{slemph} and @code{titles}.")
    ;; README mentions an unspecified version of GNU GPL and points to
    ;; COPYING, which is missing. However, the individual files mention LPPL
    ;; 1.2 or later.
    (license license:lppl1.2+)))

(define-deprecated-package texlive-latex-frankenstein texlive-frankenstein)

(define-public texlive-kantlipsum
  (package
    (name "texlive-kantlipsum")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/kantlipsum/"
                   "source/latex/kantlipsum/"
                   "tex/latex/kantlipsum/")
             (base32
              "1bz08i8b7ihzd2qi4v9r9kjl2kr5a3l516lqb36spxyyrlmmwv4p")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-l3kernel
           texlive-l3packages))
    (home-page "https://ctan.org/pkg/kantlipsum")
    (synopsis "Generate sentences in Kant's style")
    (description
     "The package spits out sentences in Kantian style; the text is provided
by the Kant generator for Python by Mark Pilgrim, described in the book ``Dive
into Python''.  The package is modelled on @code{lipsum}, and may be used for
similar purposes.")
    (license license:lppl1.3c)))

(define-public texlive-lipsum
  (package
    (name "texlive-lipsum")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/lipsum/" "source/latex/lipsum/"
                   "tex/latex/lipsum/")
             (base32
              "1iwk2iqq5s5sn2z2kr7m59fm5j14dr4nsxivia3lhph8q38p5q6q")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-l3kernel
           texlive-l3packages))
    (home-page "https://ctan.org/pkg/lipsum")
    (synopsis "Easy access to the Lorem Ipsum dummy text")
    (description
     "This package gives you easy access to the Lorem Ipsum dummy text; an
option is available to separate the paragraphs of the dummy text into
TeX-paragraphs.  All the paragraphs are taken with permission from
@url{http://lipsum.com/}.")
    (license license:lppl1.3+)))

(define-public texlive-listings
  (let ((template
         (simple-texlive-package
          "texlive-listings"
          (list "doc/latex/listings/"
                "source/latex/listings/"
                "tex/latex/listings/")
          (base32 "15dnm0j86305x84ss3ymhhcczcw45b2liq01vrab6fj204wzsahk"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/listings")
         ((#:build-targets _ '())
          #~(list "listings.ins"))))
      (home-page "https://www.ctan.org/pkg/listings")
      (synopsis "Typeset source code listings using LaTeX")
      (description
       "The package enables the user to typeset programs (programming code)
within LaTeX; the source code is read directly by TeX---no front-end processor
is needed.  Keywords, comments and strings can be typeset using different
styles.  Support for @code{hyperref} is provided.")
      (license license:lppl1.3+))))

(define-public texlive-listingsutf8
  (package
    (name "texlive-listingsutf8")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/listingsutf8/"
                   "source/latex/listingsutf8/"
                   "tex/latex/listingsutf8/")
             (base32
              "152gzkzm7sl3bvggmmfcj1pw74vc40s2kpkbp01fd9i0d0v60wma")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-listings
           texlive-pdftexcmds
           texlive-stringenc))
    (home-page "https://ctan.org/pkg/listingsutf8")
    (synopsis "Allow UTF-8 in listings input")
    (description
     "Package @code{listings} does not support files with multi-byte encodings
such as UTF-8.  In the case of @code{\\lstinputlisting}, a simple workaround
is possible if a one-byte encoding exists that the file can be converted to.
The package requires the e-TeX extensions under pdfTeX (in either PDF or DVI
output mode).")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-listings texlive-listings)

(define-public texlive-jknapltx
  (package
    (name "texlive-jknapltx")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/jknapltx/"
                   "tex/latex/jknapltx/")
             (base32
              "0as43yqq123cacxhvp4sbdp4ka3cyp2spmxwayqny0fh5rsk6qaq")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics))
    (home-page "https://ctan.org/pkg/jknapltx")
    (synopsis "Miscellaneous packages by Joerg Knappen")
    (description
     "This package provides miscellaneous macros by Joerg Knappen,
including: represent counters in greek; Maxwell's non-commutative division;
@code{latin1jk}, @code{latin2jk} and @code{latin3jk}, which are
@code{inputenc} definition files that allow verbatim input in the respective
ISO Latin codes; blackboard bold fonts in maths; use of RSFS fonts in maths;
extra alignments for @code{\\parboxes}; swap Roman and Sans fonts;
transliterate semitic languages; patches to make (La)TeX formulae embeddable
in SGML; use maths minus in text as appropriate; simple Young tableaux.")
    (license license:gpl3+)))

(define-deprecated-package texlive-latex-jknapltx texlive-jknapltx)

(define-public texlive-kvoptions
  (let ((template (simple-texlive-package
                   "texlive-kvoptions"
                   (list "doc/latex/kvoptions/"
                         "source/latex/kvoptions/"
                         "tex/latex/kvoptions/")
                   (base32
                    "1b8q93l54160b8gn3fq484n15n6cylrhmf2xk7p42czg2rqw7w3l"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/kvoptions")
         ((#:build-targets _ '())
          #~(list "kvoptions.dtx"))))
      (propagated-inputs
       (list texlive-kvsetkeys texlive-ltxcmds))
      (home-page "https://www.ctan.org/pkg/kvoptions")
      (synopsis "Key/value format for package options")
      (description
       "This package provides facilities for using key-value format in
package options.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-latex-kvoptions texlive-kvoptions)

(define-public texlive-ec
  (package
    (name "texlive-ec")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/ec/"
                   "fonts/source/jknappen/ec/"
                   "fonts/tfm/jknappen/ec/")
             (base32
              "1cyi0vv9dnp45s0ilsrbkyznj9ji62s5bhkqgh49461mv2f8qj6p")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:modules
      '((guix build texlive-build-system)
        (guix build utils)
        (srfi srfi-1)
        (srfi srfi-26))
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'install 're-generate-fonts-metrics
            (lambda _
              (let ((mf #$(this-package-native-input "texlive-metafont"))
                    (cm #$(this-package-native-input "texlive-cm"))
                    (root (getcwd)))
                (mkdir-p "build")
                (with-directory-excursion "fonts/source/jknappen/ec"
                  ;; Tell mf where to find mf.base.
                  (setenv "MFBASES"
                          (string-append mf "/share/texmf-dist/web2c"))
                  ;; Tell mf where to look for source files.
                  (setenv "MFINPUTS"
                          (string-append
                           (getcwd) ":"
                           mf "/share/texmf-dist/metafont/base:"
                           cm "/share/texmf-dist/fonts/source/public/cm"))
                  ;; Build font metrics (tfm).
                  (for-each (lambda (font)
                              (format #t "building font ~a\n" font)
                              (invoke "mf" "-progname=mf"
                                      (string-append "-output-directory="
                                                     root "/build")
                                      (string-append "\\"
                                                     "mode:=ljfour; "
                                                     "mag:=1; "
                                                     "batchmode; "
                                                     "input "
                                                     (basename font ".mf"))))
                            (find-files "." "[0-9]+\\.mf$")))
                ;; Install font metrics at the appropriate location.
                (for-each
                 (cut install-file <> "fonts/tfm/jknappen/ec")
                 (find-files "build/" "\\.tfm$"))))))))
    (native-inputs
     (list texlive-bin texlive-cm texlive-metafont))
    (home-page "https://ctan.org/pkg/ec")
    (synopsis "Computer modern fonts in T1 and TS1 encodings")
    (description
     "The EC fonts are European Computer Modern Fonts, supporting the complete
LaTeX T1 encoding defined at the 1990 TUG conference hold at Cork/Ireland.
These fonts are intended to be stable with no changes being made to the tfm
files.  The set also contains a Text Companion Symbol font, called @code{tc},
featuring many useful characters needed in text typesetting, for example
oldstyle digits, currency symbols (including the newly created Euro symbol),
the permille sign, copyright, trade mark and servicemark as well as a copyleft
sign, and many others.  The fonts are available in (traced) Adobe Type
1 format, as part of the @code{cm-super} bundle.  The other Computer
Modern-style T1-encoded Type 1 set, Latin Modern, is not actually a direct
development of the EC set, and differs from the EC in a number of
particulars.")
    (license (license:fsf-free "https://www.tug.org/svn/texlive/tags/\
texlive-2019.3/Master/texmf-dist/doc/fonts/ec/copyrite.txt"))))

(define-deprecated-package texlive-fonts-ec texlive-ec)

;; FIXME: the fonts should be built from source, but running "tex aefonts.tex"
;; fails with obscure TeX-typical error messages.
(define-public texlive-ae
  (package
    (inherit (simple-texlive-package
              "texlive-ae"
              (list "/doc/fonts/ae/"
                    "/source/fonts/ae/"
                    "/fonts/tfm/public/ae/"
                    "/fonts/vf/public/ae/"
                    "/tex/latex/ae/")
              (base32
               "1xkzg381y0avdq381r2m990wp27czkdff0qkvsp2n5q62yc0bdsw")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/ae")
    (synopsis "Virtual fonts for T1 encoded CMR-fonts")
    (description
     "This package provides a set of virtual fonts which emulates T1 coded
fonts using the standard CM fonts.  The package name, AE fonts, supposedly
stands for \"Almost European\".  The main use of the package was to produce
PDF files using Adobe Type 1 versions of the CM fonts instead of bitmapped EC
fonts.  Note that direct substitutes for the bitmapped EC fonts are available,
via the CM-super, Latin Modern and (in a restricted way) CM-LGC font sets.")
    (license license:lppl1.3+)))

(define-public texlive-incgraph
  (package
    (name "texlive-incgraph")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/incgraph/" "tex/latex/incgraph/")
             (base32
              "1j5pzhzfbgzd21bq3dh7932pv0052g5l8r0qyx68n3cbsg46lcdk")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-bookmark
           texlive-graphics
           texlive-pgf))
    (home-page "https://ctan.org/pkg/incgraph")
    (synopsis "Sophisticated graphics inclusion in a PDF document")
    (description
     "The package provides tools for including graphics at the full size of
the output medium, or for creating pages whose size is that of the graphic
they contain.  A principal use case is documents that require inclusion
of (potentially many) scans or photographs.  Bookmarking is especially
supported.  The tool box has basic macros and a convenience user interface
that wraps @code{\\includegraphics}.")
    (license license:lppl1.3+)))

(define-public texlive-inconsolata
  (package
    (inherit (simple-texlive-package
              "texlive-inconsolata"
              (list "/doc/fonts/inconsolata/"
                    "/fonts/enc/dvips/inconsolata/"
                    "/fonts/map/dvips/inconsolata/"
                    "/fonts/opentype/public/inconsolata/"
                    "/fonts/tfm/public/inconsolata/"
                    "/fonts/type1/public/inconsolata/"
                    "/tex/latex/inconsolata/")
              (base32
               "19lvma52vk7x8d7j4s9ymjwm3w2k08860fh6dkzn76scgpdm4wlb")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/inconsolata")
    (synopsis "Monospaced font with support files for use with TeX")
    (description
     "Inconsolata is a monospaced font designed by Raph Levien.  This package
contains the font (in both Adobe Type 1 and OpenType formats) in regular and
bold weights, with additional glyphs and options to control slashed zero,
upright quotes and a shapelier lower-case L, plus metric files for use with
TeX, and LaTeX font definition and other relevant files.")
    (license (list license:lppl1.3+
                   license:silofl1.1
                   license:asl2.0))))

(define-public texlive-times
  (package
    (inherit (simple-texlive-package
              "texlive-times"
              (list "/dvips/times/"
                    "/fonts/afm/adobe/times/"
                    "/fonts/afm/urw/times/"
                    "/fonts/tfm/adobe/times/"
                    "/fonts/tfm/urw35vf/times/"
                    "/fonts/type1/urw/times/"
                    "/fonts/vf/adobe/times/"
                    "/fonts/vf/urw35vf/times/"
                    "/fonts/map/dvips/times/"
                    "/tex/latex/times/")
              (base32
               "13g41a7vbkvsf7ki9dgl7qm100w382mnlqkcngwgl3axp6s5s8l0")
              #:trivial? #t))
    (home-page "https://ctan.org/pkg/urw-base35")
    (synopsis "URW Base 35 font pack for LaTeX")
    (description
     "This package provides a drop-in replacements for the Times font from
Adobe's basic set.")
    ;; No license version specified.
    (license license:gpl3+)))

(define-deprecated-package texlive-fonts-adobe-times texlive-times)

(define-public texlive-palatino
  (package
    (inherit (simple-texlive-package
              "texlive-palatino"
              (list "/dvips/palatino/"
                    "/fonts/afm/adobe/palatino/"
                    "/fonts/afm/urw/palatino/"
                    "/fonts/tfm/adobe/palatino/"
                    "/fonts/tfm/urw35vf/palatino/"
                    "/fonts/type1/urw/palatino/"
                    "/fonts/vf/adobe/palatino/"
                    "/fonts/vf/urw35vf/palatino/"

                    "/fonts/map/dvips/palatino/"
                    "/tex/latex/palatino/")
              (base32
               "12jc0av7v99857jigmva47qaxyllhpzsnqis10n0qya2kz44xf22")
              #:trivial? #t))
    (home-page "https://ctan.org/pkg/urw-base35")
    (synopsis "URW Base 35 font pack for LaTeX")
    (description
     "This package provides a drop-in replacements for the Palatino font from
Adobe's basic set.")
    ;; No license version specified.
    (license license:gpl3+)))

(define-deprecated-package texlive-fonts-adobe-palatino texlive-palatino)

(define-public texlive-zapfding
  (package
    (inherit (simple-texlive-package
              "texlive-zapfding"
              (list "/dvips/zapfding/"
                    "/fonts/afm/adobe/zapfding/"
                    "/fonts/afm/urw/zapfding/"
                    "/fonts/tfm/adobe/zapfding/"
                    "/fonts/tfm/urw35vf/zapfding/"
                    "/fonts/type1/urw/zapfding/"
                    "/fonts/map/dvips/zapfding/"
                    "/tex/latex/zapfding/")
              (base32
               "17mls8wilz9api9ivsbcczpiqp1f39qy8wa6ajssi8zhnc5lq7zn")
              #:trivial? #t))
    (home-page "https://ctan.org/pkg/urw-base35")
    (synopsis "URW Base 35 font pack for LaTeX")
    (description
     "This package provides a drop-in replacements for the Zapfding font from
Adobe's basic set.")
    ;; No license version specified.
    (license license:gpl3+)))

(define-public texlive-zhspacing
  (package
    (inherit
     (simple-texlive-package "texlive-zhspacing"
                             (list "doc/generic/zhspacing/"
                                   "tex/context/third/zhspacing/"
                                   "tex/generic/zhspacing/"
                                   "tex/xelatex/zhspacing/")
                             (base32
                              "02hwa7yjwb6wxkkib83mjdbara5zcsixbp5xlawri8n9ah54vxjm")
                             #:trivial? #t))
    (home-page "https://ctan.org/macros/xetex/generic/zhspacing")
    (synopsis "Spacing for mixed CJK-English documents in XeTeX")
    (description
     "The package manages spacing in a CJK document; between consecutive Chinese
letters, spaces are ignored, but a consistent space is inserted between Chinese
text and English (or mathematics).  The package may be used by any document
format under XeTeX.")
    (license license:lppl1.3+)))

(define-public texlive-zref
  (package
    (name "texlive-zref")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/zref/" "source/latex/zref/"
                   "tex/latex/zref/")
             (base32
              "1lc83d4qyqljfnf2m3jhq36f3f1yjbi71ys1hc11b9x2a46xk4pf")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-atbegshi
           texlive-atveryend
           texlive-gettitlestring
           texlive-iftex
           texlive-kvoptions
           texlive-pdftexcmds
           texlive-xkeyval))
    (home-page "https://github.com/ho-tex/zref")
    (synopsis "Reference scheme for LaTeX")
    (description "This package offers a means to remove the limitation, of
only two properties, that is inherent in the way LaTeX's reference system
works.  The package implements an extensible referencing system, where
properties may be defined and used in the course of a document.  It provides
an interface for macro programmers to access the new reference scheme and some
modules that use it.")
    (license license:lppl1.3c+)))

(define-deprecated-package texlive-fonts-adobe-zapfding texlive-zapfding)

(define-public texlive-rsfs
  (package
    (name "texlive-rsfs")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/rsfs/"
                   "fonts/afm/public/rsfs/"
                   "fonts/map/dvips/rsfs/"
                   "fonts/source/public/rsfs/"
                   "fonts/tfm/public/rsfs/"
                   "fonts/type1/public/rsfs/"
                   "tex/plain/rsfs/")
             (base32
              "1sa32wnsj84wbwqji1fb4k9ik99dy5ji7zz4v0xbd7306agyhns5")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:modules
      '((guix build texlive-build-system)
        (guix build utils)
        (srfi srfi-1)
        (srfi srfi-26))
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'install 're-generate-fonts-metrics
            (lambda _
              (let ((mf #$(this-package-native-input "texlive-metafont"))
                    (cm #$(this-package-native-input "texlive-cm"))
                    (root (getcwd)))
                (mkdir-p "build")
                (with-directory-excursion "fonts/source/public/rsfs"
                  ;; Tell mf where to find mf.base.
                  (setenv "MFBASES"
                          (string-append mf "/share/texmf-dist/web2c"))
                  ;; Tell mf where to look for source files.
                  (setenv "MFINPUTS"
                          (string-append
                           (getcwd) ":"
                           mf "/share/texmf-dist/metafont/base:"
                           cm "/share/texmf-dist/fonts/source/public/cm"))
                  ;; Build font metrics (tfm).
                  (for-each (lambda (font)
                              (format #t "building font ~a\n" font)
                              (invoke "mf" "-progname=mf"
                                      (string-append "-output-directory="
                                                     root "/build")
                                      (string-append "\\"
                                                     "mode:=ljfour; "
                                                     "mag:=1; "
                                                     "batchmode; "
                                                     "input "
                                                     (basename font ".mf"))))
                            (find-files "." "[0-9]+\\.mf$")))
                ;; Install font metrics at the appropriate location.
                (for-each
                 (cut install-file <> "fonts/tfm/public/rsfs/")
                 (find-files "build/" "\\.tfm$"))))))))
    (native-inputs
     (list texlive-bin texlive-metafont texlive-cm))
    (home-page "https://ctan.org/pkg/rsfs")
    (synopsis "Ralph Smith's Formal Script font")
    (description
     "The fonts provide uppercase formal script letters for use as symbols in
scientific and mathematical typesetting (in contrast to the informal script
fonts such as that used for the calligraphic symbols in the TeX maths symbol
font).  The fonts are provided as Metafont source, and as derived Adobe Type
1 format.  LaTeX support, for using these fonts in mathematics, is available
via one of the packages @code{calrsfs} and @code{mathrsfs}.")
    (license (license:fsf-free "http://mirrors.ctan.org/fonts/rsfs/README"))))

(define-deprecated-package texlive-fonts-rsfs texlive-rsfs)

(define-public texlive-eso-pic
  (let ((template (simple-texlive-package
                   "texlive-eso-pic"
                   (list "doc/latex/eso-pic/"
                         "source/latex/eso-pic/"
                         "tex/latex/eso-pic/")
                   (base32
                    "05bqm4x209wji0q6xk1jrjp0nzqafp44dlq30hlpcagrggjb3d9s"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/eso-pic")
         ((#:build-targets _ '())
          #~(list "eso-pic.ins"))))
      (home-page "https://ctan.org/macros/latex/contrib/eso-pic")
      (synopsis "Add picture commands (or backgrounds) to every page")
      (description
       "The package adds one or more user commands to LaTeX's @code{shipout}
routine, which may be used to place the output at fixed positions.  The
@code{grid} option may be used to find the correct places.")
      (license license:lppl1.3+))))

(define-deprecated-package texlive-latex-eso-pic texlive-eso-pic)

(define-public texlive-eepic
  (package
    (name "texlive-eepic")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/eepic/"
                   "tex/latex/eepic/")
             (base32
              "16v8j3f8bgww9adddpfzpwd5q9kvak7xnp5kkvkrvhw8vshdspaa")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics))
    (home-page "https://www.ctan.org/pkg/eepic")
    (synopsis "Extensions to @code{epic} and the LaTeX drawing tools")
    (description
     "This package provides extensions to @code{epic} and the LaTeX picture
drawing environment.  It includes the drawing of lines at any slope, the
drawing of circles in any radii, and the drawing of dotted and dashed lines
much faster with much less TeX memory, and providing several new commands for
drawing ellipses, arcs, splines, and filled circles and ellipses.")
    (license license:public-domain)))

(define-deprecated-package texlive-latex-eepic texlive-eepic)

(define-public texlive-enotez
  (package
    (name "texlive-enotez")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/enotez/"
                   "tex/latex/enotez/")
             (base32
              "1s1wyq6m5932gpbpvvkiw857q94jn1rp7xy9y7hysz9aafjqjyk2")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-l3packages
           texlive-translations))
    (home-page "https://ctan.org/pkg/enotez")
    (synopsis "Support for end-notes")
    (description
     "This package allows nested endnotes, supports @code{hyperref} and
provides means for easy customization of the list of notes.")
    (license license:lppl1.3c+)))

(define-deprecated-package texlive-latex-enotez texlive-enotez)

(define-public texlive-endnotes
  (package
    (inherit (simple-texlive-package
              "texlive-endnotes"
              (list "doc/latex/endnotes/"
                    "tex/latex/endnotes/")
              (base32
               "1s7j5sg8fbhifng0gfqnghbvalbbh0p7j9v06r660w089364ypwz")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/endnotes")
    (synopsis "Deal with endnotesings in strings")
    (description
     "Accumulates notes (using the @code{\\endnote} command, which can be used
as a replacement for @code{\\footnote}), and places them at the end of
the section, chapter or document.")
    (license license:lppl1.0+)))

(define-public texlive-enumitem
  (package
    (inherit
     (simple-texlive-package
      "texlive-enumitem"
      (list "doc/latex/enumitem/" "tex/latex/enumitem/")
      (base32 "0qwbyjb4a82qjxrfmz06v3w5vly75id4ix4sw7lz2az68kz080dv")
      #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/enumitem")
    (synopsis "Customize basic list environments")
    (description
     "This package is intended to ease customizing the three basic list
environments: @code{enumerate}, @code{itemize} and @code{description}.  It
extends their syntax to allow an optional argument where a set of parameters
in the form @code{key=value} are available, for example:
@code{\\begin{itemize}[itemsep=1ex,leftmargin=1cm]}.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-enumitem texlive-enumitem)

(define-public texlive-multido
  (package
    (name "texlive-multido")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/generic/multido/"
                   "source/generic/multido/"
                   "tex/generic/multido/" "tex/latex/multido/")
             (base32
              "1vwf2naw5bgs93s2gcmf226f60ws9z6cmw6gi1562fs8vg4mnjsh")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/multido")
    (synopsis "Loop facility for Generic TeX")
    (description
     "The package provides the @code{\\multido} command, which was originally
designed for use with PSTricks.  Fixed-point arithmetic is used when working
on the loop variable, so that the package is equally applicable in graphics
applications like PSTricks as it is with the more common integer loops.")
    (license license:lppl)))

(define-public texlive-multirow
  (package
    (name "texlive-multirow")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/multirow/"
                   "source/latex/multirow/"
                   "tex/latex/multirow/")
             (base32
              "18xnxqbkkzblngws1ydmkiwfrf9gvrriqrjpb6g6kmaxciwypqd6")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/multirow")
    (synopsis "Create tabular cells spanning multiple rows")
    (description
     "The package has a lot of flexibility, including an option for specifying
an entry at the natural width of its text.  The package is distributed with
the @code{bigdelim} and @code{bigstrut} packages, which can be used to
advantage with @code{\\multirow} cells.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-multirow texlive-multirow)

(define-public texlive-overpic
  (package
    (name "texlive-overpic")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/overpic/"
                   "source/latex/overpic/"
                   "tex/latex/overpic/")
             (base32
              "0z6jkn54b4yfk2ia8cxcb5is3qyg64r0na05ixd8xbirrks9ir7w")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-eepic texlive-graphics))
    (home-page "https://www.ctan.org/pkg/overpic")
    (synopsis "Combine LaTeX commands over included graphics")
    (description
     "The @code{overpic} environment is a cross between the LaTeX
@code{picture} environment and the @code{\\includegraphics} command of
@code{graphicx}.  The resulting picture environment has the same dimensions as
the included graphic.  LaTeX commands can be placed on the graphic at defined
positions; a grid for orientation is available.")
    (license license:lppl1.0+)))

(define-deprecated-package texlive-latex-overpic texlive-overpic)

(define-public texlive-parskip
  (package
    (name "texlive-parskip")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/parskip/"
                   "source/latex/parskip/"
                   "tex/latex/parskip/")
             (base32
              "18yygddxv3kblvf4jhzqa8h1js0n8g1bw723r6ss2hlz4lj64kf0")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-etoolbox
           texlive-kvoptions))
    (home-page "https://www.ctan.org/pkg/parskip")
    (synopsis "Layout with zero @code{\\parindent}, non-zero @code{\\parskip}")
    (description
     "Simply changing @code{\\parskip} and @code{\\parindent} leaves a layout
that is untidy; this package (though it is no substitute for a properly
designed class) helps alleviate this untidiness.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-parskip texlive-parskip)

(define-public texlive-pbox
  (package
    (name "texlive-pbox")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/pbox/"
                   "source/latex/pbox/"
                   "tex/latex/pbox/")
             (base32
              "104x4y22msgxhnlz2x331zq7rw28v129s5ym1jqhsk685izb3hcl")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-tools))
    (home-page "https://ctan.org/pkg/pbox")
    (synopsis "@code{\\parbox} with a variable width")
    (description
     "@code{pbox} defines a @code{\\pbox} command which adjusts the box width
to that of the enclosed text, up to the maximum width given.  The package also
defines some associated length commands.")
    (license license:gpl3+)))

(define-deprecated-package texlive-latex-pbox texlive-pbox)

(define-public texlive-pdfpages
  (let ((template (simple-texlive-package
                   "texlive-pdfpages"
                   (list "doc/latex/pdfpages/"
                         "source/latex/pdfpages/"
                         "tex/latex/pdfpages/")
                   (base32
                    "0a68vxkygk20fp51fkp7nvs8mc7h6irdvxal8qsnn9zrgr965d76"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/pdfpages")
         ((#:build-targets _ '())
          #~(list "pdfpages.ins"))))
      (propagated-inputs
       (list texlive-tools texlive-oberdiek texlive-graphics texlive-eso-pic))
      (home-page "https://ctan.org/macros/latex/contrib/pdfpages")
      (synopsis "Include PDF documents in LaTeX")
      (description
       "This package simplifies the inclusion of external multi-page PDF
documents in LaTeX documents.  Pages may be freely selected and it is possible
to put several logical pages onto each sheet of paper.  Furthermore a lot of
hypertext features like hyperlinks and article threads are provided.  The
package supports pdfTeX (pdfLaTeX) and VTeX.  With VTeX it is even possible to
use this package to insert PostScript files, in addition to PDF files.")
      (license license:lppl1.3+))))

(define-deprecated-package texlive-latex-pdfpages texlive-pdfpages)

(define-public texlive-stix2-otf
  (let ((base (simple-texlive-package
               "texlive-stix2-otf"
               (list "/doc/fonts/stix2-otf/"
                     "/fonts/opentype/public/stix2-otf/")
               (base32 "0i7rd1wn5jgm3gbi779gy78apz63w034ck4pn73xw6s10zgjzmgl")
               ;; Building these fonts requires FontLab, which is nonfree.
               #:trivial? #t)))
    (package
      (inherit base)
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:phases phases)
          #~(modify-phases #$phases
              (add-after 'install 'symlink-fonts-to-system-fonts-prefix
                ;; This is so that fontconfig can locate the fonts, such as
                ;; when using xetex or xelatex.
                (lambda _
                  (let ((system-fonts-prefix (string-append #$output
                                                            "/share/fonts")))
                    (mkdir-p system-fonts-prefix)
                    (symlink (string-append
                              #$output "/share/texmf-dist/fonts/opentype"
                              "/public/stix2-otf")
                             (string-append system-fonts-prefix
                                            "/stix2-otf")))))))))
      (home-page "https://www.stixfonts.org/")
      (synopsis "OpenType Unicode text and maths fonts")
      (description "The Scientific and Technical Information eXchange (STIX)
fonts are intended to satisfy the demanding needs of authors, publishers,
printers, and others working in the scientific, medical, and technical fields.
They combine a comprehensive Unicode-based collection of mathematical symbols
and alphabets with a set of text faces suitable for professional publishing.")
      (license license:silofl1.1))))

(define-public texlive-sidecap
  (package
    (name "texlive-sidecap")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/sidecap/"
                   "source/latex/sidecap/"
                   "tex/latex/sidecap/")
             (base32
              "0bjb514a6j90ad7dgyyzrwk6pp7rlb3zk9mfy0fv5a615a5gz82x")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-ragged2e))
    (home-page "https://ctan.org/pkg/sidecap")
    (synopsis "Typeset captions sideways")
    (description
     "The @code{sidecap} package defines environments called @code{SCfigure}
and @code{SCtable} (analogous to @code{figure} and @code{table}) to typeset
captions sideways.  Options include @code{outercaption}, @code{innercaption},
@code{leftcaption} and @code{rightcaption}.")
    (license license:lppl1.0+)))

(define-deprecated-package texlive-latex-sidecap texlive-sidecap)

(define-public texlive-stmaryrd
  (let ((template (simple-texlive-package
                   "texlive-stmaryrd"
                   (list "/fonts/afm/public/stmaryrd/"
                         "/fonts/map/dvips/stmaryrd/"
                         "/fonts/source/public/stmaryrd/"
                         "/fonts/tfm/public/stmaryrd/"
                         "/fonts/type1/public/stmaryrd/"
                         "/source/fonts/stmaryrd/"
                         "/doc/fonts/stmaryrd/")
                   (base32
                    "0yn0yl6x1z9ab5gb56lhvkqabd2agz3ggxifwxkiysrj5780j29z"))))
    (package
      (inherit template)
      (arguments (substitute-keyword-arguments (package-arguments template)
                   ((#:tex-directory _ #t)
                    "latex/stmaryrd")
                   ((#:phases phases)
                    `(modify-phases ,phases
                       (add-after 'unpack 'patch-ins
                         (lambda _
                           (substitute* "source/fonts/stmaryrd/stmaryrd.ins"
                             (("^%% LaTeX2e.*") "\\input docstrip\n")
                             (("fontdef\\}\\}" line)
                              (string-append line "\n\\endbatchfile")))))))))
      (home-page "https://www.ctan.org/pkg/stmaryrd")
      (synopsis "St Mary Road symbols for theoretical computer science")
      (description
       "The fonts were originally distributed as Metafont sources only, but
Adobe Type 1 versions are also now available.  Macro support is provided for
use under LaTeX; the package supports the @code{only} option (provided by the
@code{somedefs} package) to restrict what is loaded, for those who don't need
the whole font.")
      (license license:lppl))))

(define-deprecated-package texlive-fonts-stmaryrd texlive-stmaryrd)

(define-public texlive-subfig
  (package
    (name "texlive-subfig")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/subfig/" "source/latex/subfig/"
                   "tex/latex/subfig/")
             (base32
              "0bq1328pb1ak91j7q8n1kh2fncr742lvff7apgf8kkxzxjfg2z9r")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-caption
           texlive-graphics))
    (home-page "https://ctan.org/pkg/subfig")
    (synopsis "Figures broken into subfigures")
    (description
     "The package provides support for the manipulation and reference of small
or sub figures and tables within a single figure or table environment.  It is
convenient to use this package when your subfigures are to be separately
captioned, referenced, or are to be included in the List-of-Figures.  A new
@code{\\subfigure} command is introduced which can be used inside a figure
environment for each subfigure.  An optional first argument is used as the
caption for that subfigure.")
    (license license:lppl)))

(define-public texlive-subfigure
  (let ((template (simple-texlive-package
                   "texlive-subfigure"
                   (list "doc/latex/subfigure/"
                         "source/latex/subfigure/"
                         "tex/latex/subfigure/")
                   (base32
                    "1327ygajf6gza5msvhfjjnk6r3sw7vb7rxg23v4gx4dmyxqfqrbi"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/subfigure")
         ((#:build-targets _ '())
          #~(list "subfigure.ins"))))
      (home-page "https://www.ctan.org/pkg/subfigure")
      (synopsis "Figures divided into subfigures")
      (description
       "This (deprecated) package provides support for the manipulation and
reference of small or \"sub\" figures and tables within a single figure or
table environment.  It is convenient to use this package when your subfigures
are to be separately captioned, referenced, or are to be included in the
List-of-Figures.  A new @code{\\subfigure} command is introduced which can be
used inside a figure environment for each subfigure.  An optional first
argument is used as the caption for that subfigure.  The package is now
considered obsolete: it was superseded by @code{subfig}, but users may find
the more recent @code{subcaption} package more satisfactory.")
      (license license:lppl))))

(define-deprecated-package texlive-latex-subfigure texlive-subfigure)

(define-public texlive-tabulary
  (package
    (name "texlive-tabulary")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/tabulary/" "source/latex/tabulary/"
                   "tex/latex/tabulary/")
             (base32
              "00afi9r5264rhfy5kg73fk763i7wm6bvzkmrlg7n17fwl6hx0sa1")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-tools))
    (home-page "https://ctan.org/pkg/tabulary")
    (synopsis "Tabular with variable width columns balanced")
    (description
     "The package defines a @code{tabular*}-like environment, @code{tabulary},
taking a \"total width\" argument as well as the column specifications.  The
environment uses column types @code{L}, @code{C}, @code{R} and @code{J} for
variable width columns (@code{\\raggedright}, @code{\\centering},
@code{\\raggedleft}, and normally justified).  In contrast to
@code{tabularx}'s @code{X} columns, the width of each column is weighted
according to the natural width of the widest cell in the column.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-tabulary texlive-tabulary)

(define-public texlive-threeparttable
  (package
    (name "texlive-threeparttable")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/threeparttable/"
                   "tex/latex/threeparttable/")
             (base32
              "05i50k1y736m52903nz4kf2xl23w6y7rrzyacs4kgd1w6kmjm6f7")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-bookmark
           texlive-hyperref))
    (home-page "https://ctan.org/pkg/threeparttable")
    (synopsis "Tables with captions and notes all the same width")
    (description
     "This package facilitates tables with titles (captions) and notes.  The
title and notes are given a width equal to the body of the table (a
@code{tabular} environment).  By itself, a @code{threeparttable} does not
float, but you can put it in a @code{table} or a @code{table*} or some other
environment.")
    (license (license:fsf-free "file://threeparttable.sty"))))

(define-public texlive-txfonts
  (package
    (inherit (simple-texlive-package
              "texlive-txfonts"
              (list "/doc/fonts/txfonts/"

                    "/fonts/afm/public/txfonts/"
                    "/fonts/tfm/public/txfonts/"
                    "/fonts/type1/public/txfonts/"
                    "/fonts/vf/public/txfonts/"

                    "/fonts/map/dvips/txfonts/"
                    "/fonts/enc/dvips/txfonts/"
                    "/tex/latex/txfonts/")
              (base32
               "017zjas5y1zlyq0iy4x6mv1qbz23xcy3y5xs0crj6zdnfvnccqgp")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/txfonts")
    (synopsis "Times-like fonts in support of mathematics")
    (description
     "Txfonts supplies virtual text roman fonts using Adobe Times (or URW
NimbusRomNo9L) with some modified and additional text symbols in the OT1, T1,
and TS1 encodings; maths alphabets using Times/URW Nimbus; maths fonts
providing all the symbols of the Computer Modern and AMS fonts, including all
the Greek capital letters from CMR; and additional maths fonts of various
other symbols.

The set is complemented by a sans-serif set of text fonts, based on
Helvetica/NimbusSanL, and a monospace set.

All the fonts are in Type 1 format (AFM and PFB files), and are supported by
TeX metrics (VF and TFM files) and macros for use with LaTeX.")
    ;; Any version of the GPL with font exception.
    (license license:gpl3+)))

(define-deprecated-package texlive-fonts-txfonts texlive-txfonts)

(define-public texlive-iwona
  (package
    (name "texlive-iwona")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/iwona/"
                   "fonts/afm/nowacki/iwona/"
                   "fonts/enc/dvips/iwona/"
                   "fonts/map/dvips/iwona/"
                   "fonts/opentype/nowacki/iwona/"
                   "fonts/tfm/nowacki/iwona/"
                   "fonts/type1/nowacki/iwona/"
                   "tex/latex/iwona/"
                   "tex/plain/iwona/")
             (base32
              "1gk80zj711rcnk06cvszic7lpm06nj47kbypg13rpijdzfsvmi8m")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/iwona")
    (synopsis "Sans-serif typeface for TeX")
    (description "Iwona is a two-element sans-serif typeface.  It was created
as an alternative version of the Kurier typeface, which was designed in 1975
for a diploma in typeface design at the Warsaw Academy of Fine Arts under the
supervision of Roman Tomaszewski.  Kurier was designed for linotype
typesetting of newspapers and similar periodicals.  The Iwona fonts are an
alternative version of the Kurier fonts.  The difference lies in the absence
of ink traps which typify the Kurier font.")
    (license license:gfl1.0)))

(define-deprecated-package texlive-fonts-iwona texlive-iwona)

(define-public texlive-jknappen
  (package
    (inherit (simple-texlive-package
              "texlive-jknappen"
              (list "/fonts/source/jknappen/"
                    "/fonts/tfm/jknappen/"
                    "/tex4ht/ht-fonts/alias/jknappen/"
                    "/tex4ht/ht-fonts/unicode/jknappen/")
              (base32
               "0xvy3c845jc7iw1h9rcm1r2yvm1ni1sm9r9k9j2cfc82xy43rwij")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/jknappen")
    (synopsis "Miscellaneous packages by Jörg Knappen")
    (description
     "This package contains a collection of macros by Jörg Knappen:
@table @code
@item greekctr
New counterstyles @code{\\greek} and @code{\\Greek}.
@item holtpolt
Non-commutative fractions
@item latin1jk
@itemx latin2jk
@itemx latin3jk
Inputenc definition files that allow verbatim input in the respective ISO
Latin codes.
@item mathbol
Blackboard bold fonts for use in maths.
@item mathrsfs
Mathematical script letters, as traditionally used in physics for Lagrangian,
Hamiltonian, path integral measures, etc.
@item parboxx
New alignment options for parboxen at top and bottom of the box.
@item sans
Interchanges the roles of sans serif and roman fonts throughout the document.
@item semtrans
Support for special latin letters and diacritics used in transliteration of
semitic languages
@item smartmn
Intelligent hyphen/minus, which guesses whether to render as hyphen or minus.
@item sgmlcmpt
Commands replacing the characters <, >, and &.
@item tccompat
A compatibility package for users of the older versions of the textcomp package.
@item young
Simple Young tableaux.
@end table")
    (license license:gpl2)))                    ;per the 00readme_txt file.

(define-public texlive-jadetex
  (let ((template (simple-texlive-package
                   "texlive-jadetex"
                   (list "/doc/man/man1/jadetex.1"
                         "/doc/man/man1/jadetex.man1.pdf"
                         "/doc/man/man1/pdfjadetex.1"
                         "/doc/man/man1/pdfjadetex.man1.pdf"
                         "/source/jadetex/base/"
                         ;; The following files are not generated from
                         ;; sources.
                         "/tex/jadetex/base/jadetex.ini"
                         "/tex/jadetex/base/pdfjadetex.ini"
                         "/tex/jadetex/base/uentities.sty")
                   (base32
                    "03chyc3vjqgxcj985gy4k0bd0lf1n4a6sgbhc7k84jparjk3hx4i"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t)
          "jadetex/base")
         ((#:phases phases)
          `(modify-phases ,phases
             (add-after 'unpack 'unify-source-directory
               (lambda _
                 (chdir "source/jadetex/base")
                 (for-each (lambda (f)
                             (copy-file f (basename f)))
                           (find-files "../../../tex/jadetex/base"))
                 #t))
             (add-after 'build 'generate-formats
               (lambda* (#:key inputs #:allow-other-keys)
                 (mkdir "web2c")
                 (for-each (lambda (f)
                             (symlink f (basename f)))
                           (find-files "build"))
                 (invoke "fmtutil-sys" "--byfmt" "jadetex"
                         "--fmtdir=web2c")
                 (invoke "fmtutil-sys" "--byfmt" "pdfjadetex"
                         "--fmtdir=web2c")))
             (add-after 'install 'install-formats-and-wrappers
               (lambda* (#:key inputs outputs #:allow-other-keys)
                 (let* ((out (assoc-ref outputs "out"))
                        (texlive-bin (assoc-ref inputs "texlive-bin"))
                        (pdftex (string-append texlive-bin "/bin/pdftex"))
                        (web2c (string-append out "/share/texmf-dist/web2c")))
                   (mkdir-p web2c)
                   (copy-recursively "web2c" web2c)
                   ;; Create convenience command wrappers.
                   (mkdir-p (string-append out "/bin"))
                   (symlink pdftex (string-append out "/bin/jadetex"))
                   (symlink pdftex (string-append out "/bin/pdfjadetex"))
                   #t)))))))
      (propagated-inputs
       ;; Propagate the texlive-updmap.cfg input used by xmltex, which provides the
       ;; required fonts for its use.
       (list texlive-xmltex texlive-kpathsea)) ;for fmtutil.cnf template
      (native-inputs
       (list texlive-cm ;for cmex10 and others
             texlive-latex-fonts        ;for lasy6
             ;; The t1cmr.fd file of texlive-latex-base refers to the ecrm font,
             ;; provided by the jknappen package collection.
             texlive-jknappen
             texlive-hyperref
             texlive-colortbl
             texlive-fancyhdr
             texlive-graphics ;for color.sty
             texlive-tools ;for array.sty
             texlive-marvosym
             texlive-tex-ini-files ;for pdftexconfig
             texlive-ulem))
      (home-page "https://www.ctan.org/pkg/jadetex/")
      (synopsis "TeX macros to produce TeX output using OpenJade")
      (description "JadeTeX is a companion package to the OpenJade DSSSL
processor.  OpenJade applies a DSSSL stylesheet to an SGML or XML document.
The output of this process can be in a number of forms, including a set of
high level LaTeX macros.  It is the task of the JadeTeX package to transform
these macros into DVI/PostScript (using the @command{jadetex} command) or
Portable Document Format (PDF) form (using the @command{pdfjadetex}
command).")
      ;; The license text is found at the header of the jadetex.dtx file.
      (license license:expat))))

(define-public texlive-libertine
  (package
    (inherit (simple-texlive-package
              "texlive-libertine"
              (list "/doc/fonts/libertine/"

                    "/fonts/enc/dvips/libertine/"
                    "/fonts/map/dvips/libertine/"
                    "/fonts/opentype/public/libertine/"
                    "/fonts/tfm/public/libertine/"
                    "/fonts/type1/public/libertine/"
                    "/fonts/vf/public/libertine/"

                    "/tex/latex/libertine/")
              (base32
               "1d5r80isyvs2v3i8pzlhsn7ns6bn8ldkbs82g25widraixlhg6yg")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/libertine")
    (synopsis "Use Linux Libertine and Biolinum fonts with LaTeX")
    (description
     "The package provides the Libertine and Biolinum fonts in both Type 1 and
OTF styles, together with support macros for their use.  Monospaced and
display fonts, and the \"keyboard\" set are also included, in OTF style, only.
The @code{mweights} package is used to manage the selection of font weights.
The package supersedes both the @code{libertineotf} and the
@code{libertine-legacy} packages.")
    (license (list license:gpl2+        ; with font exception
                   license:silofl1.1
                   license:lppl))))

(define-public texlive-dejavu
  (package
    (inherit (simple-texlive-package
              "texlive-dejavu"
              (list "/doc/fonts/dejavu/"

                    "/fonts/enc/dvips/dejavu/"
                    "/fonts/map/dvips/dejavu/"

                    "/fonts/afm/public/dejavu/"
                    "/fonts/tfm/public/dejavu/"
                    "/fonts/truetype/public/dejavu/"
                    "/fonts/type1/public/dejavu/"
                    "/fonts/vf/public/dejavu/"

                    "/tex/latex/dejavu/")
              (base32
               "0y4qf5jl0xncah9nkcaalmy69wwq02n3j895zp71n2p0nfi24aka")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/libertine")
    (synopsis "LaTeX support for the DejaVu fonts")
    (description
     "The package contains LaTeX support for the DejaVu fonts, which are
derived from the Vera fonts but contain more characters and styles.  The fonts
are included in the original TrueType format, and in converted Type 1 format.
The (currently) supported encodings are: OT1, T1, IL2, TS1, T2*, X2, QX, and
LGR.  The package doesn't (currently) support mathematics.")
    (license license:lppl)))

(define-public texlive-titlesec
  (package
    (inherit
     (simple-texlive-package
      "texlive-titlesec"
      (list "doc/latex/titlesec/" "tex/latex/titlesec/")
      (base32 "01nwh4p15xblc3kgivjliihy9kr8yr2cqsf9wn2iwqv1njx0i2zw")
      #:trivial? #t))
    (home-page "https://ctan.org/macros/latex/contrib/titlesec")
    (synopsis "Select alternative section titles")
    (description
     "This package provides an interface to sectioning commands for selection
from various title styles, e.g. for marginal titles and to change the font of
all headings with a single command, also providing simple one-step page
styles.  It also includes a package to change the page styles when there are
floats in a page.  You may assign headers/footers to individual floats, too.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-titlesec texlive-titlesec)

(define-public texlive-type1cm
  (package
    (name "texlive-type1cm")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/type1cm/" "source/latex/type1cm/"
                   "tex/latex/type1cm/")
             (base32
              "1922af5xvhrh4l8rqwz3bjd1gqvzfkxrfim28rpnvbx4n7jl6sdh")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/type1cm")
    (synopsis "Arbitrary size font selection in LaTeX")
    (description
     "LaTeX, by default, restricts the sizes at which you can use its default
computer modern fonts, to a fixed set of discrete sizes (effectively, a set
specified by Knuth).  The @code{type1cm} package removes this restriction;
this is particularly useful when using scalable versions of the @code{cm}
fonts (Bakoma, or the versions from BSR/Y&Y, or True Type versions from Kinch,
PCTeX, etc.).  Note that the LaTeX distribution now contains a package
@code{fix-cm}, which performs the task of @code{type1cm}, as well as doing the
same job for T1- and TS1-encoded @code{ec} fonts.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-type1cm texlive-type1cm)

(define-public texlive-lh
  (let ((template (simple-texlive-package
                   "texlive-lh"
                   (list "/doc/fonts/lh/"
                         "/source/fonts/lh/"
                         "/source/latex/lh/"
                         "/fonts/source/lh/"
                         "/tex/plain/lh/")
                   (base32
                    "0vw75i52asi5sssp8k9r8dy4ihvqbvmbsl3dini3ls8cky15lz37"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t)
          "latex/lh")
         ((#:build-targets _ '())
          ''("nfssfox.ins" "lcyfonts.ins" "ot2fonts.ins" "t2ccfonts.ins"))))
      (home-page "https://www.ctan.org/pkg/lh")
      (synopsis "Cyrillic fonts that support LaTeX standard encodings")
      (description
       "The LH fonts address the problem of the wide variety of alphabets that
are written with Cyrillic-style characters.  The fonts are the original basis
of the set of T2* and X2 encodings that are now used when LaTeX users need to
write in Cyrillic languages.  Macro support in standard LaTeX encodings is
offered through the latex-cyrillic and t2 bundles, and the package itself
offers support for other (more traditional) encodings.  The fonts, in the
standard T2* and X2 encodings are available in Adobe Type 1 format, in the
CM-Super family of fonts.  The package also offers its own LaTeX support for
OT2 encoded fonts, CM bright shaped fonts and Concrete shaped fonts.")
      (license license:lppl))))

(define-deprecated-package texlive-latex-lh texlive-lh)

(define-public texlive-marvosym
  (package
    (inherit (simple-texlive-package
              "texlive-marvosym"
              (list "/doc/fonts/marvosym/"
                    "/fonts/afm/public/marvosym/"
                    "/fonts/map/dvips/marvosym/"
                    "/fonts/tfm/public/marvosym/"
                    "/fonts/truetype/public/marvosym/"
                    "/fonts/type1/public/marvosym/"
                    "/tex/latex/marvosym/")
              (base32
               "0m3bbg06cia8ni86fjhvb7x4a5qcxgnpqcvicfms91w2px9ysc46")
              #:trivial? #t))
    (home-page "https://martinvogel.de/blog/index.php?\
/archives/131-Marvosym.ttf.html")
    (synopsis "Martin Vogel's Symbols (marvosym) font")
    (description "The Martin Vogel’s Symbols fonts (marvosym) contains the
Euro currency symbol as defined by the European commission, along with symbols
for structural engineering, symbols for steel cross-sections, astronomy
signs (sun, moon, planets), the 12 signs of the zodiac, scissor symbols, CE
sign and others.  This package contains both the original TrueType font and
the derived Type 1 font, together with support files for TeX (LaTeX).")
    (license (list license:lppl          ;for TeX support files
                   license:silofl1.1)))) ;for fonts

(define-public texlive-metapost
  (package
    (name "texlive-metapost")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/man/man1/dvitomp.1"
                   "doc/man/man1/dvitomp.man1.pdf"
                   "doc/man/man1/mpost.1"
                   "doc/man/man1/mpost.man1.pdf"
                   "doc/metapost/base/"
                   "fonts/afm/metapost/"
                   "fonts/enc/dvips/metapost/"
                   "fonts/map/dvips/metapost/"
                   "fonts/tfm/metapost/"
                   "fonts/type1/metapost/"
                   "metapost/base/"
                   "metapost/config/"
                   "metapost/misc/"
                   "metapost/support/charlib/"
                   "tex/generic/metapost/")
             (base32
              "04pgi23frfk6ds10zypqvki0852ds7m1s52c5qvbpyl647nfbgc5")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs (list texlive-kpathsea))
    (home-page "https://ctan.org/pkg/metapost")
    (synopsis "Create scalable illustrations")
    (description
     "MetaPost uses a language based on that of Metafont to produce precise
technical illustrations.  Its output is scalable PostScript or SVG, rather
than the bitmaps Metafont creates.")
    (license license:lppl)))

(define-public texlive-acmart
  (package
    (name "texlive-acmart")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "bibtex/bst/acmart/" "doc/latex/acmart/"
                   "source/latex/acmart/" "tex/latex/acmart/")
             (base32
              "0vz0dla2frf5wgp5xrqc9q4z730k9wayfkfj0vg58a2xjriarrzn")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-booktabs
           texlive-caption
           texlive-cmap
           texlive-comment
           texlive-draftwatermark
           texlive-environ
           texlive-etoolbox
           texlive-fancyhdr
           texlive-float
           texlive-geometry
           texlive-graphics
           texlive-hyperref
           texlive-hyperxmp
           texlive-iftex
           texlive-inconsolata
           texlive-libertine
           texlive-microtype
           texlive-natbib
           texlive-ncctools
           texlive-newtx
           texlive-preprint
           texlive-refcount
           texlive-setspace
           texlive-textcase
           texlive-totpages
           texlive-xcolor
           texlive-xkeyval
           texlive-xstring))
    (home-page "https://ctan.org/pkg/acmart")
    (synopsis "Class for typesetting publications of ACM")
    (description
     "This package provides a class for typesetting publications of the
Association for Computing Machinery (ACM).")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-acmart texlive-acmart)

(define-public texlive-varwidth
  (package
    (name "texlive-varwidth")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/varwidth/" "tex/latex/varwidth/")
             (base32
              "0jcrv4klcjpl17ml0zyqfvkrq6qwn2imxv8syqs5m6qk0fk7hg6l")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-bookmark
           texlive-hyperref))
    (home-page "https://ctan.org/pkg/varwidth")
    (synopsis "Variable-width @code{minipage}")
    (description
     "The @code{varwidth} environment is superficially similar to @code{minipage},
but the specified width is just a maximum value -- the box may get a narrower
natural width.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-varwidth texlive-varwidth)

(define-public texlive-wasy
  (package
    (inherit (simple-texlive-package
              "texlive-wasy"
              (list "/fonts/source/public/wasy/"
                    "/fonts/tfm/public/wasy/"
                    "/tex/plain/wasy/"
                    "/doc/fonts/wasy/")
              (base32
               "1swzxgld3lndi5q0q6zkwbw06ndh13fvp04as7zpwyhh646s0hbx")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/wasy")
    (synopsis "Waldi symbol fonts")
    (description "This package provides the @code{wasy} (Waldi symbol) fonts,
in the Metafont and Adobe Type 1 formats.  Support under LaTeX is provided by
the @code{wasysym} package.")
    (license license:public-domain)))

(define-public texlive-wasysym
  (package
    (name "texlive-wasysym")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/wasysym/" "source/latex/wasysym/"
                   "tex/latex/wasysym/")
             (base32
              "1n0rrrh510hy04a4fkxqh7skwfhp3xiiji78cw3mc65g06h1jyjc")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/wasysym")
    (synopsis "LaTeX support for the @code{wasy} fonts")
    (description
     "The @code{wasy} (Waldi Symbol) font by Roland Waldi provides many glyphs
like male and female symbols and astronomical symbols, as well as the complete
@code{lasy} font set and other odds and ends.  The @code{wasysym} package
implements an easy to use interface for these symbols.")
    (license license:lppl1.3c)))

(define-deprecated-package texlive-latex-wasysym texlive-wasysym)

(define-public texlive-wrapfig
  (package
    (inherit
     (simple-texlive-package
      "texlive-wrapfig"
      (list "doc/latex/wrapfig/" "tex/latex/wrapfig/")
      (base32 "0wk1vp0dqsp597xzsqbwj8xk80v7d77qmpjir84n54f920rf9ka9")
      #:trivial? #t))
    (home-page "https://ctan.org/macros/latex/contrib/wrapfig")
    (synopsis "Produces figures which text can flow around")
    (description
     "This package allows figures or tables to have text wrapped around them.
It does not work in combination with list environments, but can be used in a
@code{parbox} or @code{minipage}, and in two-column format.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-wrapfig texlive-wrapfig)

(define-public texlive-ucs
  (package
    (name "texlive-ucs")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/ucs/" "tex/latex/ucs/data/"
                   "tex/latex/ucs/utils/")
             (base32
              "1hr7dsfx7vggai1j7saba48lsm1a003my9qkbr6qmazgc3lbcvl8")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics
           texlive-hyperref))
    (home-page "https://ctan.org/pkg/ucs")
    (synopsis "Extended UTF-8 input encoding support for LaTeX")
    (description
     "The bundle provides the @code{ucs} package, and @file{utf8x.def},
together with a large number of support files.  The @file{utf8x.def}
definition file for use with @code{inputenc} covers a wider range of Unicode
characters than does @file{utf8.def} in the LaTeX distribution.  The package
provides facilities for efficient use of its large sets of Unicode characters.
Glyph production may be controlled by various options, which permits use of
non-ASCII characters when coding mathematical formulae.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-ucs texlive-ucs)

(define-public texlive-preview
  (package
    (name "texlive-preview")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/preview/" "source/latex/preview/"
                   "tex/latex/preview/")
             (base32
              "1njw4ziyigmzxky86sh6byn8jjdah51iyd8lkmwx5rxhaqp7snkp")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/preview")
    (synopsis "Extract bits of a LaTeX source for output")
    (description
     "The main purpose of the preview package is the extraction of selected
elements from a LaTeX source, like formulas or graphics, into separate
pages of a DVI file.  A flexible and convenient interface allows it to
specify what commands and constructs should be extracted.  This works
with DVI files postprocessed by either Dvips and Ghostscript or
dvipng, but it also works when you are using PDFTeX for generating PDF
files.")
    (license license:gpl3+)))

(define-deprecated-package texlive-latex-preview texlive-preview)

(define-public texlive-acronym
  (let ((template (simple-texlive-package
                   "texlive-acronym"
                   (list "doc/latex/acronym/"
                         "source/latex/acronym/"
                         "tex/latex/acronym/")
                   (base32
                    "0p2sws3qy7wv0v6bsy6c5j36n9s1ps7b1z7dmg1370schrjpqnfh"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t) "latex/acronym")
         ((#:build-targets _ '()) '(list "acronym.ins"))))
      (propagated-inputs
       (list texlive-bigfoot texlive-relsize texlive-xstring))
      (home-page "https://ctan.org/pkg/acronym")
      (synopsis "Expand acronyms at least once")
      (description
       "This package ensures that all acronyms used in the text are spelled
out in full at least once.  It also provides an environment to build a list of
acronyms used.  The package is compatible with PDF bookmarks.  The package
requires the @code{suffix} package, which in turn requires that it runs under
e-TeX.")
      (license license:lppl1.3+))))

(define-deprecated-package texlive-latex-acronym texlive-acronym)

(define-public texlive-pdftex
  (package
    (inherit (simple-texlive-package
              "texlive-pdftex"
              (list "/doc/pdftex/"
                    "/doc/man/man1/pdftex.1"
                    "/doc/man/man1/pdfetex.1"
                    "/fonts/map/dvips/dummy-space/dummy-space.map"
                    "/fonts/tfm/public/pdftex/dummy-space.tfm"
                    "/fonts/type1/public/pdftex/dummy-space.pfb"
                    "/scripts/simpdftex/simpdftex"
                    "/tex/generic/config/pdftex-dvi.tex"
                    "/tex/generic/pdftex/glyphtounicode.tex"
                    "/tex/generic/pdftex/pdfcolor.tex")
              (base32
               "0w4ar5g7x4w8zw8z6hdwqxwcbglfzzq7pcznz8rawllwy6dssr8g")
              #:trivial? #t))
    ;; TODO: add this missing package:
    ;; dehyph
    (propagated-inputs
     (list texlive-cm
           texlive-etex
           texlive-knuth-lib
           texlive-hyphen-base
           texlive-kpathsea
           texlive-tex-ini-files
           texlive-plain))
    (home-page "https://www.ctan.org/pkg/pdftex")
    (synopsis "TeX extension for direct creation of PDF")
    (description
     "This package provides an extension of TeX which can be configured to
directly generate PDF documents instead of DVI.")
    (license license:gpl2+)))

(define-deprecated-package texlive-generic-pdftex texlive-pdftex)

(define texlive-texmf
  (package
   (name "texlive-texmf")
   (version "20210325")
   (source texlive-texmf-src)
   (build-system gnu-build-system)
   (inputs
    `(("texlive-bin" ,texlive-bin)
      ("lua" ,lua)
      ("perl" ,perl)
      ("python" ,python)
      ("ruby" ,ruby)
      ("tcsh" ,tcsh)))
   (arguments
    `(#:modules ((guix build gnu-build-system)
                 (guix build utils)
                 (srfi srfi-26))

      ;; This package takes 4 GiB, which we can't afford to distribute from
      ;; our servers.
      #:substitutable? #f

      #:phases
        (modify-phases (map (cut assq <> %standard-phases)
                            '(set-paths unpack patch-source-shebangs))
          (add-after 'unpack 'unset-environment-variables
            (lambda _
              (unsetenv "TEXMF")
              (unsetenv "TEXMFCNF")
              #t))
          (add-after 'patch-source-shebangs 'install
            (lambda* (#:key outputs #:allow-other-keys)
              (let ((share (string-append (assoc-ref outputs "out") "/share")))
                (mkdir-p share)
                (invoke "mv" "texmf-dist" share))))
          (add-after 'install 'texmf-config
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (share (string-append out "/share"))
                     (texmfroot (string-append share "/texmf-dist/web2c"))
                     (texmfcnf (string-append texmfroot "/texmf.cnf"))
                     (fmtutilcnf (string-append texmfroot "/fmtutil.cnf"))
                     (texlive-bin (assoc-ref inputs "texlive-bin"))
                     (texbin (string-append texlive-bin "/bin"))
                     (tlpkg (string-append texlive-bin "/share/tlpkg")))
                ;; LuaJIT is not ported to powerpc64* yet.
                (if ,(target-ppc64le?)
                    (substitute* fmtutilcnf
                      (("^(luajittex|luajithbtex|mfluajit)" m)
                       (string-append "#! " m))))
                ;; Register SHARE as TEXMFROOT in texmf.cnf.
                (substitute* texmfcnf
                  (("TEXMFROOT = \\$SELFAUTOPARENT")
                   (string-append "TEXMFROOT = " share))
                  (("TEXMFLOCAL = \\$SELFAUTOGRANDPARENT/texmf-local")
                   "TEXMFLOCAL = $SELFAUTODIR/share/texmf-local")
                  (("!!\\$TEXMFLOCAL") "$TEXMFLOCAL"))
                ;; Register paths in texmfcnf.lua, needed for context.
                (substitute* (string-append texmfroot "/texmfcnf.lua")
                  (("selfautodir:") out)
                  (("selfautoparent:") (string-append share "/")))
                ;; Set path to TeXLive Perl modules
                (setenv "PERL5LIB"
                        (string-append (getenv "PERL5LIB") ":" tlpkg))
                ;; Configure the texmf-dist tree; inspired from
                ;; http://slackbuilds.org/repository/13.37/office/texlive/
                (setenv "PATH" (string-append (getenv "PATH") ":" texbin))
                (setenv "TEXMFCNF" texmfroot)
                (invoke "updmap-sys" "--nohash" "--syncwithtrees")
                (invoke "mktexlsr")
                (invoke "fmtutil-sys" "--all")))))))
   (properties `((max-silent-time . 9600))) ; don't time out while grafting
   (synopsis "TeX Live, a package of the TeX typesetting system")
   (description
    "TeX Live provides a comprehensive TeX document production system.
It includes all the major TeX-related programs, macro packages, and fonts
that are free software, including support for many languages around the
world.

This package contains the complete tree of texmf-dist data.")
   (license (license:fsf-free "https://www.tug.org/texlive/copying.html"))
   (home-page "https://www.tug.org/texlive/")))

(define-public texlive
  (package
   (name "texlive")
   (version "20210325")
   (source #f)
   (build-system trivial-build-system)
   (inputs `(("bash" ,bash-minimal)     ;for wrap-program
             ("texlive-bin" ,texlive-bin)
             ("texlive-texmf" ,texlive-texmf)))
   (native-search-paths
    (list (search-path-specification
           (variable "TEXMFLOCAL")
           (files '("share/texmf-local")))))
   (arguments
    `(#:modules ((guix build utils))
      #:builder
        ;; Build the union of texlive-bin and texlive-texmf, but take the
        ;; conflicting subdirectory share/texmf-dist from texlive-texmf.
        (begin
          (use-modules (guix build utils))
          (let ((out (assoc-ref %outputs "out"))
                (bin (assoc-ref %build-inputs "texlive-bin"))
                (texmf (assoc-ref %build-inputs "texlive-texmf"))
                (bash (assoc-ref %build-inputs "bash")))
               (mkdir out)
               (with-directory-excursion out
                 (for-each
                   (lambda (name)
                     (symlink (string-append bin "/" name) name))
                   '("include" "lib"))
                 (mkdir "bin")
                 (with-directory-excursion "bin"
                   (setenv "PATH" (string-append bash "/bin"))
                   (for-each
                     (lambda (name)
                       (symlink name (basename name))
                       (wrap-program
                         (basename name)
                         `("TEXMFCNF" =
                           (,(string-append texmf "/share/texmf-dist/web2c")))))
                     (find-files (string-append bin "/bin/") "")))
                 (mkdir "share")
                 (with-directory-excursion "share"
                   (for-each
                     (lambda (name)
                       (symlink (string-append bin "/share/" name) name))
                     '("info" "man" "tlpkg"))
                   (for-each
                     (lambda (name)
                       (symlink (string-append texmf "/share/" name) name))
                     '("texmf-dist" "texmf-var"))))
               #t))))
   (synopsis "TeX Live, a package of the TeX typesetting system")
   (description
    "TeX Live provides a comprehensive TeX document production system.
It includes all the major TeX-related programs, macro packages, and fonts
that are free software, including support for many languages around the
world.

This package contains the complete TeX Live distribution.")
   (license (license:fsf-free "https://www.tug.org/texlive/copying.html"))
   (home-page "https://www.tug.org/texlive/")))

(define-public perl-text-bibtex
  (package
    (name "perl-text-bibtex")
    (version "0.88")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://cpan/authors/id/A/AM/AMBS/Text-BibTeX-"
                           version ".tar.gz"))
       (sha256
        (base32
         "0b7lmjvfmypps1nw6nsdikgaakm0n0g4186glaqazg5xd1p5h55h"))))
    (build-system perl-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'add-output-directory-to-rpath
           (lambda* (#:key outputs #:allow-other-keys)
             (substitute* "inc/MyBuilder.pm"
               (("-Lbtparse" line)
                (string-append "-Wl,-rpath="
                               (assoc-ref outputs "out") "/lib " line)))
             #t))
         (add-after 'unpack 'install-libraries-to-/lib
           (lambda* (#:key outputs #:allow-other-keys)
             (substitute* "Build.PL"
               (("lib64") "lib"))
             #t)))))
    (native-inputs
     (list perl-capture-tiny perl-config-autoconf perl-extutils-libbuilder
           perl-module-build))
    (home-page "https://metacpan.org/release/Text-BibTeX")
    (synopsis "Interface to read and parse BibTeX files")
    (description "@code{Text::BibTeX} is a Perl library for reading, parsing,
and processing BibTeX files.  @code{Text::BibTeX} gives you access to the data
at many different levels: you may work with BibTeX entries as simple field to
string mappings, or get at the original form of the data as a list of simple
values (strings, macros, or numbers) pasted together.")
    (license license:perl-license)))

(define-public biber
  (package
    ;; Note: When updating Biber, make sure it matches our BibLaTeX version by
    ;; checking the Biber/BibLaTeX compatibility matrix in the BibLaTeX manual
    ;; at <https://ctan.org/pkg/biblatex>.
    (name "biber")
    (version "2.16")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/plk/biber/")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0586q8y1f2k23mvb02ccm3qsb35cwskafksixsjaih7a7xcf5gxx"))
              (patches (search-patches "biber-adapt-perl-5.36.patch"))))
    (build-system perl-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'install 'wrap-programs
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (perl5lib (getenv "PERL5LIB")))
               (wrap-program (string-append out "/bin/biber")
                 `("PERL5LIB" ":" prefix
                   (,(string-append perl5lib ":" out
                                    "/lib/perl5/site_perl")))))
             #t)))))
    (inputs
     (list perl-autovivification
           perl-class-accessor
           perl-data-dump
           perl-data-compare
           perl-data-uniqid
           perl-datetime-format-builder
           perl-datetime-calendar-julian
           perl-file-slurper
           perl-io-string
           perl-ipc-cmd
           perl-ipc-run3
           perl-list-allutils
           perl-list-moreutils
           perl-mozilla-ca
           perl-regexp-common
           perl-log-log4perl
           perl-parse-recdescent
           perl-unicode-collate
           perl-unicode-normalize
           perl-unicode-linebreak
           perl-encode-eucjpascii
           perl-encode-jis2k
           perl-encode-hanextra
           perl-xml-libxml
           perl-xml-libxml-simple
           perl-xml-libxslt
           perl-xml-writer
           perl-sort-key
           perl-text-csv
           perl-text-csv-xs
           perl-text-roman
           perl-uri
           perl-text-bibtex
           perl-libwww
           perl-lwp-protocol-https
           perl-business-isbn
           perl-business-issn
           perl-business-ismn
           perl-lingua-translit))
    (native-inputs
     `(("perl-config-autoconf" ,perl-config-autoconf)
       ("perl-extutils-libbuilder" ,perl-extutils-libbuilder)
       ("perl-module-build" ,perl-module-build)
       ;; for tests
       ("perl-file-which" ,perl-file-which)
       ("perl-test-more" ,perl-test-most) ; FIXME: "more" would be sufficient
       ("perl-test-differences" ,perl-test-differences)))
    (home-page "https://biblatex-biber.sourceforge.net/")
    (synopsis "Backend for the BibLaTeX citation management tool")
    (description "Biber is a BibTeX replacement for users of biblatex.  Among
other things it comes with full Unicode support.")
    (license license:artistic2.0)))

(define-public rubber
  (package
    (name "rubber")
    (version "1.5.1")
    (source (origin
              (method url-fetch)
              (uri (list (string-append "https://launchpad.net/rubber/trunk/"
                                        version "/+download/rubber-"
                                        version ".tar.gz")
                         (string-append "http://ebeffara.free.fr/pub/rubber-"
                                        version ".tar.gz")))
              (sha256
               (base32
                "178dmrp0mza5gqjiqgk6dqs0c10s0c517pk6k9pjbam86vf47a1p"))))
    (build-system python-build-system)
    (arguments
     '(#:tests? #f ; no `check' target
       #:phases
       (modify-phases %standard-phases
         (delete 'build)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             ;; texlive is required to build the PDF documentation; do not
             ;; build it.
             (invoke "python" "setup.py" "build" "--pdf=False" "install"
                     (string-append "--prefix=" (assoc-ref outputs "out"))))))))
    (native-inputs (list texinfo))
    (home-page "https://launchpad.net/rubber")
    (synopsis "Wrapper for LaTeX and friends")
    (description
     "Rubber is a program whose purpose is to handle all tasks related to the
compilation of LaTeX documents.  This includes compiling the document itself,
of course, enough times so that all references are defined, and running BibTeX
to manage bibliographic references.  Automatic execution of dvips to produce
PostScript documents is also included, as well as usage of pdfLaTeX to produce
PDF documents.")
    (license license:gpl2+)))

(define-public texmaker
  (package
    (name "texmaker")
    (version "5.0.4")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://www.xm1math.net/texmaker/texmaker-"
                                  version ".tar.bz2"))
              (sha256
               (base32
                "1qnh5g8zkjpjmw2l8spcynpfgs3wpcfcla5ms2kkgvkbdlzspqqx"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         ;; Qt has its own configuration utility.
         (replace 'configure
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (invoke "qmake"
                       (string-append "PREFIX=" out)
                       (string-append "DESKTOPDIR=" out "/share/applications")
                       (string-append "ICONDIR=" out "/share/pixmaps")
                       (string-append "METAINFODIR=" out "/share/metainfo")
                       "texmaker.pro")))))))
    (inputs
     (list poppler-qt5 qtbase-5 qtscript zlib))
    (native-inputs
     (list pkg-config))
    (home-page "https://www.xm1math.net/texmaker/")
    (synopsis "LaTeX editor")
    (description "Texmaker is a program that integrates many tools needed to
develop documents with LaTeX, in a single application.")
    (license license:gpl2+)))

(define-public texstudio
  (package
    (name "texstudio")
    (version "4.5.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/texstudio-org/texstudio")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0bzdcsc0273809hx04zqd2famq05q9rpvqcbqhkjqnqp9vxbisig"))))
    (build-system qt-build-system)
    (arguments
     `(#:tests? #f))                    ;tests work only with debug build
    (native-inputs
     (list pkg-config
           poppler-qt5
           qtdeclarative-5
           qtsvg-5
           qttools-5))
    (home-page "https://www.texstudio.org/")
    (synopsis "Feature-packed LaTeX editor")
    (description
     "TeXstudio is an integrated writing environment for creating LaTeX
documents.  It makes writing LaTeX comfortable by providing features such as
syntax-highlighting, an integrated viewer and reference checking.")
    (license license:gpl3)))

(define-public dvisvgm
  (package
    (name "dvisvgm")
    (version "3.0.3")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mgieseki/dvisvgm")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "11r401yqbw61n1mwsfk5qmwx2c92djwpl0q756qkds5kh25l9ci8"))))
    (native-inputs (list pkg-config
                         autoconf
                         autoconf-archive
                         automake
                         python-wrapper
                         libtool))
    (inputs (list texlive-libkpathsea
                  freetype
                  fontforge
                  clipper
                  ghostscript
                  xxhash
                  google-brotli
                  woff2
                  zlib))
    (build-system gnu-build-system)
    (synopsis "Command-line utility for generating SVG from DVI, EPS and PDF
files")
    (description
     "Dvisvgm converts TeX DVI, EPS and PDF files into an
SVG (Scalable Vector Graphics) image.  It provides full font support including
virtual fonts, font maps and sub-fonts.  The embedded SVG fonts can optionally
be replaced with graphics paths for applications that do not support SVG
fonts.  Dvisvgm supports also colors, emTeX, tpic, papersize, PDF mapfile
and PostScript specials.  A working TeX installation is needed.")
    (home-page "https://dvisvgm.de/")
    (license license:gpl3+)))

(define-public teximpatient
  ;; The homepage seems to be distributing this version which is currently the
  ;; most recent commit
  (let ((commit "e3666abff186832fd9c467ceda3958058f30bac2")
        (revision "0"))
    (package
      (name "teximpatient")
      (version (git-version "2.4" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url
                       "https://git.savannah.gnu.org/git/teximpatient.git/")
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "0r30383nmly7w29il6v3vmilnnyrzak0x0qmabjvnpaga9ansjmi"))))
      (build-system gnu-build-system)
      (arguments
       `(#:tests? #f ;there are none
         #:allowed-references ("out")
         #:phases (modify-phases %standard-phases
                    (add-after 'unpack 'fix-build
                      (lambda* (#:key inputs #:allow-other-keys)
                        (chdir "teximpatient")

                        ;; Remove generated files
                        (for-each delete-file
                                  '("book.pdf"
                                    "book.aux"
                                    "book.ccs"
                                    "book.log"
                                    "book.idx"
                                    "config.log"
                                    "config.status"
                                    "configure"
                                    "Makefile"))
                        (delete-file-recursively "autom4te.cache")

                        ;; make build reproducible
                        (substitute* "eplain.tex"
                          (("timestamp.*%")
                           (string-append "timestamp{"
                                          ,version "}"))))))))
      (native-inputs (list autoconf automake
                           (texlive-updmap.cfg (list texlive-amsfonts
                                                     texlive-palatino
                                                     texlive-zapfding
                                                     texlive-knuth-lib
                                                     texlive-mflogo-font
                                                     texlive-pdftex))))
      (home-page "https://www.gnu.org/software/teximpatient/")
      (synopsis "Book on TeX, plain TeX and Eplain")
      (description
       "@i{TeX for the Impatient} is a ~350 page book on TeX,
plain TeX, and Eplain, originally written by Paul Abrahams, Kathryn Hargreaves,
and Karl Berry.")
      (license license:fdl1.3+))))

(define-public lyx
  (package
    (name "lyx")
    (version "2.3.7")
    (source (origin
              (method url-fetch)
              ;; XXX: Upstream version is 2.3.7, but they released a suffixed
              ;; tarball.  This can probably be removed after next release.
              (uri (let ((suffix "-1"))
                     (string-append "https://ftp.lyx.org/pub/lyx/stable/"
                                    (version-major+minor version) ".x/"
                                    "lyx-" version suffix ".tar.xz")))
              (sha256
               (base32
                "1vfq30big55038bcymh83xh9dqp9wn0gnw0f6644xcw6zdj8igir"))
              (modules '((guix build utils)))
              (snippet
               '(begin
                  (delete-file-recursively "3rdparty")))))
    (build-system qt-build-system)
    (arguments
     (list #:configure-flags
           #~(list "-DLYX_USE_QT=QT5"
                   "-DLYX_EXTERNAL_BOOST=1"
                   "-DLYX_INSTALL=1"
                   "-DLYX_RELEASE=1"
                   "-DLYX_PROGRAM_SUFFIX=OFF"
                   (string-append "-DLYX_INSTALL_PREFIX=" #$output))
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'patch-python
                 (lambda* (#:key inputs #:allow-other-keys)
                   (substitute* '("lib/configure.py"
                                  "src/support/ForkedCalls.cpp"
                                  "src/support/Systemcall.cpp"
                                  "src/support/os.cpp"
                                  "src/support/filetools.cpp")
                     (("\"python ")
                      (string-append "\""
                                     (search-input-file inputs "/bin/python3")
                                     " ")))))
               (add-after 'unpack 'add-missing-test-file
                 (lambda _
                   ;; Create missing file that would cause tests to fail.
                   (with-output-to-file "src/tests/check_layout.cmake"
                     (const #t)))))))
    (inputs
     ;; XXX: Aspell library is properly detected during build, but hunspell
     ;; isn't.  So we use the former here.
     (list aspell
           boost
           libx11
           mythes
           python
           qtbase-5
           qtsvg-5
           zlib))
    (propagated-inputs
     (list (texlive-updmap.cfg (list texlive-ec))))
    (native-inputs
     (list python pkg-config))
    (home-page "https://www.lyx.org/")
    (synopsis "Document preparation system with GUI")
    (description "LyX is a document preparation system.  It excels at letting
you create complex technical and scientific articles with mathematics,
cross-references, bibliographies, indexes, etc.  It is very good for working
with documents of any length in which the usual processing abilities are
required: automatic sectioning and pagination, spell checking and so forth.")
    (license license:gpl2+)))

(define-public texlive-media9
  (package
    (name "texlive-media9")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/media9/"
                   "source/latex/media9/files/"
                   "source/latex/media9/players/"
                   "tex/latex/media9/javascript/"
                   "tex/latex/media9/players/")
             (base32
              "1kx0zbwd7pd4mah0b8l595hyjc03g505kfmn6fv7iaqvkixqrgbi")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/media9")
    (synopsis "Multimedia inclusion package with Adobe Reader-9/X compatibility")
    (description
     "The package provides an interface to embed interactive Flash (SWF) and
3D objects (Adobe U3D & PRC), as well as video and sound files or streams in
the popular MP4, FLV and MP3 formats into PDF documents with Acrobat-9/X
compatibility.  Playback of multimedia files uses the built-in Flash Player of
Adobe Reader and does, therefore, not depend on external plug-ins.  Flash
Player supports the efficient H.264 codec for video compression.

The package is based on the RichMedia Annotation, an Adobe addition to the PDF
specification.  It replaces the now obsolete @code{movie15} package.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-media9 texlive-media9)

(define-public texlive-ocgx2
  (package
    (name "texlive-ocgx2")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/ocgx2/" "tex/latex/ocgx2/")
             (base32
              "195zli0l69rvxxd7cs387g6bipppfl0pyfsf5invq191zlv319b2")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-l3packages
           texlive-media9
           texlive-pgf))
    (home-page "https://ctan.org/pkg/ocgx2")
    (synopsis "Drop-in replacement for 'ocgx' and 'ocg-p'")
    (description
     "This package serves as a drop-in replacement for the packages
@code{ocgx} by Paul Gaborit and @code{ocg-p} by Werner Moshammer for the
creation of PDF Layers.  It re-implements the functionality of the @code{ocg},
@code{ocgx}, and @code{ocg-p} packages and adds support for all known engines
and back-ends.  It also ensures compatibility with the @code{media9} and
@code{animate} packages.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-ocgx2 texlive-ocgx2)

(define-public texlive-ms
  (let ((template
         (simple-texlive-package
          "texlive-ms"
          (list "doc/latex/ms/" "source/latex/ms/" "tex/latex/ms/")
          (base32 "1cgrpx5mybiirjjdmni8kvqdg37dwfkixq3h9ami0mgxqqqfl2x3"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/ms")
         ((#:tex-format _ "latex") "latex")
         ((#:build-targets _ '())
          #~(list "count1to.ins" "multitoc.ins"))))
      (home-page "https://ctan.org/macros/latex/contrib/ms")
      (synopsis "Various LaTeX packages by Martin Schroder")
      (description
       "The remains of a bundle of LaTeX packages by Martin Schroder; the
collection comprises: count1to, make use of TeX counters; and multitoc,
typeset the table of contents in multiple columns.")
      (license license:lppl))))

(define-deprecated-package texlive-latex-ms texlive-ms)

(define-public texlive-ncctools
  (let ((template (simple-texlive-package
                   "texlive-ncctools"
                   (list "doc/latex/ncctools/"
                         "source/latex/ncctools/"
                         "tex/latex/ncctools/")
                   (base32
                    "1g3fpvrg6kx2ns97ih6iwdk0rcbxlv043x8rdppxdincl2lvbdx5"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t) "latex/ncctools")
         ((#:build-targets _ '()) '(list "ncctools.ins"))))
      (propagated-inputs
       (list texlive-amsmath texlive-graphics))
      (home-page "https://ctan.org/pkg/ncctools")
      (synopsis "Collection of general packages for LaTeX")
      (description
       "The NCCtools bundle contains many packages for general use under LaTeX;
many are also used by NCC LaTeX.  The bundle includes tools for:
@itemize
@item executing commands after a package is loaded;
@item watermarks;
@item counter manipulation;
@item improvements to the @code{description} environment;
@item hyphenation of compound words;
@item new levels of footnotes;
@item space-filling patterns;
@item poor man's Black Board Bold symbols;
@item alignment of the content of a box; use comma as decimal separator;
@item boxes with their own crop marks;
@item page cropmarks;
@item improvements to fancy headers;
@item float styles, mini floats, side floats;
@item manually marked footnotes;
@item extension of amsmath;
@item control of paragraph skip;
@item an envelope to the @code{graphicx} package;
@item dashed and multiple rules;
@item alternative techniques for declarations of sections, captions, and
toc-entries;
@item generalised text-stretching;
@item generation of new theorem-like environments;
@item control of the text area;
@item centered page layouts;
@item un-numbered top-level section.
@end itemize")
      (license license:lppl))))

(define-public texlive-numprint
  (let ((template
         (simple-texlive-package
          "texlive-numprint"
          (list "doc/latex/numprint/"
                "source/latex/numprint/"
                "tex/latex/numprint/")
          (base32 "1rqbqj4ffcfxxxxbs100pdslaiimwzgg19mf2qzcmm5snxwrf7zj"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/numprint")
         ((#:build-targets _ '())
          '(list "numprint.ins"))))
      (home-page "https://www.ctan.org/pkg/numprint")
      (synopsis "Print numbers with separators and exponent if necessary")
      (description
       "The package numprint prints numbers with a separator every three
digits and converts numbers given as 12345.6e789 to 12\\,345,6\\cdot
10^{789}.  Numbers are printed in the current mode (text or math) in
order to use the correct font.

Many things, including the decimal sign, the thousand separator, as
well as the product sign can be changed by the user, e.g., to reach
12,345.6\\times 10^{789}.

If an optional argument is given it is printed upright as unit.
Numbers can be rounded to a given number of digits.  The package
supports an automatic, language-dependent change of the number format.

Tabular alignment using the tabular, array, tabularx, and longtable
environments (similar to the dcolumn and rccol packages) is supported
using all features of numprint.  Additional text can be added before
and after the formatted number.")
      (license license:lppl))))

(define-deprecated-package texlive-latex-numprint texlive-numprint)

(define-public texlive-needspace
  (package
    (name "texlive-needspace")
    (version (number->string %texlive-revision))
    (source (texlive-origin name version
                            (list "doc/latex/needspace/"
                                  "source/latex/needspace/"
                                  "tex/latex/needspace/")
                            (base32
                             "12hbvv1w6b1k29qjvp72bkpnzsxpvrimzshllwinrxh9rx1mn550")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list #:tex-format "latex"))
    (native-inputs
     (list texlive-filecontents))
    (home-page "https://ctan.org/pkg/needspace")
    (synopsis "Insert pagebreak if not enough space")
    (description
     "This package provides commands to disable pagebreaking within a given
vertical space.  If there is not enough space between the command and the
bottom of the page, a new page will be started.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-needspace texlive-needspace)

(define-public texlive-changepage
  (package
    (name "texlive-changepage")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/changepage/"
                   "source/latex/changepage/"
                   "tex/latex/changepage/")
             (base32
              "0g9zlbqrgxh3p2vys2s84i8v590qi4fbpppp5lkaqc1di8kw60lm")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list #:tex-format "latex"))
    (native-inputs
     (list texlive-filecontents))
    (home-page "https://ctan.org/pkg/changepage")
    (synopsis "Margin adjustment and detection of odd/even pages")
    (description
     "The package provides commands to change the page layout in the middle of
a document, and to robustly check for typesetting on odd or even pages.  The
package is an extraction of code from the @code{memoir} class, whose user
interface it shares.  This package will eventually replace the @code{chngpage}
package, which is distributed with the package.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-changepage texlive-changepage)

(define-public texlive-eukdate
  (package
    (name "texlive-eukdate")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/eukdate/" "source/latex/eukdate/"
                   "tex/latex/eukdate/")
             (base32
              "1bz32l4500y4sx7ighpcvzfh0z45lzyyxm1dq1knmhdsv46gqaxi")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/eukdate")
    (synopsis "UK format dates, with weekday")
    (description
     "The package is used to change the format of @code{\\today}’s date,
including the weekday, e.g., @samp{Saturday, 26 June 2008}, the UK format,
which is preferred in many parts of the world, as distinct from that which is
used in @code{\\maketitle} of the article class, @samp{June 26, 2008}, the US
format.")
    (license license:lppl)))

(define-deprecated-package texlive-latex-eukdate texlive-eukdate)

(define-public texlive-ulem
  (package
    (inherit (simple-texlive-package
              "texlive-ulem"
              (list "doc/generic/ulem/" "tex/generic/ulem/")
              (base32 "0wcfnw5h6lsg2ilvkkf7mns8jgcn0n5sh45iznfsb49pfb4mming")
              #:trivial? #t))
    (home-page "https://www.ctan.org/pkg/ulem")
    (synopsis "Underline text in TeX")
    (description
     "The package provides an @code{\\ul} (underline) command which will break
over line ends; this technique may be used to replace @code{\\em} (both in that
form and as the @code{\\emph} command), so as to make output look as if it comes
from a typewriter.  The package also offers double and wavy underlining, and
striking out (line through words) and crossing out (/// over words).")
    (license license:lppl1.3c+)))

(define-public texlive-pgf
  (package
    (inherit (simple-texlive-package
              "texlive-pgf"
              (list "doc/generic/pgf/"
                    "scripts/pgf/"
                    "source/generic/pgf/c/"
                    "source/generic/pgf/testsuite/external/"
                    "source/generic/pgf/testsuite/mathtest/"
                    "tex/context/third/pgf/basiclayer/"
                    "tex/context/third/pgf/frontendlayer/"
                    "tex/context/third/pgf/math/"
                    "tex/context/third/pgf/systemlayer/"
                    "tex/context/third/pgf/utilities/"
                    "tex/generic/pgf/"
                    "tex/latex/pgf/basiclayer/"
                    "tex/latex/pgf/compatibility/"
                    "tex/latex/pgf/doc/"
                    "tex/latex/pgf/frontendlayer/"
                    "tex/latex/pgf/math/"
                    "tex/latex/pgf/systemlayer/"
                    "tex/latex/pgf/utilities/"
                    "tex/plain/pgf/basiclayer/"
                    "tex/plain/pgf/frontendlayer/"
                    "tex/plain/pgf/math/"
                    "tex/plain/pgf/systemlayer/"
                    "tex/plain/pgf/utilities/")
              (base32
               "02qfx9k0ggqfrbrjpfz74w8rkvvzk07rmgr37r7y64gggwpn4cw5")
              #:trivial? #t))
    (propagated-inputs
     (list texlive-atveryend
           texlive-fp
           texlive-graphics
           texlive-ms
           texlive-pdftexcmds
           texlive-xcolor))
    (home-page "https://ctan.org/graphics/pgf/base")
    (synopsis "Create PostScript and PDF graphics in TeX")
    (description
     "PGF is a macro package for creating graphics.  It is platform- and
format-independent and works together with the most important TeX backend
drivers, including pdfTeX and dvips.  It comes with a user-friendly syntax layer
called TikZ.  Its usage is similar to pstricks and the standard picture
environment.  PGF works with plain (pdf-)TeX, (pdf-)LaTeX, and ConTeXt.  Unlike
pstricks, it can produce either PostScript or PDF output.")
    ;; The code of the package is dual-license: GPL-2 or LPPL-1.3c+.  The
    ;; documentation is also dual-license: LPPL-1.3c+ or GFDL-1.2.
    (license (list license:gpl2 license:lppl1.3c+ license:fdl1.2+))))

(define-deprecated-package texlive-latex-pgf texlive-pgf)

(define-public texlive-koma-script
  (package
    (name "texlive-koma-script")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/koma-script/"
                   "source/latex/koma-script/"
                   "tex/latex/koma-script/")
             (base32
              "0k8mhikpll066x3683gmg3xas7a2mz93b9fip4k56hacxxb6map1")))
    (build-system texlive-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'move-required-files
            ;; These files are required by the build process.
            (lambda _
              (for-each (lambda (f)
                          (install-file
                           (string-append "doc/latex/koma-script/" f)
                           "build/"))
                        '("komabug.tex" "manifest.txt" "INSTALL.txt"
                          "INSTALLD.txt" "lppl.txt" "lppl-de.txt")))))))
    (propagated-inputs
     (list texlive-bookmark
           texlive-eso-pic
           texlive-etoolbox
           texlive-graphics
           texlive-l3packages
           texlive-xpatch))
    (home-page "https://ctan.org/pkg/koma-script")
    (synopsis "Bundle of versatile classes and packages")
    (description
     "The KOMA-Script bundle provides replacements for the article, report,
and book classes with emphasis on typography and versatility.  There is also
a letter class.  The bundle also offers: a package for calculating type areas
in the way laid down by the typographer Jan Tschichold, packages for easily
changing and defining page styles, a package @code{scrdate} for getting not
only the current date but also the name of the day, and a package
@code{scrtime} for getting the current time.  All these packages may be used
not only with KOMA-Script classes but also with the standard classes.")
    (license license:lppl1.3c+)))

(define-deprecated-package texlive-latex-koma-script texlive-koma-script)

(define-public texlive-atbegshi
  (let ((template (simple-texlive-package
                   "texlive-atbegshi"
                   (list "doc/latex/atbegshi/"
                         "source/latex/atbegshi/"
                         "tex/generic/atbegshi/")
                   (base32
                    "0vd90wdjwj5w4g4xka4nms3rgixjw63iwf0hj0v1akcfflwvgn69"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/atbegshi")
         ((#:build-targets _ '())
          #~(list "atbegshi.dtx"))))
      (home-page "https://www.ctan.org/pkg/atbegshi")
      (synopsis "Execute commands at @code{\\shipout} time")
      (description
       "This package is a modern reimplementation of package @code{everyshi},
providing various commands to be executed before a @code{\\shipout} command.
It makes use of e-TeX’s facilities if they are available.  The package may
be used either with LaTeX or with plain TeX.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-generic-atbegshi texlive-atbegshi)

(define-public texlive-bigintcalc
  (let ((template (simple-texlive-package
                   "texlive-bigintcalc"
                   (list "doc/latex/bigintcalc/"
                         "source/latex/bigintcalc/"
                         "tex/generic/bigintcalc/")
                   (base32
                    "1cyv4mcvx83ab782l6h2f86a63ipm845r7hv1m6f1z2336vy7rc5"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/bigintcalc")
         ((#:build-targets _ '())
          #~(list "bigintcalc.dtx"))))
      (propagated-inputs
       (list texlive-pdftexcmds))
      (home-page "https://www.ctan.org/pkg/bigintcalc")
      (synopsis "Integer calculations on very large numbers")
      (description
       "This package provides expandable arithmetic operations with big
integers that can exceed TeX's number limits.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-generic-bigintcalc texlive-bigintcalc)

(define-public texlive-bitset
  (let ((template (simple-texlive-package
                   "texlive-bitset"
                   (list "doc/latex/bitset/"
                         "source/latex/bitset/"
                         "tex/generic/bitset/")
                   (base32
                    "1q7vk5gr5a4vaa3l20j178cg2q7a99rxdiyxhzpx9a6lfqfkjddz"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/bitset")
         ((#:build-targets _ '())
          #~(list "bitset.dtx"))))
      (propagated-inputs
       (list texlive-bigintcalc texlive-infwarerr texlive-intcalc))
      (home-page "https://www.ctan.org/pkg/bitset")
      (synopsis "Handle bit-vector datatype")
      (description
       "This package defines and implements the data type bit set, a vector
of bits.  The size of the vector may grow dynamically.  Individual bits
can be manipulated.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-generic-bitset texlive-bitset)

(define-public texlive-etexcmds
  (let ((template (simple-texlive-package
                   "texlive-etexcmds"
                   (list "doc/latex/etexcmds/"
                         "source/latex/etexcmds/"
                         "tex/generic/etexcmds/")
                   (base32
                    "13cf1fs5x9d8749b2jgxmgnkrx0r4hwpl389r15kq3ldz9jfl627"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/etexcmds")
         ((#:build-targets _ '())
          #~(list "etexcmds.dtx"))))
      (propagated-inputs
       (list texlive-iftex texlive-infwarerr))
      (home-page "https://www.ctan.org/pkg/etexcmds")
      (synopsis "Avoid name clashes with e-TeX commands")
      (description
       "New primitive commands are introduced in e-TeX; sometimes the names
collide with existing macros.  This package solves the name clashes by
adding a prefix to e-TeX’s commands.  For example, ε-TeX’s
@code{\\unexpanded} is provided as @code{\\etex@@unexpanded}.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-generic-etexcmds texlive-etexcmds)

(define-public texlive-etextools
  (package
    (name "texlive-etextools")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/etextools/"
                   "source/latex/etextools/"
                   "tex/latex/etextools/")
             (base32
              "0bfcc8g8q5v1nyqmrg8n17hv4k8yvhsplansvriccpmvyx0w9y9d")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-etex
           texlive-etoolbox
           texlive-letltxmacro))
    (home-page "https://ctan.org/pkg/etextools")
    (synopsis "e-TeX tools for LaTeX users and package writers")
    (description
     "The package provides many (purely expandable) tools for LaTeX: extensive
list management; purely expandable loops; conversion; addition/deletion;
expansion and group control; tests on tokens, characters and control
sequences; tests on strings; purely expandable macros with options or
modifiers; some purely expandable numerics.")
    (license license:lppl)))

(define-public texlive-gettitlestring
  (let ((template (simple-texlive-package
                   "texlive-gettitlestring"
                   (list "doc/latex/gettitlestring/"
                         "source/latex/gettitlestring/"
                         "tex/generic/gettitlestring/")
                   (base32
                    "1vbvmwrpsvy37gbwdmsqbbsicjiww3i0bh1yqnb75jiya9an0sjb"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/gettitlestring")
         ((#:build-targets _ '())
          #~(list "gettitlestring.dtx"))))
      (home-page "https://www.ctan.org/pkg/gettitlestring")
      (synopsis "Clean up title references")
      (description
       "This package provides commands for cleaning up the title string
(such as removing @code{\\label} commands) for packages that typeset such
strings.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-generic-gettitlestring texlive-gettitlestring)

(define-public texlive-infwarerr
  (let ((template (simple-texlive-package
                   "texlive-infwarerr"
                   (list "doc/latex/infwarerr/"
                         "source/latex/infwarerr/"
                         "tex/generic/infwarerr/")
                   (base32
                    "0lpcrpf3d6xfdp68ri22126x57mvmq5dpj9np68ph8p8lhvhqdjd"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/infwarerr")
         ((#:build-targets _ '())
          #~(list "infwarerr.dtx"))))
      (home-page "https://www.ctan.org/pkg/infwarerr")
      (synopsis "Information/warning/error macros")
      (description
       "This package provides a complete set of macros for information,
warning and error messages.  Under LaTeX, the commands are wrappers for
the corresponding LaTeX commands; under Plain TeX they are available as
complete implementations.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-generic-infwarerr texlive-infwarerr)

(define-public texlive-intcalc
  (let ((template (simple-texlive-package
                   "texlive-intcalc"
                   (list "doc/latex/intcalc/"
                         "source/latex/intcalc/"
                         "tex/generic/intcalc/")
                   (base32
                    "15alwp9cr8wasfajs3p201p7nqml37vly9mpg1j5l6xv95javk7x"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/intcalc")
         ((#:build-targets _ '())
          #~(list "intcalc.dtx"))))
      (home-page "https://www.ctan.org/pkg/intcalc")
      (synopsis "Expandable arithmetic operations with integers")
      (description
       "This package provides expandable arithmetic operations with integers,
using the e-TeX extension @code{\\numexpr} if it is available.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-generic-intcalc texlive-intcalc)

(define-public texlive-kvdefinekeys
  (let ((template (simple-texlive-package
                   "texlive-kvdefinekeys"
                   (list "doc/latex/kvdefinekeys/"
                         "source/latex/kvdefinekeys/"
                         "tex/generic/kvdefinekeys/")
                   (base32
                    "1026h223ph3nzhs6jqbasa0bzsrdg3zgllfcwwcavfzb5i6p9jdf"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/kvdefinekeys")
         ((#:build-targets _ '())
          #~(list "kvdefinekeys.dtx"))))
      (home-page "https://www.ctan.org/pkg/kvdefinekeys")
      (synopsis "Define keys for use in the @code{kvsetkeys} package")
      (description
       "This package provides the @code{\\kv@@define@@key} (analogous to
keyval’s @code{\\define@@key}, to define keys for use by @code{kvsetkeys}.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-generic-kvdefinekeys texlive-kvdefinekeys)

(define-public texlive-kvsetkeys
  (let ((template (simple-texlive-package
                   "texlive-kvsetkeys"
                   (list "doc/latex/kvsetkeys/"
                         "source/latex/kvsetkeys/"
                         "tex/generic/kvsetkeys/")
                   (base32
                    "0b2f2r49vi8x54qshm1h9sh8zhdmy0mc2y44yd05kcmmbiiq7hfz"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/kvsetkeys")
         ((#:build-targets _ '())
          #~(list "kvsetkeys.dtx"))))
      (home-page "https://www.ctan.org/pkg/kvsetkeys")
      (synopsis "Key value parser with default handler support")
      (description
       "This package provides @code{\\kvsetkeys}, a variant of @code{\\setkeys}
from the @code{keyval} package.  Users can specify a handler that deals with
unknown options.  Active commas and equal signs may be used, and only one
level of curly braces are removed from the values.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-generic-kvsetkeys texlive-kvsetkeys)

(define-public texlive-listofitems
  (package
    (name "texlive-listofitems")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/generic/listofitems"
                   "tex/generic/listofitems")
             (base32
              "1vzp4qkpfxzgcll1ak9syyc91sl93k9wr5rgfqvd6d6rgrnh3ava")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/listofitems")
    (synopsis "Grab items in lists using user-specified separation character")
    (description
     "This package is designed to read a list, for which the parsing character
has been selected by the user, and to access any of these items with a simple
interface.")
    (license license:lppl1.3c+)))

(define-deprecated-package texlive-generic-listofitems texlive-listofitems)

(define-public texlive-ltxcmds
  (let ((template (simple-texlive-package
                   "texlive-ltxcmds"
                   (list "doc/generic/ltxcmds/"
                         "source/generic/ltxcmds/"
                         "tex/generic/ltxcmds/")
                   (base32
                    "1izcw9jl64iij541183hc156sjwamvxm7q9fkpfnz8sppyg31fkb"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/ltxcmds")
         ((#:build-targets _ '())
          #~(list "ltxcmds.dtx"))))
      (home-page "https://www.ctan.org/pkg/ltxcmds")
      (synopsis "LaTeX kernel commands extracted for general use")
      (description
       "This package exports some utility macros from the LaTeX kernel into
a separate namespace and also makes them available for other formats such
as plain TeX.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-generic-ltxcmds texlive-ltxcmds)

(define-public texlive-pdfescape
  (let ((template (simple-texlive-package
                   "texlive-pdfescape"
                   (list "doc/latex/pdfescape/"
                         "source/latex/pdfescape/"
                         "tex/generic/pdfescape/")
                   (base32
                    "16a0rdmpa4wxh6gyf46qwfgyh399rwdind2wc89phqd50ky9b5m4"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/pdfescape")
         ((#:build-targets _ '())
          #~(list "pdfescape.dtx"))))
      (home-page "https://www.ctan.org/pkg/pdfescape")
      (synopsis "pdfTeX's escape features for plain TeX")
      (description
       "This package implements pdfTeX's escape features (@code{\\pdfescapehex},
@code{\\pdfunescapehex}, @code{\\pdfescapename}, @code{\\pdfescapestring})
using TeX or e-TeX.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-generic-pdfescape texlive-pdfescape)

(define-public texlive-uniquecounter
  (let ((template (simple-texlive-package
                   "texlive-uniquecounter"
                   (list "doc/latex/uniquecounter/"
                         "source/latex/uniquecounter/"
                         "tex/generic/uniquecounter/")
                   (base32
                    "1ll3iwk8x44l3qx1dhna399ngg66vbllivv8i3lwzriwkx22xbf3"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/uniquecounter")
         ((#:build-targets _ '())
          #~(list "uniquecounter.dtx"))))
      (propagated-inputs
       (list texlive-bigintcalc texlive-infwarerr))
      (home-page "https://www.ctan.org/pkg/uniquecounter")
      (synopsis "Unlimited unique counter")
      (description
       "This package provides a kind of counter that provides unique number
values.  Several counters can be created with different names.  The numeric
values are not limited.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-generic-uniquecounter texlive-uniquecounter)

(define-public texlive-readarray
  (package
    (name "texlive-readarray")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/readarray/" "tex/latex/readarray/")
             (base32
              "05yi37j8jq5a9pp9n6qg76m2fw899vpmwafzgnxbg0qp2fmch2ch")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-listofitems))
    (home-page "https://www.ctan.org/pkg/readarray")
    (synopsis "Read, store and recall array-formatted data")
    (description
     "This package allows the user to input formatted data into elements of
a 2-D or 3-D array and to recall that data at will by individual cell number.
The data can be but need not be numerical in nature.  It can be, for example,
formatted text.")
    (license license:lppl1.3)))

(define-deprecated-package texlive-latex-readarray texlive-readarray)

(define-public texlive-verbatimbox
  (package
    (name "texlive-verbatimbox")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/verbatimbox/"
                   "tex/latex/verbatimbox/")
             (base32
              "00n3x075ya3s2qwmcz2vvn8x70pbbgj2cbwz0ifw89jrc4ljisgi")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-tools))
    (home-page "https://www.ctan.org/pkg/verbatimbox")
    (synopsis "Deposit verbatim text in a box")
    (description
     "The package provides a @code{verbbox} environment to place its contents
into a globally available box, or into a box specified by the user.  The
global box may then be used in a variety of situations (for example, providing
a replica of the @code{boxedverbatim} environment itself).  A valuable use is
in places where the standard @code{verbatim} environment (which is based on a
@code{trivlist}) may not appear.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-verbatimbox texlive-verbatimbox)

(define-public texlive-examplep
  (package
    (name "texlive-examplep")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/examplep/" "tex/latex/examplep/")
             (base32
              "0afbl77i57hxngc3l0czdzmmkhcgh2l4h2dpbg9ax9p9dv8c006n")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/examplep")
    (synopsis "Verbatim phrases and listings in LaTeX")
    (description
     "The @code{examplep} package provides sophisticated features for
typesetting verbatim source code listings, including the display of the source
code and its compiled LaTeX or METAPOST output side-by-side, with automatic
width detection and enabled page breaks (in the source), without the need for
specifying the source twice.  Special care is taken that section, page and
footnote numbers do not interfere with the main document.  For typesetting
short verbatim phrases, a replacement for the @code{\\verb} command is also
provided in the package, which can be used inside tables and moving arguments
such as footnotes and section titles.")
    ;; No version of the GPL is specified.
    (license license:gpl3+)))

(define-deprecated-package texlive-latex-examplep texlive-examplep)

(define-public texlive-xunicode
  (package
    (inherit
     (simple-texlive-package "texlive-xunicode"
                             (list "doc/xelatex/xunicode/"
                                   "tex/xelatex/xunicode/")
                             (base32
                              "1d96i8kd2lhbykc3rxy2jjvws404f2vy1cvdcp5bdr6l9m72q1fa")
                             #:trivial? #t))
    (propagated-inputs (list texlive-tipa))
    (home-page "https://ctan.org/macros/xetex/latex/xunicode")
    (synopsis "Generate Unicode characters from accented glyphs")
    (description
     "The package supports XeTeX's (and other putative future similar engines')
need for Unicode characters, in a similar way to what the fontenc does for
8-bit (and the like) fonts: convert accent-glyph sequence to a single Unicode
character for output.  The package also covers glyphs specified by
packages (such as @code{tipa}) which define many commands for single text
glyphs.")
    (license license:lppl1.3+)))

(define-public texlive-xypic
  (let ((template (simple-texlive-package
                   "texlive-xypic"
                   (list "/doc/generic/xypic/"
                         "/dvips/xypic/xy389dict.pro"
                         "/fonts/enc/dvips/xypic/"
                         "/fonts/map/dvips/xypic/xypic.map"

                         "/fonts/source/public/xypic/"
                         "/fonts/afm/public/xypic/"
                         "/fonts/tfm/public/xypic/"
                         "/fonts/type1/public/xypic/"
                         "/tex/generic/xypic/")
                   (base32
                    "09b51bbm189xh7039h5n8nmab5nn2bybhh26qjn08763m80zdhjg")
                   #:trivial? #t)))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:phases phases)
          `(modify-phases ,phases
             (delete 'reset-gzip-timestamps)))))
      (home-page "https://www.ctan.org/pkg/xypic")
      (synopsis "Flexible diagramming macros")
      (description "This is a package for typesetting a variety of graphs and
diagrams with TeX.  Xy-pic works with most formats (including LaTeX,
AMS-LaTeX, AMS-TeX, and plain TeX).  The distribution includes Michael Barr's
@code{diag} package, which was previously distributed stand-alone.")
      (license license:gpl3+))))

(define-deprecated-package texlive-fonts-xypic texlive-xypic)

(define-deprecated-package texlive-generic-xypic texlive-xypic)

(define-public texlive-bibtex
  (package
    (name "texlive-bibtex")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "bibtex/bib/base/"
                   "bibtex/bst/base/"
                   "doc/bibtex/base/"
                   "doc/man/man1/bibtex.1"
                   "doc/man/man1/bibtex.man1.pdf"
                   "tex/generic/bibtex/")
             (base32
              "0h72ckha1mv1a2i5v85l68amfc0kf0km9iyin6vxxal69146j8gp")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs (list texlive-kpathsea))
    (home-page "https://ctan.org/pkg/bibtex")
    (synopsis "Process bibliographies for LaTeX")
    (description
     "BibTeX allows the user to store his citation data in generic form, while
printing citations in a document in the form specified by a BibTeX style, to
be specified in the document itself (one often needs a LaTeX citation-style
package, such as @command{natbib} as well).")
    (license license:knuth)))

(define-public texlive-charter
  (package
    (name "texlive-charter")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/charter/"
                   "fonts/afm/bitstrea/charter/"
                   "fonts/tfm/bitstrea/charter/"
                   "fonts/type1/bitstrea/charter/"
                   "fonts/vf/bitstrea/charter/")
             (base32
              "09l5ymgz48s3hyn776l01g3isk3dnhrj1vdavdw4qq4kfxxpqdn9")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     ;; This provides charter.map.
     (list texlive-psnfss))
    (home-page "https://www.ctan.org/pkg/charter")
    (synopsis "Charter fonts for TeX")
    (description "This package provides a copy of the Charter Type-1 fonts
which Bitstream contributed to the X consortium, renamed for use with TeX.
Support for use with LaTeX is available in @code{freenfss}, part of
@command{psnfss}.")
    (license (license:non-copyleft
              "http://mirrors.ctan.org/fonts/charter/readme.charter"))))

(define-deprecated-package texlive-fonts-charter texlive-charter)

(define-public texlive-chngcntr
  (package
    (name "texlive-chngcntr")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/chngcntr/" "tex/latex/chngcntr/")
             (base32
              "0ag1hb1vkl0xdzslp6f0j59dijwr9k9kq7vaada148241q0hflbj")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/chngcntr")
    (synopsis "Change the resetting of counters")
    (description
     "This package defines commands @code{\\counterwithin} (which sets up
a counter to be reset when another is incremented) and
@code{\\counterwithout} (which unsets such a relationship).")
    (license license:lppl)))

(define-public texlive-context
  (package
    (inherit (simple-texlive-package
              "texlive-context"
              (list "/doc/context/"
                    "/doc/man/man1/context.1"
                    "/doc/man/man1/luatools.1"
                    "/doc/man/man1/mtx-babel.1"
                    "/doc/man/man1/mtx-base.1"
                    "/doc/man/man1/mtx-bibtex.1"
                    "/doc/man/man1/mtx-cache.1"
                    "/doc/man/man1/mtx-chars.1"
                    "/doc/man/man1/mtx-check.1"
                    "/doc/man/man1/mtx-colors.1"
                    "/doc/man/man1/mtx-context.1"
                    "/doc/man/man1/mtx-dvi.1"
                    "/doc/man/man1/mtx-epub.1"
                    "/doc/man/man1/mtx-evohome.1"
                    "/doc/man/man1/mtx-fcd.1"
                    "/doc/man/man1/mtx-flac.1"
                    "/doc/man/man1/mtx-fonts.1"
                    "/doc/man/man1/mtx-grep.1"
                    "/doc/man/man1/mtx-interface.1"
                    "/doc/man/man1/mtx-metapost.1"
                    "/doc/man/man1/mtx-modules.1"
                    "/doc/man/man1/mtx-package.1"
                    "/doc/man/man1/mtx-pdf.1"
                    "/doc/man/man1/mtx-plain.1"
                    "/doc/man/man1/mtx-profile.1"
                    "/doc/man/man1/mtx-rsync.1"
                    "/doc/man/man1/mtx-scite.1"
                    "/doc/man/man1/mtx-server.1"
                    "/doc/man/man1/mtx-texworks.1"
                    "/doc/man/man1/mtx-timing.1"
                    "/doc/man/man1/mtx-tools.1"
                    "/doc/man/man1/mtx-unicode.1"
                    "/doc/man/man1/mtx-unzip.1"
                    "/doc/man/man1/mtx-update.1"
                    "/doc/man/man1/mtx-watch.1"
                    "/doc/man/man1/mtx-youless.1"

                    "/bibtex/bst/context/"
                    "/context/"

                    "/fonts/afm/hoekwater/context/contnav.afm"
                    "/fonts/cid/fontforge/Adobe-CNS1-4.cidmap"
                    "/fonts/cid/fontforge/Adobe-GB1-4.cidmap"
                    "/fonts/cid/fontforge/Adobe-Identity-0.cidmap"
                    "/fonts/cid/fontforge/Adobe-Japan1-5.cidmap"
                    "/fonts/cid/fontforge/Adobe-Japan1-6.cidmap"
                    "/fonts/cid/fontforge/Adobe-Japan2-0.cidmap"
                    "/fonts/cid/fontforge/Adobe-Korea1-2.cidmap"
                    "/fonts/enc/dvips/context/"
                    "/fonts/map/dvips/context/"
                    "/fonts/map/luatex/context/"
                    "/fonts/map/pdftex/context/"
                    "/fonts/misc/xetex/fontmapping/context/"
                    "/fonts/tfm/hoekwater/context/"
                    "/fonts/type1/hoekwater/context/"
                    "/metapost/context/"
                    "/scripts/context/"
                    "/tex/context/base/"
                    "/tex/context/bib/"
                    "/tex/context/colors/"
                    "/tex/context/fonts/"
                    "/tex/context/interface/"
                    "/tex/context/modules/"
                    "/tex/context/patterns/"
                    "/tex/context/sample/"
                    "/tex/context/test/"
                    "/tex/context/user/"
                    "/tex/generic/context/"
                    "/tex/latex/context/")
              (base32
               "1rsw760f52rj62i7ms89xgxdi0qw6hag5fs5hb667nclr4kdkam8")
              #:trivial? #t))
    ;; TODO: add these missing packages:
    ;; xetex, luatex, lm-math, manfnt-font, and mptopdf
    (propagated-inputs
     (list texlive-amsfonts
           texlive-lm
           texlive-pdftex
           texlive-metapost
           texlive-stmaryrd
           texlive-mflogo-font))
    (home-page "https://www.ctan.org/pkg/context")
    (synopsis "Full featured, parameter driven macro package for TeX")
    (description "ConTeXt is a full featured, parameter driven macro package,
which fully supports advanced interactive documents.  See the ConTeXt garden
for a wealth of support information.")
    ;; The GPL applies to all code; alternatively, the LaTeX license may be used.
    ;; The CC-BY-SA license applies to all documentation.
    (license (list license:lppl1.3c+
                   license:gpl2+
                   license:cc-by-sa4.0))))

(define-deprecated-package texlive-context-base texlive-context)

(define-public texlive-beamer
  (package
    (name "texlive-beamer")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/beamer/"
                   "tex/latex/beamer/")
             (base32
              "091n27n4l3iac911bvmpp735ffryyzaq46mkclgn3q9jsvc4ngiv")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-amsfonts
           texlive-amsmath
           texlive-atbegshi
           texlive-etoolbox
           texlive-graphics
           texlive-hyperref
           texlive-iftex
           texlive-oberdiek
           texlive-pgf
           texlive-tools
           texlive-translator
           texlive-ucs
           texlive-xcolor))
    (home-page "https://www.ctan.org/pkg/beamer")
    (synopsis "LaTeX class for producing presentations and slides")
    (description
     "The @code{beamer} LaTeX class can be used for producing slides.
The class works in both PostScript and direct PDF output modes, using the
@code{pgf} graphics system for visual effects.  Content is created in the
@code{frame} environment, and each frame can be made up of a number of slides
using a simple notation for specifying material to appear on each slide within
a frame.  Short versions of title, authors, institute can also be specified as
optional parameters.  Whole frame graphics are supported by plain frames.  The
class supports @code{figure} and @code{table} environments, transparency
effects, varying slide transitions and animations.")
    ;; Code is dual licensed under GPLv2+ or LPPL1.3c+; documentation is
    ;; dual-licensed under either FDLv1.3+ or LPPL1.3c+.
    (license (list license:lppl1.3c+ license:gpl2+ license:fdl1.3+))))

(define-deprecated-package texlive-latex-beamer texlive-beamer)

(define-public texlive-xmpincl
  (package
    (name "texlive-xmpincl")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/xmpincl/" "source/latex/xmpincl/"
                   "tex/latex/xmpincl/")
             (base32
              "1r9vga6pl8q0p40njr1l04nhga4i0pjyppsd9qmxx0kx408siram")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-iftex))
    (home-page "https://ctan.org/pkg/xmpincl")
    (synopsis "Include eXtensible Metadata Platform data in pdfLaTeX")
    (description
     "The XMP (eXtensible Metadata platform) is a framework to add metadata to
digital material to enhance the workflow in publication.  The essence is that
the metadata is stored in an XML file, and this XML stream is then embedded in
the file to which it applies.")
    (license license:gpl3+)))

(define-deprecated-package texlive-latex-xmpincl texlive-xmpincl)

(define-public texlive-pdfx
  (let ((template (simple-texlive-package
                   "texlive-pdfx"
                   (list "/doc/latex/pdfx/"
                         "/source/latex/pdfx/"
                         "/tex/latex/pdfx/")
                   (base32
                    "1z4j4d92k2fjmf8jfap4zn7ij97d9rz2jcs9aslcac07ag4x5bdp"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t)
          "latex/pdfx")
         ((#:phases phases)
          `(modify-phases ,phases
             (add-after 'unpack 'fix-encoding
               (lambda _
                 (substitute* "source/latex/pdfx/pdfx.dtx"
                   (("    .+umaczy") "umaczy"))))))))
      (propagated-inputs
       (list texlive-pdftex))
      (home-page "https://www.ctan.org/pkg/pdfx")
      (synopsis "PDF/X and PDF/A support for pdfTeX, LuaTeX and XeTeX")
      (description
       "This package helps LaTeX users to create PDF/X, PDF/A and other
standards-compliant PDF documents with pdfTeX, LuaTeX and XeTeX.")
      (license license:lppl1.2+))))

(define-deprecated-package texlive-latex-pdfx texlive-pdfx)

(define-public texlive-ydoc
  (package
    (name "texlive-ydoc")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/ydoc/" "source/latex/ydoc/"
                   "tex/generic/ydoc/" "tex/latex/ydoc/")
             (base32
              "1z7690vin47mw47gjg7k4h49b4ckg6g96l1zlziyjmjbkyzmyhdn")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'create-missing-directories
            ;; XXX: These directories are not created even though they belong
            ;; to locations in TEXLIVE-ORIGIN.  Create them manually.
            (lambda _
              (mkdir-p "tex/generic/ydoc/")
              (mkdir-p "tex/latex/ydoc/"))))))
    (propagated-inputs
     (list texlive-etoolbox
           texlive-float
           texlive-hyperref
           texlive-listings
           texlive-needspace
           texlive-svn-prov
           texlive-tools
           texlive-url
           texlive-xcolor))
    (home-page "https://ctan.org/pkg/ydoc")
    (synopsis "Macros for documentation of LaTeX classes and packages")
    (description "The package provides macros and environments to document
LaTeX packages and classes.  It is an (as yet unfinished) alternative to the
@code{ltxdoc} class and the @code{doc} or @code{xdoc} packages.  The aim is to
provide a different layout and more modern styles (using the @code{xcolor},
@code{hyperref} packages, etc.)  This is an alpha release, and should probably
not (yet) be used with other packages, since the implementation might
change.")
    (license license:lppl1.3+)))

(define-public texlive-pstricks
  (package
    (name "texlive-pstricks")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/generic/pstricks/"
                   "dvips/pstricks/"
                   "tex/generic/pstricks/"
                   "tex/latex/pstricks/")
             (base32
              "15c9iqfq2y9c8c78cvqb6vzd5a5rm7qq5x7m05jq1hb8sgqrqb0j")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-amsfonts
           texlive-amsmath
           texlive-babel
           texlive-bera
           texlive-biblatex
           texlive-booktabs
           texlive-caption
           texlive-chngcntr
           texlive-eso-pic
           texlive-fancyvrb
           texlive-filecontents
           texlive-footmisc
           texlive-graphics
           texlive-hyperref
           texlive-ifplatform
           texlive-iftex
           texlive-listings
           texlive-multido
           texlive-ragged2e
           texlive-setspace
           texlive-subfig
           texlive-tools
           texlive-xcolor))
    (home-page "http://www.ctan.org/pkg/pstricks")
    (synopsis "PostScript macros for TeX")
    (description
     "PSTricks offers an extensive collection of macros for generating
PostScript that is usable with most TeX macro formats, including Plain TeX,
LaTeX, AMS-TeX, and AMS-LaTeX.  Included are macros for colour, graphics, pie
charts, rotation, trees and overlays.  It has many special features, including
a wide variety of graphics (picture drawing) macros, with a flexible interface
and with colour support.  There are macros for colouring or shading the cells
of tables.")
    (license license:lppl1.3+)))

(define-public texlive-pst-text
  (package
    (name "texlive-pst-text")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/generic/pst-text/"
                   "dvips/pst-text/"
                   "tex/generic/pst-text/"
                   "tex/latex/pst-text/")
             (base32
              "146fpzd1xlqi94q5r48z8ni8qww713yh6nwkbr9pw27mjrqdadb9")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-pstricks))
    (home-page "http://www.ctan.org/pkg/pst-text")
    (synopsis "Text and character manipulation in PSTricks")
    (description "Pst-text is a PSTricks based package for plotting text along
a different path and manipulating characters.  It includes the functionality
of the old package @code{pst-char}.")
    (license license:lppl)))

(define-public texlive-marginnote
  (let ((template (simple-texlive-package
                   "texlive-marginnote"
                   (list "/source/latex/marginnote/marginnote.dtx")
                   (base32
                    "152bwxhnssj40rr72r6cfirvqbnc0h7xnagfrbz58v2xck53qhg1"))))
    (package
      (inherit template)
      (home-page "http://www.ctan.org/pkg/marginnote")
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/marginnote")
         ((#:build-targets _ '())
          ''("marginnote.dtx"))))
      (synopsis "Notes in the margin")
      (description "This package provides the command @code{\\marginnote} that
may be used instead of @code{\\marginpar} at almost every place where
@code{\\marginpar} cannot be used, e.g., inside floats, footnotes, or in
frames made with the @code{framed} package.")
      (license license:lppl1.3c+))))

(define-public texlive-iftex
  (package
    (name "texlive-iftex")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "/doc/generic/iftex/"
                   "/tex/generic/iftex/")
             (base32
              "147xa5kl4kjs05nj8v3kd7dpr5xkz3xp3gdvjih32ccd7527f5vp")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "http://www.ctan.org/pkg/iftex")
    (synopsis "Determine the currently used TeX engine")
    (description
     "This package, which works both for Plain TeX and for LaTeX, defines the
@code{\\ifPDFTeX}, @code{\\ifXeTeX}, and @code{\\ifLuaTeX} conditionals for
testing which engine is being used for typesetting.  The package also provides
the @code{\\RequirePDFTeX}, @code{\\RequireXeTeX}, and @code{\\RequireLuaTeX}
commands which throw an error if pdfTeX, XeTeX or LuaTeX (respectively) is not
the engine in use.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-generic-iftex texlive-iftex)

(define-deprecated-package texlive-generic-ifxetex texlive-iftex)

(define-public texlive-tabu
  (let ((template
         (simple-texlive-package
          "texlive-tabu"
          (list "doc/latex/tabu/"
                "source/latex/tabu/"
                "tex/latex/tabu/")
          (base32 "0mixyrqavipq4ni38z42x3579cdjbz54cp2qqb4q4yhfbl0a4pka"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/tabu")
         ((#:build-targets _ '())
          '(list "tabu.dtx"))))
      (propagated-inputs (list texlive-varwidth))
      (home-page "https://ctan.org/macros/latex/contrib/tabu")
      (synopsis "Flexible LaTeX tabulars")
      (description
       "The package provides an environment, tabu, which will make any sort of
tabular, and an environment longtabu which provides the facilities of tabu in
a modified longtable environment.  The package requires array, xcolor for
coloured rules in tables, and colortbl for coloured cells.  The longtabu
environment further requires that longtable be loaded.  The package itself
does not load any of these packages for the user.  The tabu environment may be
used in place of @code{tabular}, @code{tabular*} and @code{tabularx}
environments, as well as the @code{array} environment in maths mode.")
      (license license:lppl1.3+))))

(define-public texlive-xkeyval
  (package
    (name "texlive-xkeyval")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/xkeyval/"
                   "source/latex/xkeyval/"
                   "tex/generic/xkeyval/"
                   "tex/latex/xkeyval/")
             (base32
              "0hcfqxbi907yi9jwq61i638n8g9abf6zc0aazk2lxzshy44h3ms1")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     '(#:build-targets '("xkeyval.dtx")
       #:tex-format "latex"             ;won't build with luatex
       #:phases
       (modify-phases %standard-phases
         ;; This package cannot be built out of tree as it expects to find
         ;; built files in the working directory.
         (add-before 'build 'fix-build
           (lambda _
             (setenv "TEXINPUTS" (string-append (getcwd) "/build:"))
             (substitute* "source/latex/xkeyval/xkeyval.dtx"
               (("usepackage\\{xcolor\\}")
                "usepackage[dvips]{xcolor}")))))))
    (native-inputs
     (list (texlive-updmap.cfg
            (list texlive-ec
                  texlive-footmisc
                  texlive-fourier
                  texlive-graphics-def
                  texlive-iftex
                  texlive-listings
                  texlive-lm
                  texlive-pgf
                  texlive-pst-text
                  texlive-pstricks
                  texlive-url
                  texlive-xcolor))))
    (propagated-inputs
     (list texlive-tools))
    (home-page "https://ctan.org/pkg/xkeyval")
    (synopsis "Extension of the @code{keyval} package")
    (description
     "This package is an extension of the keyval package and offers additional
macros for setting keys and declaring and setting class or package options.
The package allows the programmer to specify a prefix to the name of the
macros it defines for keys, and to define families of key definitions; these
all help use in documents where several packages define their own sets of
keys.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-xkeyval texlive-xkeyval)

(define-public texlive-standalone
  (package
    (name "texlive-standalone")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/standalone/"
                   "source/latex/standalone/"
                   "tex/latex/standalone/"
                   "tex/plain/standalone/")
             (base32
              "00cs6bxpcpl8fjld280af52njkv44fm81yww9ynhqa9xp49q0p90")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (native-inputs
     (list texlive-ydoc))
    (propagated-inputs
     (list texlive-adjustbox
           texlive-currfile
           texlive-filemod
           texlive-gincltex
           texlive-iftex
           texlive-multido
           texlive-pdftexcmds
           texlive-pgf
           texlive-preview
           texlive-pstricks
           texlive-tools
           texlive-varwidth
           texlive-xkeyval))
    (home-page "https://ctan.org/pkg/standalone")
    (synopsis "Compile TeX pictures stand-alone or as part of a document")
    (description
     "This package provides a class and package is provided which allows TeX
pictures or other TeX code to be compiled standalone or as part of a main
document.  Special support for pictures with @code{beamer} overlays is also
provided.  The package is used in the main document and skips extra preambles
in sub-files.  The class may be used to simplify the preamble in sub-files.
By default the @code{preview} package is used to display the typeset code
without margins.")
    (license license:lppl1.3+)))

(define-public texlive-siunitx
  (package
    (name "texlive-siunitx")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "/source/latex/siunitx/siunitx.dtx"
                   "/doc/latex/siunitx/README.md")
             (base32
              "05kl7yid2npp2gbfshnv2xd08w81fkh5h2n5wd9xcpbhlqjzx9sj")))
    (build-system texlive-build-system)
    (arguments
     '(#:tex-directory "latex/siunitx"
       #:build-targets '("siunitx.dtx")))
    (propagated-inputs
     (list texlive-l3kernel texlive-l3packages))
    (home-page "http://www.ctan.org/pkg/siunitx")
    (synopsis "Comprehensive SI units package")
    (description
     "Typesetting values with units requires care to ensure that the combined
mathematical meaning of the value plus unit combination is clear.  In
particular, the SI units system lays down a consistent set of units with rules
on how they are to be used.  However, different countries and publishers have
differing conventions on the exact appearance of numbers (and units).  A
number of LaTeX packages have been developed to provide consistent application
of the various rules.  The @code{siunitx} package takes the best from the
existing packages, and adds new features and a consistent interface.  A number
of new ideas have been incorporated, to fill gaps in the existing provision.
The package also provides backward-compatibility with @code{SIunits},
@code{sistyle}, @code{unitsdef} and @code{units}.  The aim is to have one
package to handle all of the possible unit-related needs of LaTeX users.")
    (license license:lppl1.3c)))

(define-public texlive-booktabs
  (package
    (name "texlive-booktabs")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/booktabs/" "source/latex/booktabs/"
                   "tex/latex/booktabs/")
             (base32
              "0pv2kv4hgayqfcij2sz1jmk6kbxqccyaksz8xlw5kvqrbag9vxm3")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/booktabs")
    (synopsis "Publication quality tables in LaTeX")
    (description
     "This package enhances the quality of tables in LaTeX, providing extra
commands as well as behind-the-scenes optimisation.  Guidelines are given as
to what constitutes a good table in this context.  The package offers
@code{longtable} compatibility.")
    (license license:lppl1.3+)))

(define-public texlive-csquotes
  (package
    (name "texlive-csquotes")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/csquotes/"
                   "tex/latex/csquotes/")
             (base32
              "17y5mrmjmi7n0cgq4cnqr55f4bni6lx1pfdv5pzsmbrzha3mhbfg")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-etoolbox
           texlive-graphics
           texlive-relsize))
    (home-page "https://www.ctan.org/pkg/csquotes")
    (synopsis "Context sensitive quotation facilities")
    (description
     "This package provides advanced facilities for inline and display
quotations.  It is designed for a wide range of tasks ranging from the most
simple applications to the more complex demands of formal quotations.  The
facilities include commands, environments, and user-definable smart quotes
which dynamically adjust to their context.  Quotation marks are switched
automatically if quotations are nested and they can be adjusted to the current
language if the babel package is available.  There are additional facilities
designed to cope with the more specific demands of academic writing,
especially in the humanities and the social sciences.  All quote styles as
well as the optional active quotes are freely configurable.")
    (license license:lppl1.3c+)))

(define-public texlive-logreq
  (package
    (name "texlive-logreq")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/logreq/" "tex/latex/logreq/")
             (base32
              "13difccs3cxlkqlnhw286yb0c7mifrxfd402a2x5wwxv0m1kgfqd")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-etoolbox
           texlive-graphics))
    (home-page "https://ctan.org/pkg/logreq")
    (synopsis "Support for automation of the LaTeX workflow")
    (description
     "The package helps to automate a typical LaTeX workflow that involves
running LaTeX several times, running tools such as BibTeX or makeindex, and so
on.  It will log requests like ``please rerun LaTeX'' or ``please run BibTeX
on file X'' to an external XML file which lists all open tasks in
a machine-readable format.  Compiler scripts and integrated LaTeX editing
environments may parse this file to determine the next steps in the
workflow. In sum, the package will do two things: enable package authors to
use LaTeX commands to issue requests, collect all requests from all packages
and write them to an external XML file at the end of the document.")
    (license license:lppl1.3+)))

(define-public texlive-biblatex
  (package
    (name "texlive-biblatex")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "bibtex/bib/biblatex/biblatex/"
                   "bibtex/bst/biblatex/"
                   "doc/latex/biblatex/"
                   "tex/latex/biblatex/bbx/"
                   "tex/latex/biblatex/cbx/"
                   "tex/latex/biblatex/lbx/")
             (base32
              "1v3y2i7vng1qfs3p7ma2mf8lvvib422aagc3z6q2vwz6r3y4mr5k")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-etoolbox
           texlive-kvoptions
           texlive-logreq
           texlive-pdftexcmds
           texlive-url))
    (home-page "https://ctan.org/pkg/biblatex")
    (synopsis "Sophisticated Bibliographies in LaTeX")
    (description
     "BibLaTeX is a complete reimplementation of the bibliographic facilities
provided by LaTeX.  Formatting of the bibliography is entirely controlled by
LaTeX macros, and a working knowledge of LaTeX should be sufficient to design
new bibliography and citation styles.  BibLaTeX uses its own data backend
program called @code{biber} to read and process the bibliographic data.  With
@code{biber}, the range of features provided by BibLaTeX includes full Unicode
support, customisable bibliography labels, multiple bibliographies in the same
document, and subdivided bibliographies, such as bibliographies per chapter or
section.")
    (license license:lppl1.3+)))

(define-public texlive-biblatex-apa
  (package
    (name "texlive-biblatex-apa")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/biblatex-apa/"
                   "tex/latex/biblatex-apa/")
             (base32
              "0ivf7xbzj4xd57sqfbi87hbr73rraqifkzvx06yxgq0gmzz0x6wl")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/biblatex-apa")
    (synopsis "BibLaTeX citation and reference style for APA")
    (description
     "This is a fairly complete BibLaTeX style (citations and references) for
APA (American Psychological Association) publications.  It implements and
automates most of the guidelines in the APA 7th edition style guide for
citations and references.")
    (license license:lppl1.3c)))

(define-public texlive-todonotes
  (package
    (name "texlive-todonotes")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/todonotes/"
                   "source/latex/todonotes/"
                   "tex/latex/todonotes/")
             (base32
              "0lhqzrvf216j3rzg7lmc1mvnr2mzr0a6c2kqrfwzw6qbpm9v29nk")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-pgf
           texlive-tools
           texlive-xcolor
           texlive-xkeyval))
    (home-page "https://ctan.org/pkg/todonotes")
    (synopsis "Marking things to do in a LaTeX document")
    (description
     "The @code{todonotes} package lets the user mark things to do later, in
a simple and visually appealing way.  The package takes several options to
enable customization and finetuning of the visual appearance.")
    (license license:lppl1.3+)))

(define-public texlive-units
  (package
    (name "texlive-units")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/units/" "source/latex/units/"
                   "tex/latex/units/")
             (base32
              "1mrdsg55f40cvarrx84gbhrnsk8mlv915nll17lnfzfapgmvjsbl")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/units")
    (synopsis "Typeset physical units and fractions")
    (description "@code{units} is a package for typesetting physical units in
a standard-looking way.  The package is based upon @code{nicefrac}, a package
for typing fractions.  @code{nicefrac} is included in the @code{units}
bundle.")
    (license license:gpl3+)))

(define-public texlive-microtype
  (package
    (name "texlive-microtype")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/microtype/"
                   "source/latex/microtype/"
                   "tex/latex/microtype/")
             (base32
              "1r9w6za8g263n16pz0r5adrx5sazhfa78rdhjj9idnif12bgvpq2")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics))
    (home-page "https://ctan.org/pkg/microtype")
    (synopsis "Subliminal refinements towards typographical perfection")
    (description
     "The package provides a LaTeX interface to the micro-typographic
extensions that were introduced by pdfTeX and have since also propagated to
XeTeX and LuaTeX: most prominently, character protrusion and font expansion,
furthermore the adjustment of interword spacing and additional kerning, as
well as hyphenatable letterspacing (tracking) and the possibility to disable
all or selected ligatures.  These features may be applied to customisable sets
of fonts, and all micro-typographic aspects of the fonts can be configured in
a straight-forward and flexible way.  An alternative package
@code{letterspace}, which also works with plain TeX, is included in the
bundle.")
    (license license:lppl1.3c)))

(define-public texlive-minitoc
  (package
    (name "texlive-minitoc")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/minitoc/"
                   "tex/latex/minitoc/")
             (base32
              "0yd1na5b9m7z1j87a5fjwjqddfpiblfbpzcv0vlvql6lwh38mii7")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/minitoc")
    (synopsis "Produce a table of contents for each chapter, part or section")
    (description
     "The @code{minitoc} package allows you to add
mini-tables-of-contents (minitocs) at the beginning of every chapter, part or
section.  There is also provision for mini-lists of figures and of tables.  At
the part level, they are parttocs, partlofs and partlots.  If the type of
document does not use chapters, the basic provision is section level secttocs,
sectlofs and sectlots.  The package has provision for language-specific
configuration of its own fixed names, using @file{.mld} files.")
    (license license:lppl1.3+)))

(define-public texlive-minted
  (package
    (name "texlive-minted")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/minted/" "source/latex/minted/"
                   "tex/latex/minted/")
             (base32
              "13cjsjb3b04n9arwp46ayk8fcicylxq5g1864cpxl1lxjxh1yi0l")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list python-pygments
           texlive-etoolbox
           texlive-fancyvrb
           texlive-float
           texlive-framed
           texlive-fvextra
           texlive-graphics
           texlive-ifplatform
           texlive-kvoptions
           texlive-lineno
           texlive-newfloat
           texlive-pdftexcmds
           texlive-tools
           texlive-xstring))
    (home-page "https://ctan.org/pkg/minted")
    (synopsis "Highlighted source code for LaTeX")
    (description
     "The package that facilitates expressive syntax highlighting in LaTeX
using the powerful Pygments library.  The package also provides options to
customize the highlighted source code output using @code{fancyvrb}.")
    (license license:lppl1.3+)))

(define-public texlive-caption
  (package
    (name "texlive-caption")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/caption/" "source/latex/caption/"
                   "tex/latex/caption/")
             (base32
              "1fg3zfgi54zqx911wbqfb1y24d9ihm6wg59npng4clnqz45lla2i")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics))
    (home-page "https://ctan.org/pkg/caption")
    (synopsis "Customising captions in floating environments")
    (description
     "The @code{caption} package provides many ways to customise the captions
in floating environments like figure and table, and cooperates with many other
packages.  Facilities include rotating captions, sideways captions, continued
captions (for tables or figures that come in several parts).  A list of
compatibility notes, for other packages, is provided in the documentation.
The package also provides the caption outside float facility, in the same way
that simpler packages like capt-of do.")
    (license license:lppl1.3+)))

(define-public texlive-symbol
  (package
    (name "texlive-symbol")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "dvips/symbol/"
                   "fonts/afm/adobe/symbol/"
                   "fonts/afm/urw/symbol/"
                   "fonts/map/dvips/symbol/"
                   "fonts/tfm/adobe/symbol/"
                   "fonts/tfm/monotype/symbol/"
                   "fonts/tfm/urw35vf/symbol/"
                   "fonts/type1/urw/symbol/"
                   "tex/latex/symbol/")
             (base32
              "1pdkpr86bhia5hcmf7q3nhvklnsga4mqqrrirgl8a7al7x6q3ivs")))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/urw-base35")
    (synopsis "URW Base 35 font pack for LaTeX")
    (description
     "This package provides a set of fonts for use as drop-in replacements for
Adobe's basic set, comprising: Century Schoolbook (substituting for Adobe's
New Century Schoolbook); Dingbats (substituting for Adobe's Zapf Dingbats);
Nimbus Mono L (substituting for Abobe's Courier); Nimbus Roman No9
L (substituting for Adobe's Times); Nimbus Sans L (substituting for Adobe's
Helvetica); Standard Symbols L (substituting for Adobe's Symbol); URW Bookman;
URW Chancery L Medium Italic (substituting for Adobe's Zapf Chancery); URW
Gothic L Book (substituting for Adobe's Avant Garde); and URW Palladio
L (substituting for Adobe's Palatino).")
    (license license:gpl3+)))

(define-public texlive-mathpazo
  (package
    (name "texlive-mathpazo")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/mathpazo/"
                   "fonts/afm/public/mathpazo/"
                   "fonts/tfm/public/mathpazo/"
                   "fonts/type1/public/mathpazo/"
                   "fonts/vf/public/mathpazo/"
                   "source/latex/mathpazo/")
             (base32
              "0g10rjgg1kb78lgyxmwjrkgpy24yq3v0m47h6zhbc68rrmmawvwp")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs (list texlive-fpl texlive-palatino))
    (home-page "https://ctan.org/pkg/mathpazo")
    (synopsis "Fonts to typeset mathematics to match Palatino")
    (description "The Pazo Math fonts are a family of PostScript fonts
suitable for typesetting mathematics in combination with the Palatino family
of text fonts.  The Pazo Math family is made up of five fonts provided in
Adobe Type 1 format.  These contain glyphs that are usually not available in
Palatino and for which Computer Modern looks odd when combined with Palatino.
These glyphs include the uppercase Greek alphabet in upright and slanted
shapes, the lowercase Greek alphabet in slanted shape, several mathematical
glyphs and the uppercase letters commonly used to represent various number
sets.  LaTeX macro support is provided in package @code{psnfss}.")
    (license license:gpl3+)))

(define-public texlive-fp
  (package
    (name "texlive-fp")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/fp/" "tex/latex/fp/"
                   "tex/plain/fp/")
             (base32
              "1q555fx71cf88sn3npzb0j2i10ak920k0qc9ccdygz99vqg10dad")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/fp")
    (synopsis "Fixed point arithmetic")
    (description
     "This package provides an extensive collection of arithmetic operations
for fixed point real numbers of high precision.")
    (license license:lppl)))

(define-public texlive-fpl
  (package
    (name "texlive-fpl")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/fpl/" "fonts/afm/public/fpl/"
                   "fonts/type1/public/fpl/" "source/fonts/fpl/")
             (base32
              "02gkl516z9kn8xqs269pdkqn37sxm8ib0pcs43s4rs2rhyyl5z68")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/fpl")
    (synopsis "SC and OsF fonts for URW Palladio L")
    (description "The FPL Fonts provide a set of SC/OsF fonts for URW
Palladio L which are compatible with the Palatino SC/OsF fonts from
Adobe.  LaTeX use is enabled by the mathpazo package, which is part of
the @code{psnfss} distribution.")
    ;; Either LPPL version 1.0 or later, or GPL version 2
    (license (list license:lppl1.0+ license:gpl2))))

(define-public texlive-arev
  (package
    (name "texlive-arev")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/arev/"
                   "fonts/afm/public/arev/"
                   "fonts/enc/dvips/arev/"
                   "fonts/map/dvips/arev/"
                   "fonts/tfm/public/arev/"
                   "fonts/type1/public/arev/"
                   "fonts/vf/public/arev/"
                   "source/fonts/arev/"
                   "tex/latex/arev/")
             (base32
              "1a0zw9vc6z0shxvb4kdhfqdhwpzph5hm9v7klpchlisabvk421y1")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-amsfonts
           texlive-bera))
    (home-page "https://ctan.org/pkg/arev")
    (synopsis "Fonts and LaTeX support files for Arev Sans")
    (description
     "The @code{arev} package provides type 1 fonts, virtual fonts and LaTeX
packages for using Arev Sans in both text and mathematics.  Arev Sans is
a derivative of Bitstream Vera Sans, adding support for Greek and Cyrillic
characters and a few variant letters appropriate for mathematics.  The font is
primarily used in LaTeX for presentations, particularly when using a computer
projector.  Arev Sans has large x-height, open letters, wide spacing and thick
stems.  The style is very similar to the SliTeX font @code{lcmss} but heavier.
Arev is one of a very small number of sans-font mathematics support
packages.")
    (license (list license:silofl1.1    ;for Arev Sans
                   license:lppl1.3a     ;for TeX support files
                   license:gpl2))))     ;for ams-mdbch.sty

(define-public texlive-mathdesign
  (package
    (name "texlive-mathdesign")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/mathdesign/"
                   "dvips/mathdesign/"
                   "fonts/enc/dvips/mathdesign/"
                   "fonts/map/dvips/mathdesign/"
                   "fonts/tfm/public/mathdesign/mdbch/"
                   "fonts/tfm/public/mathdesign/mdgreek/"
                   "fonts/tfm/public/mathdesign/mdici/"
                   "fonts/tfm/public/mathdesign/mdpgd/"
                   "fonts/tfm/public/mathdesign/mdpus/"
                   "fonts/tfm/public/mathdesign/mdput/"
                   "fonts/tfm/public/mathdesign/mdugm/"
                   "fonts/type1/public/mathdesign/mdbch/"
                   "fonts/type1/public/mathdesign/mdici/"
                   "fonts/type1/public/mathdesign/mdpgd/"
                   "fonts/type1/public/mathdesign/mdpus/"
                   "fonts/type1/public/mathdesign/mdput/"
                   "fonts/type1/public/mathdesign/mdugm/"
                   "fonts/vf/public/mathdesign/mdbch/"
                   "fonts/vf/public/mathdesign/mdgreek/"
                   "fonts/vf/public/mathdesign/mdici/"
                   "fonts/vf/public/mathdesign/mdpgd/"
                   "fonts/vf/public/mathdesign/mdpus/"
                   "fonts/vf/public/mathdesign/mdput/"
                   "fonts/vf/public/mathdesign/mdugm/"
                   "tex/latex/mathdesign/")
             (base32
              "0jcby2sd0l3ank2drxc0qcf5d1cwa8idzh4g91h4nxk8zrzxj8nr")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics
           texlive-xkeyval))
    (home-page "https://ctan.org/pkg/mathdesign")
    (synopsis "Mathematical fonts to fit with particular text fonts")
    (description
     "The Math Design project offers mathematical fonts that match with
existing text fonts.  To date, three free font families are available: Adobe
Utopia, URW Garamond and Bitstream Charter.  Mathdesign covers the whole LaTeX
glyph set including AMS symbols.  Both roman and bold versions of these
symbols can be used.  Moreover, there is a choice between three greek
fonts (two of them created by the Greek Font Society).")
    (license license:gpl3+)))

(define-public texlive-bera
  (package
    (name "texlive-bera")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/bera/"
                   "fonts/afm/public/bera/"
                   "fonts/map/dvips/bera/"
                   "fonts/tfm/public/bera/"
                   "fonts/type1/public/bera/"
                   "fonts/vf/public/bera/"
                   "tex/latex/bera/")
             (base32
              "1pkmhhr6ah44xhipjr7nianv03hr4w4bn45xcvp264yw6ymqzqwr")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics))
    (home-page "https://ctan.org/pkg/bera")
    (synopsis "Bera fonts")
    (description "The @code{bera} package contains the Bera Type 1 fonts and
files to use the fonts with LaTeX.  Bera is a set of three font families: Bera
Serif (a slab-serif Roman), Bera Sans (a Frutiger descendant) and Bera
Mono (monospaced/typewriter).  The Bera family is a repackaging, for use with
TeX, of the Bitstream Vera family.")
    (license license:silofl1.1)))

(define-public texlive-fourier
  (package
    (name "texlive-fourier")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/fourier/"
                   "fonts/afm/public/fourier/"
                   "fonts/map/dvips/fourier/"
                   "fonts/opentype/public/fourier/"
                   "fonts/tfm/public/fourier/"
                   "fonts/type1/public/fourier/"
                   "fonts/vf/public/fourier/"
                   "tex/latex/fourier/")
             (base32
              "038h02n02fii0kv021d5z8ic2p0mqnjzwxdbvcfym4gkcw345fxk")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-fontspec
           texlive-iftex))
    (home-page "https://ctan.org/pkg/fourier")
    (synopsis "Using Utopia fonts for LaTeX documents")
    (description
     "Fourier-GUTenberg is a LaTeX typesetting system which uses Adobe Utopia
as its standard base font.  Fourier-GUTenberg provides all complementary
typefaces needed to allow Utopia based TeX typesetting, including an extensive
mathematics set and several other symbols.  The system is absolutely
stand-alone: apart from Utopia and Fourier, no other typefaces are required.
Utopia is a registered trademark of Adobe Systems Incorporated")
    (license license:lppl)))

(define-public texlive-utopia
  (package
    (name "texlive-utopia")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/utopia/" "fonts/afm/adobe/utopia/"
                   "fonts/tfm/adobe/utopia/"
                   "fonts/type1/adobe/utopia/"
                   "fonts/vf/adobe/utopia/")
             (base32
              "113wgkfz4z0ls2grxxfj17l42a1yv9r5ipcd0156xnfsrqvqzxfc")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/utopia")
    (synopsis "Adobe Utopia fonts")
    (description
     "The Adobe Standard Encoding set of the Utopia font family, as
contributed by the X Consortium.  The set comprises upright and italic shapes
in medium and bold weights.  Macro support and matching maths fonts are
provided by the @code{fourier} and the @code{mathdesign} font packages.")
    (license (license:fsf-free
              "http://mirrors.ctan.org/fonts/utopia/README"))))

(define-public texlive-fontaxes
  (package
    (name "texlive-fontaxes")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/fontaxes/" "source/latex/fontaxes/"
                   "tex/latex/fontaxes/")
             (base32
              "1d9ji2qvjf1ky8l6rfqbag2hw61r0hyjxkzsp18s4pckyq4dqwdm")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/fontaxes")
    (synopsis "Additional font axes for LaTeX")
    (description "The @code{fontaxes} package adds several new font axes on
top of LaTeX's New Font Selection Scheme (NFSS).  In particular, it splits the
shape axis into a primary and a secondary shape axis and it adds three new
axes to deal with the different figure versions offered by many professional
fonts.")
    (license license:lppl1.3+)))

(define-public texlive-preprint
  (package
    (name "texlive-preprint")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/preprint/" "source/latex/preprint/"
                   "tex/latex/preprint/")
             (base32
              "198xwg6mll3yndc1kf79l6zgnq3nsk7fsh3rlj28nipd26ysw6lq")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/preprint")
    (synopsis "Bundle of modules for preprints")
    (description "The bundle comprises: @code{authblk}, which permits
footnote style author/affiliation input in the @command{\\author} command,
@code{balance}, to balance the end of @command{\\twocolumn} pages,
@code{figcaps}, to send figure captions, etc., to end document,
@code{fullpage}, to set narrow page margins and set a fixed page style, and
@code{sublabel}, which permits counters to be subnumbered.")
    (license license:lppl1.3+)))

(define-public texlive-mweights
  (package
    (name "texlive-mweights")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/mweights/" "tex/latex/mweights/")
             (base32
              "12493g3yz06mhiybnphqbp49fjzy36clzw63b74mkfhsg1pq7h1b")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/mweights")
    (synopsis "Support for multiple-weight font packages")
    (description
     "Many font families available for use with LaTeX are available at
multiple weights.  Many Type 1-oriented support packages for such fonts
re-define the standard @code{\\mddefault} or @code{\\bfdefault} macros.  This
can create difficulties if the weight desired for one font family isn't
available for another font family, or if it differs from the weight desired
for another font family.  The package provides a solution to these
difficulties.")
    (license license:lppl)))

(define-public texlive-cabin
  (package
    (name "texlive-cabin")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/cabin/"
                   "fonts/enc/dvips/cabin/"
                   "fonts/map/dvips/cabin/"
                   "fonts/opentype/impallari/cabin/"
                   "fonts/tfm/impallari/cabin/"
                   "fonts/type1/impallari/cabin/"
                   "fonts/vf/impallari/cabin/"
                   "tex/latex/cabin/")
             (base32
              "1gqqqbj7i18fs1ss5n3axd821hzq5kbv1dl7dqxp4gba619f1rli")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-fontaxes
           texlive-fontspec
           texlive-iftex
           texlive-mweights
           texlive-xkeyval))
    (home-page "https://ctan.org/pkg/cabin")
    (synopsis "Humanist Sans Serif font with LaTeX support")
    (description
     "Cabin is a humanist sans with four weights and true italics and small
capitals.  According to the designer, Pablo Impallari, Cabin was inspired by
Edward Johnston's and Eric Gill's typefaces, with a touch of modernism.  Cabin
incorporates modern proportions, optical adjustments, and some elements of the
geometric sans.  @file{cabin.sty} supports use of the font under LaTeX,
pdfLaTeX, XeLaTeX and LuaLaTeX; it uses the @code{mweights}, to manage the
user's view of all those font weights.  An option is provided to enable Cabin
as the default text font.")
    (license (list license:silofl1.1    ;for Cabin
                   license:lppl))))     ;for support files

(define-public texlive-newtx
  (package
    (name "texlive-newtx")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "/doc/fonts/newtx/"
                   "/fonts/afm/public/newtx/"
                   "/fonts/enc/dvips/newtx/"
                   "/fonts/map/dvips/newtx/"
                   "/fonts/opentype/public/newtx/"
                   "/fonts/tfm/public/newtx/"
                   "/fonts/type1/public/newtx/"
                   "/fonts/vf/public/newtx/"
                   "/tex/latex/newtx/")
             (base32
              "0h0wm3cd0wxag5x7vy3vgr42jd8m6ffkl90pnkvqdxzbnfdjv3l6")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-amsmath
           texlive-carlisle
           texlive-etextools
           texlive-etoolbox
           texlive-fontaxes
           texlive-iftex
           texlive-oberdiek
           texlive-trimspaces
           texlive-xkeyval
           texlive-xstring))
    (home-page "https://www.ctan.org/pkg/newtx")
    (synopsis "Repackaging of the TX fonts with improved metrics")
    (description
     "The @code{newtx} bundle splits @file{txfonts.sty} (from the TX fonts
distribution) into two independent packages, @code{newtxtext.sty} and
@code{newtxmath.sty}, each with fixes and enhancements.  @code{newtxmath}'s
metrics have been re-evaluated to provide a less tight appearance and to
provide a @code{libertine} option that substitutes Libertine italic and Greek
letters for the existing math italic and Greek glyphs, making a mathematics
package that matches Libertine text quite well.")
    (license license:lppl1.3)))

(define-public texlive-xcharter
  (package
    (name "texlive-xcharter")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/xcharter/"
                   "fonts/afm/public/xcharter/"
                   "fonts/enc/dvips/xcharter/"
                   "fonts/map/dvips/xcharter/"
                   "fonts/opentype/public/xcharter/"
                   "fonts/tfm/public/xcharter/"
                   "fonts/type1/public/xcharter/"
                   "fonts/vf/public/xcharter/"
                   "tex/latex/xcharter/")
             (base32
              "0d8rvcmvxrlxqqxpirxqbhmiijpsz5y4vvldh1jnc018aannjlhm")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-carlisle
           texlive-etoolbox
           texlive-fontaxes
           texlive-xstring
           texlive-xkeyval))
    (home-page "https://ctan.org/pkg/xcharter")
    (synopsis "Extension of Bitstream Charter fonts")
    (description "@code{xcharter} repackages Bitstream Charter with an
extended set of features.  The extension provides small caps, oldstyle
figures and superior figures in all four styles, accompanied by LaTeX
font support files.  The fonts themselves are provided in both Adobe
Type 1 and OTF formats, with supporting files as necessary.")
    (license (list (license:fsf-free
                    "http://mirrors.ctan.org/fonts/xcharter/README")
                   license:lppl1.3))))

(define-public texlive-ly1
  (package
    (name "texlive-ly1")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/ly1/"
                   "fonts/enc/dvips/ly1/"
                   "fonts/map/dvips/ly1/"
                   "fonts/tfm/adobe/ly1/"
                   "fonts/vf/adobe/ly1/"
                   "tex/latex/ly1/"
                   "tex/plain/ly1/")
             (base32
              "1lks902rr94m3n3r4rc2lm4vvqhqv9prgrpni5ww64rqrv56h8yy")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/ly1")
    (synopsis "Support for LY1 LaTeX encoding")
    (description
     "The legacy @code{texnansi} (TeX and ANSI) encoding is known in the LaTeX
scheme of things as @emph{LY1} encoding.  The @code{ly1} bundle includes
metrics and LaTeX macros to use the three basic Adobe Type 1 fonts (Times,
Helvetica and Courier) in LaTeX using LY1 encoding.")
    (license license:lppl1.0+)))

(define-public texlive-sectsty
  (let ((template (simple-texlive-package
                   "texlive-sectsty"
                   (list "/doc/latex/sectsty/"
                         "/source/latex/sectsty/")
                   (base32
                    "08m90j7cg6w46vnwgsp10clpj4l6c9a6l8dad20q3mnd32l84hbl"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/sectsty")
         ((#:build-targets _ '())
          ''("sectsty.ins"))
         ((#:tex-format _ "latex") "latex")))
      (home-page "https://www.ctan.org/pkg/sectsty")
      (synopsis "Control sectional headers")
      (description "This is a LaTeX2ε package to help change the style of any or
all of LaTeX's sectional headers in the article, book, or report classes.
Examples include the addition of rules above or below a section title.")
      (license license:lppl1.2+))))

(define-public texlive-morefloats
  (let ((template (simple-texlive-package
                   "texlive-morefloats"
                   (list "/doc/latex/morefloats/"
                         "/source/latex/morefloats/")
                   (base32
                    "0n0405fjxyjlbjspzfvhl0wjkwiqicj3hk8fa0g7agw72wlxscpl"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/morefloats")
         ((#:build-targets _ '())
          ''("morefloats.ins"))))
      (home-page "https://www.ctan.org/pkg/morefloats")
      (synopsis "Increase the number of simultaneous LaTeX floats")
      (description "LaTeX can, by default, only cope with 18 outstanding floats;
any more, and you get the error “too many unprocessed floats”.  This package
releases the limit; TeX itself imposes limits (which are independent of the
help offered by e-TeX).

However, if your floats can’t be placed anywhere, extending the number of
floats merely delays the arrival of the inevitable error message.")
      (license license:lppl1.3c+))))

(define-public texlive-ifmtarg
  (package
    (name "texlive-ifmtarg")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/ifmtarg/" "source/latex/ifmtarg/"
                   "tex/latex/ifmtarg/")
             (base32
              "19bfi12j5ra19k6vjd1q5fjsm68vipa7ida7pg9pf15l5pxwbgqz")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list #:tex-format "latex"))
    (native-inputs
     (list texlive-filecontents))
    (home-page "https://ctan.org/pkg/ifmtarg")
    (synopsis "If-then-else command for processing potentially empty arguments")
    (description
     "This package provides a command for the LaTeX programmer for testing
whether an argument is empty.")
    (license license:lppl1.3c+)))

(define-public texlive-pagenote
  (let ((template (simple-texlive-package
                   "texlive-pagenote"
                   (list "/doc/latex/pagenote/"
                         "/source/latex/pagenote/")
                   (base32
                    "0cqfqrfvnzq7ldaf255hcvi8xsfx8h7iha3hs8p9gdi3cfzbcmjm"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/pagenote")
         ((#:build-targets _ '())
          ''("pagenote.ins"))))
      (propagated-inputs
       (list texlive-ifmtarg))
      (home-page "https://www.ctan.org/pkg/pagenote")
      (synopsis "Notes at end of document")
      (description "The pagenote package provides tagged notes on a separate
page (also known as ‘end notes’).")
      (license license:lppl1.3c+))))

(define-public texlive-titling
  (let ((template (simple-texlive-package
                   "texlive-titling"
                   (list "/doc/latex/titling/"
                         "/source/latex/titling/")
                   (base32
                    "0pc3806kc9p2dizdghis0p0b00xs0gmlh2nmf94f5wasz5mkw6bk"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "latex/titling")
         ((#:build-targets _ '())
          ''("titling.ins"))
         ((#:tex-format _ "latex") "latex")))
      (native-inputs
       (list texlive-cm))
      (home-page "https://www.ctan.org/pkg/titling")
      (synopsis "Control typesetting of the \\maketitle command")
      (description "The @code{titling} package provides control over the
typesetting of the @code{\\maketitle} command and @code{\\thanks} commands,
and makes the \title, @code{\\author} and @code{\\date} information
permanently available.  Multiple titles are allowed in a single document.  New
titling elements can be added and a @code{titlepage} title can be centered on
a physical page.")
      (license license:lppl))))

(define-public texlive-ifoddpage
  (package
    (name "texlive-ifoddpage")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/ifoddpage/"
                   "source/latex/ifoddpage/"
                   "tex/latex/ifoddpage/")
             (base32
              "06xn3dwf6aa8j3lmvvgwfadw2ahw770jx91x8nyl8zir58aiys5s")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (native-inputs
     (list texlive-ydoc))
    (home-page "https://ctan.org/pkg/ifoddpage")
    (synopsis "Determine if the current page is odd or even")
    (description
     "This package provides an @code{\\ifoddpage} conditional to determine if
the current page is odd or even.  The macro @code{\\checkoddpage} must be used
directly before to check the page number using a label.  Two compiler runs are
therefore required to achieve correct results.  In addition, the conditional
@code{\\ifoddpageoronside} is provided which is also true in @code{oneside}
mode where all pages use the odd page layout.")
    (license license:lppl1.3)))

(define-public texlive-storebox
  (package
    (name "texlive-storebox")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/storebox/" "source/latex/storebox/"
                   "tex/latex/storebox/")
             (base32
              "1vbjq9aq2kbncq1dn4rk7jspfb6kcxk66h49z0xz1qix5yg94gmx")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (native-inputs
     (list texlive-ydoc))
    (propagated-inputs
     (list texlive-collectbox
           texlive-iftex))
    (home-page "https://ctan.org/pkg/storebox")
    (synopsis "Storing information for reuse")
    (description
     "The package provides store boxes whose user interface matches that of
normal LaTeX save boxes, except that the content of a store box appears at
most once in the output PDF file, however often it is used.  The present
version of the package supports pdfLaTeX and LuaLaTeX; when DVI is output,
store boxes behave the same as save boxes.")
    (license license:lppl1.3+)))

(define-public texlive-collectbox
  (package
    (name "texlive-collectbox")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/collectbox/"
                   "source/latex/collectbox/"
                   "tex/latex/collectbox/")
             (base32
              "106k01lgnvikndk48r5ms9xj3gmynv2xy20090frr7sa3g9k42za")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (native-inputs
     (list texlive-ydoc))
    (home-page "https://ctan.org/pkg/collectbox")
    (synopsis "Collect and process macro arguments as boxes")
    (description
     "The package provides macros to collect and process a macro
argument (i.e., something which looks like a macro argument) as a horizontal
box rather than as a real macro argument.  The \"arguments\" are stored as if
they had been saved by @code{\\savebox} or by the @code{lrbox} environment.
Grouping tokens @code{\\bgroup} and @code{\\egroup} may be used, which allows
the user to have the beginning and end of a group in different macro
invocations, or to place them in the begin and end code of an environment.
Arguments may contain verbatim material or other special use of characters.
The macros were designed for use within other macros.")
    (license license:lppl1.3)))

(define-public texlive-grfext
  (let ((template (simple-texlive-package
                   "texlive-grfext"
                   (list "doc/latex/grfext/"
                         "source/latex/grfext/"
                         "tex/latex/grfext/")
                   (base32
                    "1x35r10mkjg8dzx7aj99y4dwyf69jgs41qwapdx523lbglywmgxp"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t)
          "latex/grfext")
         ((#:build-targets _ #t)
          #~(list "grfext.dtx"))))
      (home-page "https://github.com/ho-tex/grfext")
      (synopsis "Manipulate the graphics package's list of extensions")
      (description "This package provides macros for adding to, and reordering
the list of graphics file extensions recognised by package graphics.")
      (license license:lppl1.3c+))))

(define-public texlive-adjustbox
  (package
    (name "texlive-adjustbox")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/adjustbox/"
                   "source/latex/adjustbox/"
                   "tex/latex/adjustbox/")
             (base32
              "01r6cb8aadbgsfcqhqnwaig3xwzgr0nfxci3mzb8ln3k4dghmq97")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (native-inputs
     (list texlive-ydoc))
    (propagated-inputs
     (list texlive-collectbox
           texlive-graphics
           texlive-ifoddpage
           texlive-pgf
           texlive-storebox
           texlive-tools
           texlive-varwidth
           texlive-xkeyval))
    (home-page "https://ctan.org/pkg/adjustbox")
    (synopsis "Graphics package-alike macros for general boxes")
    (description "The package provides several macros to adjust boxed
content.  One purpose is to supplement the standard @code{graphics} package,
which defines the macros @code{\\resizebox}, @code{\\scalebox} and
@code{\\rotatebox} , with the macros @code{\\trimbox} and @code{\\clipbox}.
The main feature is the general @code{\\adjustbox} macro which extends the
@code{key=value} interface of @code{\\includegraphics} from the
@code{graphics} package and applies it to general text content.  Additional
provided box macros are @code{\\lapbox}, @code{\\marginbox},
@code{\\minsizebox}, @code{\\maxsizebox} and @code{\\phantombox}.")
    (license license:lppl1.3+)))

(define-public texlive-qrcode
  (package
    (inherit (simple-texlive-package
              "texlive-qrcode"
              (list "doc/latex/qrcode/README"
                    "source/latex/qrcode/qrcode.dtx"
                    "source/latex/qrcode/qrcode.ins")
              (base32
               "1xfv0imrrbxjqwjapcf2silg19rwz2jinawy1x65c1krg919vn02")))
    (outputs '("out" "doc"))
    (arguments
     (list
      #:tex-directory "latex/qrcode"))
    (propagated-inputs
     (list texlive-lm
           texlive-xcolor
           texlive-xkeyval))
    (native-inputs
     (list (texlive-updmap.cfg (list texlive-lm texlive-zapfding))
           texlive-hyperref
           texlive-stringenc
           texlive-xcolor
           texlive-xkeyval))
    (home-page "https://www.ctan.org/pkg/qrcode")
    (synopsis "QR codes without external tools")
    (description "This package creates @acronym{QR,Quick Response} codes for
LaTeX documents without depending on external graphics packages.  It supports
generating codes of different sizes and with different error correction
levels.  All functionality is provided by the single @code{\\qrcode} command.")
    (license license:lppl1.3c+)))

(define-public texlive-tcolorbox
  (package
    (name "texlive-tcolorbox")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/tcolorbox/" "tex/latex/tcolorbox/")
             (base32
              "1qnsbblkadzdn1fx2k21xnlwcb35pg9xya24chkm66jmidi22qp0")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-amsmath
           texlive-environ
           texlive-etoolbox
           texlive-hyperref
           texlive-incgraph
           texlive-iftex
           texlive-l3packages
           texlive-listings
           texlive-listingsutf8
           texlive-marvosym
           texlive-minted
           texlive-oberdiek             ;for pdfcol
           texlive-pdftexcmds
           texlive-pgf
           texlive-psnfss
           texlive-refcount
           texlive-tools))
    (home-page "https://ctan.org/pkg/tcolorbox")
    (synopsis "Coloured boxes, for LaTeX examples and theorems, etc")
    (description
     "This package provides an environment for coloured and framed text boxes
with a heading line.  Optionally, such a box may be split in an upper and
a lower part; thus the package may be used for the setting of LaTeX examples
where one part of the box displays the source code and the other part shows
the output.  Another common use case is the setting of theorems.  The package
supports saving and reuse of source code and text parts.")
    (license license:lppl1.3c+)))

(define-public texlive-ebproof
  (package
    (name "texlive-ebproof")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/ebproof/" "source/latex/ebproof/"
                   "tex/latex/ebproof/")
             (base32
              "1a3203jgxsgihfgb6wwm0gfpaxbf1lg5axcakan9rj316xrrj4lc")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-l3kernel))
    (home-page "https://ctan.org/pkg/ebproof")
    (synopsis "Formal proofs in the style of sequent calculus")
    (description
     "This package provides commands to typeset proof trees in the style of
sequent calculus and related systems.  The commands allow for writing
inferences with any number of premises and alignment of successive formulas on
an arbitrary point.  Various options allow complete control over spacing,
styles of inference rules, placement of labels, etc.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-ebproof texlive-ebproof)

(define-public texlive-bussproofs
  (package
    (name "texlive-bussproofs")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/bussproofs/"
                   "tex/latex/bussproofs/")
             (base32
              "1gb8y9g89fqw1kix4d2vb7mj440vlb8hnpsa3jqpk9yicndwcyk6")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/bussproofs")
    (synopsis "Proof trees in the style of the sequent calculus")
    (description
     "This package provides commands to typeset proof trees in the style of
sequent calculus and related systems.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-bussproofs texlive-bussproofs)

(define-public texlive-euenc
  (package
    (name "texlive-euenc")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/euenc/" "source/latex/euenc/"
                   "tex/latex/euenc/")
             (base32
              "0vhqxhj1v68rhi08xivps8icxmlcq9mv8slqmsmf2qhvzj6x6qx3")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     ;; Sole ".dtx" file bundled only generates documentation.
     (list #:build-targets #~(list)))
    (home-page "https://ctan.org/pkg/euenc")
    (synopsis "Unicode font encoding definitions for XeTeX")
    (description
     "The package provides font encoding definitions for unicode fonts loaded
by LaTeX in XeTeX or LuaTeX.  The package provides two encodings: EU1,
designed for use with XeTeX, which the fontspec uses for unicode fonts which
require no macro-level processing for accents, and EU2, which provides the
same facilities for use with LuaTeX.  Neither encoding places any restriction
on the glyphs provided by a font; use of EU2 causes the package
@code{euxunicode} to be loaded (the package is part of this distribution).
The package includes font definition files for use with the Latin Modern
OpenType fonts.")
    (license license:lppl1.3+)))

(define-public texlive-eurosym
  (package
    (name "texlive-eurosym")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/eurosym/"
                   "fonts/map/dvips/eurosym/"
                   "fonts/source/public/eurosym/"
                   "fonts/tfm/public/eurosym/"
                   "fonts/type1/public/eurosym/"
                   "tex/latex/eurosym/")
             (base32
              "0ml24rxbl1yir4s3fjjxm0z7axklc3p33syg41b76zc7hck9mk8s")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:modules
      '((guix build texlive-build-system)
        (guix build utils)
        (srfi srfi-1)
        (srfi srfi-26))
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'install 're-generate-fonts-metrics
            (lambda _
              (let ((mf #$(this-package-native-input "texlive-metafont"))
                    (cm #$(this-package-native-input "texlive-cm"))
                    (root (getcwd)))
                (mkdir-p "build")
                (with-directory-excursion "fonts/source/public/eurosym"
                  ;; Tell mf where to find mf.base.
                  (setenv "MFBASES"
                          (string-append mf "/share/texmf-dist/web2c"))
                  ;; Tell mf where to look for source files.
                  (setenv "MFINPUTS"
                          (string-append
                           (getcwd) ":"
                           mf "/share/texmf-dist/metafont/base:"
                           cm "/share/texmf-dist/fonts/source/public/cm"))
                  ;; Build font metrics (tfm).
                  (for-each (lambda (font)
                              (format #t "building font ~a\n" font)
                              (invoke "mf" "-progname=mf"
                                      (string-append "-output-directory="
                                                     root "/build")
                                      (string-append "\\"
                                                     "mode:=ljfour; "
                                                     "mag:=1; "
                                                     "batchmode; "
                                                     "input "
                                                     (basename font ".mf"))))
                            (find-files "." "[0-9]+\\.mf$")))
                ;; Install font metrics at the appropriate location.
                (for-each
                 (cut install-file <> "fonts/tfm/public/eurosym")
                 (find-files "build/" "\\.tfm$"))))))))
    (native-inputs
     (list texlive-bin texlive-cm texlive-metafont))
    (home-page "https://ctan.org/pkg/eurosym")
    (synopsis "METAFONT and macros for Euro sign")
    (description
     "The European currency symbol for the Euro implemented in METAFONT, using
the official European Commission dimensions, and providing several
shapes (normal, slanted, bold, outline).  The package also includes a LaTeX
package which defines the macro, pre-compiled @file{tfm} files, and
documentation.")
    (license (license:non-copyleft "file:///doc/fonts/eurosym/COPYING"))))

(define-public texlive-kastrup
  (package
    (name "texlive-kastrup")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/generic/kastrup/"
                   "source/generic/kastrup/"
                   "tex/generic/kastrup/")
             (base32
              "0sbf4xw1jsh9pbjhqw3f0bg067f0rhf936wfnqpzj9kp2167n41j")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/binhex")
    (synopsis "Convert numbers into binary, octal and hexadecimal")
    (description
     "The @code{kastrup} package provides the @emph{binhex.tex} file.  This
file provides expandable macros for both fixed-width and minimum-width numbers
to bases 2, 4, 8 and 16.  All constructs TeX accepts as arguments to its
@code{\\number} primitive are valid as arguments for the macros.  The package
may be used under LaTeX and plain TeX.")
    (license (license:fsf-free "file:/binhex.dtx"))))

(define-public texlive-translations
  (package
    (name "texlive-translations")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
              (list "doc/latex/translations/"
                    "tex/latex/translations/")
              (base32
               "0vl7ckpbkjvz3a5snzppb96ncwgmhpwb2p6cg30grfyn421kap3v")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-etoolbox
           texlive-pdftexcmds))
    (home-page "https://ctan.org/pkg/translations")
    (synopsis "Internationalisation of LaTeX2e packages")
    (description
     ;; Polish not mentioned on CTAN, but there is a
     ;; translations-basic-dictionary-polish.trsl file.
     "This package (once part of the @code{exsheets} package), provides a
framework for providing multilingual features to a LaTeX package.  The package
has its own basic dictionaries for English, Brazilian, Catalan, Dutch, French,
German, Polish and Spanish.  It aims to use translation material for English,
Dutch, French, German, Italian, Spanish, Catalan, Turkish, Croatian, Hungarian,
Danish and Portuguese from babel or polyglossia if either is in use in the
document.")
    (license license:lppl1.3c+)))

(define-deprecated-package texlive-latex-translations texlive-translations)

(define-public texlive-translator
  (package
    (name "texlive-translator")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/translator/"
                   "tex/latex/translator/")
             (base32
              "13rxdqhvgwc5lz2wsw4jwsb92614wlxsa90rmzxyrc6xjz1jypnk")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics))
    (home-page "https://ctan.org/pkg/translator")
    (synopsis "Easy translation of strings in LaTeX")
    (description
     "This LaTeX package provides a flexible mechanism for translating
individual words into different languages.  Such a translation mechanism is
useful when the author of some package would like to localize the package such
that texts are correctly translated into the language preferred by the user.
This package is not intended to be used to automatically translate more than
a few words.")
    (license (list license:lppl license:gpl1+))))

(define-public texlive-textpos
  (package
    (name "texlive-textpos")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/textpos/" "source/latex/textpos/"
                   "tex/latex/textpos/")
             (base32
              "0gg6b2ckafj8fbrlw85m538c08qyq2cv5z59r9pzcwg1c1xdyn02")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-everyshi
           texlive-graphics))
    (home-page "https://ctan.org/pkg/textpos")
    (synopsis "Place boxes at arbitrary positions on the LaTeX page")
    (description
     "This package provides a package to facilitate placement of boxes at
absolute positions on the LaTeX page.  There are several reasons why this
might be useful, an important one being to help the creation of large-format
conference posters.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-textpos texlive-textpos)

(define-public texlive-unicode-math
  (package
    (inherit (simple-texlive-package
              "texlive-unicode-math"
              (list "source/latex/unicode-math/"
                    "doc/latex/unicode-math/"
                    "tex/latex/unicode-math/unicode-math-table.tex")
              (base32 "1j3041dcm7wqj0x26rxm9bb7q4xa1rqsqynqdb6cbjk3jmfvskxn")))
    (outputs '("out" "doc"))
    (arguments
     (list
      #:tex-directory "latex/unicode-math"
      #:tex-format "xelatex"
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'copy-files
            ;; The documentation isn't built.
            (lambda* (#:key outputs tex-directory #:allow-other-keys)
              (let ((doc (assoc-ref outputs "doc"))
                    (tex (string-append #$output "/share/texmf-dist/tex/"
                                        tex-directory)))
                ;; Install documentation.
                (mkdir-p (string-append doc "/share/texmf-dist/doc" ))
                (copy-recursively "doc" doc)
                ;; Install unicode-math-table.tex, which is not
                ;; built.
                (install-file "tex/latex/unicode-math/unicode-math-table.tex"
                              tex)))))))
    (home-page "https://ctan.org/pkg/unicode-math")
    (synopsis "Unicode mathematics support for XeTeX and LuaTeX")
    (description "This package will provide a complete implementation of
Unicode maths for XeLaTeX and LuaLaTeX.  Unicode maths is currently supported
by the following fonts:
@itemize
@item Latin Modern Math
@item TeX Gyre Bonum Math
@item TeX Gyre Pagella Math
@item TeX Gyre Schola Math
@item TeX Gyre Termes Math
@item DejaVu Math TeX Gyre
@item Asana-Math
@item STIX
@item XITS Math
@item Libertinus Math
@item Fira Math
@end itemize")
    (license license:lppl1.3c+)))

(define-public texlive-xifthen
  (package
    (name "texlive-xifthen")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/xifthen/" "tex/latex/xifthen/")
             (base32
              "0b33mlmnxsj5mi06v2w2zgamk51mgv1lxdr1cax8nkpn9g7n9axw")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-ifmtarg
           texlive-tools))
    (home-page "https://ctan.org/pkg/xifthen")
    (synopsis "Extended conditional commands")
    (description
     "This package extends the @code{ifthen} package by implementing new
commands to go within the first argument of @code{\\\\ifthenelse}: to test
whether a string is void or not, if a command is defined or equivalent to
another.  The package also enables use of complex expressions as introduced by
the package @code{calc}, together with the ability of defining new commands to
handle complex tests.")
    (license license:lppl)))

(define-public texlive-xindy
  (package
    (name "texlive-xindy")
    (version "2.5.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://ctan/indexing/xindy/base/xindy-"
                                  version ".tar.gz"))
              (sha256
               (base32
                "0hxsx4zw19kmixkmrln17sxgg1ln4pfp4lpfn5v5fyr1nwfyk3ic"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:configure-flags #~(list "--enable-docs")
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'patch-clisp
            (lambda* (#:key inputs #:allow-other-keys)
              ;; The xindy.in file is encoded in ISO-8859-1 (or iso-latin-1).
              (with-fluids ((%default-port-encoding "ISO-8859-1"))
                (substitute* "user-commands/xindy.in"
                  (("(our \\$clisp = ).*" _ head)
                   (format #f "our $clisp = ~s;~%"
                           (search-input-file inputs "bin/clisp"))))))))))
    (native-inputs (list clisp
                         glibc-locales
                         perl
                         texlive-bin
                         texlive-greek-fontenc
                         texlive-hyperref
                         texlive-latex-base
                         texlive-cyrillic
                         texlive-geometry
                         (texlive-updmap.cfg ;fonts
                          (list texlive-cbfonts
                                texlive-lh
                                texlive-jknappen))))
    (inputs (list clisp perl))          ;used at run time
    (home-page "https://www.ctan.org/pkg/xindy")
    (synopsis "General-purpose index processor")
    (description "Xindy was developed after an impasse had been encountered in
the attempt to complete internationalisation of @command{makeindex}.  Xindy
can be used to process indexes for documents marked up using (La)TeX, Nroff
family and SGML-based languages.  Xindy is highly configurable, both in markup
terms and in terms of the collating order of the text being processed.")
    (license license:gpl2+)))

(define-public texlive-nth
  (package
    (name "texlive-nth")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "tex/generic/nth/")
             (base32
              "0716sd99xjdkplm7jdmg4lx8lpfnnx6mxjp1l1sp2bfqcg73p4hm")))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/nth")
    (synopsis "Generate English ordinal numbers")
    (description
     "The command @code{\\nth{<number>}} generates English ordinal numbers of
the form 1st, 2nd, 3rd, 4th, etc.  LaTeX package options may specify that the
ordinal mark be superscripted, and that negative numbers may be treated; Plain
TeX users have no access to package options, so need to redefine macros for
these changes.")
    (license license:public-domain)))

(define-public texlive-ntheorem
  (package
    (name "texlive-ntheorem")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/ntheorem/" "source/latex/ntheorem/"
                   "tex/latex/ntheorem/")
             (base32
              "16xain8s0azcnhwj5xwh3m365sb9bhdvxanh19kvmnc52dggjc1y")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-amsfonts))
    (home-page "https://ctan.org/pkg/ntheorem")
    (synopsis "Enhanced theorem environment")
    (description
     "The package offers enhancements for theorem-like environments: easier
control of layout; proper placement of endmarks even when the environment ends
with @code{\\end@{enumerate@}} or @code{\\end@{displaymath@}} (including
support for @code{amsmath} displayed-equation environments); and support for
making a list of theorems, analagous to @code{\\listoffigures}.")
    (license license:lppl)))

(define-public texlive-fmtcount
  (package
    (name "texlive-fmtcount")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/fmtcount/" "scripts/fmtcount/"
                   "source/latex/fmtcount/" "tex/latex/fmtcount/")
             (base32
              "1biw0g6s2arq6kq52c1yfkl0vzafja2az65c3d0syq0vgjzj9763")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-amsmath
           texlive-etoolbox
           texlive-graphics
           texlive-xkeyval))
    (home-page "https://ctan.org/pkg/fmtcount")
    (synopsis "Display the value of a LaTeX counter in a variety of formats")
    (description
     "The package provides commands that display the value of a LaTeX counter
in a variety of formats (ordinal, text, hexadecimal, decimal, octal, binary
etc).  The package offers some multilingual support; configurations for use in
English (both British and American usage), French (including Belgian and Swiss
variants), German, Italian, Portuguese and Spanish documents are provided.")
    (license license:lppl1.3+)))

(define-public texlive-inriafonts
  (package
    (name "texlive-inriafonts")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/fonts/inriafonts/"
                   "fonts/enc/dvips/inriafonts/"
                   "fonts/map/dvips/inriafonts/"
                   "fonts/opentype/public/inriafonts/"
                   "fonts/tfm/public/inriafonts/"
                   "fonts/truetype/public/inriafonts/"
                   "fonts/type1/public/inriafonts/"
                   "fonts/vf/public/inriafonts/"
                   "tex/latex/inriafonts/")
             (base32
              "0ngbpr4pl7r82jmdhiksp32qvbvggf2nawwqq0pkb7cffp95ya49")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-fontaxes
           texlive-ly1                  ;requires LY1 font encoding
           texlive-mweights
           texlive-xkeyval))
    (home-page "https://ctan.org/pkg/inriafonts")
    (synopsis "Inria fonts with LaTeX support")
    (description
     "Inria is a free font designed by Black[Foundry] for Inria, a French
research institute.  It comes as Serif and Sans Serif, each with three weights
and matching italics.  Using these fonts with XeLaTeX and LuaLaTeX is easy
using the @code{fontspec} package.  The present package provides a way of
using them with LaTeX and pdfLaTeX: it provides two style files,
@file{InriaSerif.sty} and @file{InriaSans.sty}, together with the PostScript
version of the fonts and their associated files.")
    (license (list license:lppl license:silofl1.1))))

(define-public texlive-floatflt
  (package
    (name "texlive-floatflt")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/floatflt/" "source/latex/floatflt/"
                   "tex/latex/floatflt/")
             (base32
              "1piy8ajbbcadsjwp0mhlgxm2ggggnb5sn75arfs5fxiaqrwd572j")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list #:tex-format "latex"))
    (home-page "https://ctan.org/pkg/floatflt")
    (synopsis "Wrap text around floats")
    (description
     "The package can float text around figures and tables which do not span
the full width of a page; it improves upon floatfig, and allows tables/figures
to be set left/right or alternating on even/odd pages.")
    (license license:lppl1.3+)))

(define-public texlive-fvextra
  (let ((template (simple-texlive-package
                   "texlive-fvextra"
                   (list "/doc/latex/fvextra/"
                         "/source/latex/fvextra/"
                         "/tex/latex/fvextra/")
                   (base32
                    "0nawx1fh55yhqspy5jgss2qmwpqmikfrg7628smk931rph9nq0aa"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t)
          "latex/fvextra")))
      (home-page "https://ctan.org/macros/latex/contrib/fvextra")
      (synopsis "Extensions and patches for fancyvrb")
      (description
       "This package provides several extensions to fancyvrb, including
automatic line breaking and improved math mode.  It also patches some fancyvrb
internals.")
      (license license:lppl1.3+))))

(define-public bibtool
  (package
    (name "bibtool")
    (version "2.68")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/ge-ne/bibtool")
         (commit (string-append
                  "BibTool_"
                  (string-map (lambda (c) (if (char=? c #\.) #\_ c))
                              version)))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0grnmqj8w5018nd7r6drnq2yvfhf22gj9i3rj8ilhzm7zmz3zn0g"))))
    (build-system gnu-build-system)
    (arguments
     `(#:test-target "test"))
    (native-inputs
     (list perl))
    (home-page "http://www.gerd-neugebauer.de/software/TeX/BibTool/en")
    (synopsis "Tool for manipulating BibTeX databases")
    (description
     "BibTool manipulates BibTeX files.  The possibilities of BibTool include
sorting and merging of BibTeX databases, generation of uniform reference keys,
and selecting references used in a publication.")
    (license license:gpl2+)))

(define-public texlive-apa6
  (package
    (name "texlive-apa6")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/apa6/" "source/latex/apa6/"
                   "tex/latex/apa6/")
             (base32
              "08jn8piyaad4zln33c0gikyhdkcsk2s3ms9l992riq2hbpbm9lcf")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'fix-build
            ;; Build process wants to generate files in the wrong directory.
            (lambda _
              (substitute* "source/latex/apa6/apa6.ins"
                (("file\\{\\./.*?/") "file{")))))))
    (propagated-inputs
     (list texlive-apacite
           texlive-babel
           texlive-biblatex
           texlive-booktabs
           texlive-caption
           texlive-draftwatermark
           texlive-endnotes
           texlive-etoolbox
           texlive-fancyhdr
           texlive-float
           texlive-geometry
           texlive-graphics
           texlive-lm
           texlive-substr
           texlive-threeparttable
           texlive-times
           texlive-tools
           texlive-xstring))
    (home-page "https://ctan.org/pkg/apa6")
    (synopsis "Format documents in APA style (6th edition)")
    (description
     "The class formats documents in APA style (6th Edition).  It provides
a full set of facilities in three different output modes (journal-like
appearance, double-spaced manuscript, LaTeX-like document).  The class can
mask author identity for copies for use in masked peer review.")
    (license license:lppl1.3c+)))

(define-public texlive-apacite
  (package
    (name "texlive-apacite")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "bibtex/bst/apacite/" "doc/bibtex/apacite/"
                   "source/bibtex/apacite/" "tex/latex/apacite/")
             (base32
              "0nc86zngk71xpbinrfm8p0413xphc0v86ddhcw94gi2sl00hsmzq")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-natbib
           texlive-tools))
    (home-page "https://ctan.org/pkg/apacite")
    (synopsis "Citation style following the rules of the APA")
    (description
     "Apacite provides a BibTeX style and a LaTeX package which are designed
to match the requirements of the American Psychological Association's style
for citations.  The package follows the 6th edition of the APA manual, and is
designed to work with the @code{apa6} class.")
    (license license:lppl)))

(define-public texlive-endfloat
  (package
    (name "texlive-endfloat")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/endfloat/" "source/latex/endfloat/"
                   "tex/latex/endfloat/")
             (base32
              "1zslmc5g28z6adfyd8bdlbw03jawxmgafq0mgwy811hrbcppb2kg")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics))
    (home-page "https://ctan.org/pkg/endfloat")
    (synopsis "Move floats to the end, leaving markers where they belong")
    (description
     "The @code{endfloat} package places all floats on pages by themselves at
the end of the document, optionally leaving markers in the text near to where
the figure (or table) would normally have occurred.")
    (license license:gpl3+)))

(define-public texlive-was
  (package
    (name "texlive-was")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/was/" "source/latex/was/"
                   "tex/latex/was/")
             (base32
              "1fp0l9sn9yrhf8hz175dzc2x28byk1ygfirn23am5ak72csmi0cp")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/was")
    (synopsis "Collection of small packages by Walter Schmidt")
    (description
     "This package provides a bundle of packages that arise in the author's
area of interest: compliance of maths typesetting with ISO standards; symbols
that work in both maths and text modes commas for both decimal separator and
maths; and upright Greek letters in maths.")
    (license license:lppl1.2+)))

(define-public texlive-xpatch
  (package
    (name "texlive-xpatch")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/xpatch/" "source/latex/xpatch/"
                   "tex/latex/xpatch/")
             (base32
              "0r08hadnwx9vyppzmbn1bj69b12i5fw1mhk49piw2rqbk01722zk")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-etoolbox
           texlive-l3kernel
           texlive-l3packages))
    (home-page "https://ctan.org/pkg/xpatch")
    (synopsis "Extending @code{etoolbox} patching commands")
    (description
     "The package generalises the macro patching commands provided by Philipp
Lehmann's @code{etoolbox}.")
    (license license:lppl1.3c+)))

(define-public texlive-threeparttablex
  (package
    (name "texlive-threeparttablex")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/threeparttablex/"
                   "tex/latex/threeparttablex/")
             (base32
              "19pvw2ifswxcf8dxw0mzjmqhl592477w5hcfh97f4wpya0dv2m9p")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-environ
           texlive-threeparttable))
    (home-page "https://ctan.org/pkg/threeparttablex")
    (synopsis "Notes in @code{longtables}")
    (description
     "The package provides the functionality of the @code{threeparttable}
package to tables created using the @code{longtable} package.")
    (license license:lppl1.3+)))

(define-public texlive-lineno
  (package
    (name "texlive-lineno")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/lineno/" "source/latex/lineno/"
                   "tex/latex/lineno/")
             (base32
              "1xf8ljgcj411yqmng89wc49rqfz19j95yqqpnb35dj3qc1chvm2a")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-tools))
    (home-page "https://ctan.org/pkg/lineno")
    (synopsis "Line numbers on paragraphs")
    (description
     "The @code{lineno} package adds line numbers to selected paragraphs with
reference possible through the LaTeX @code{\\ref} and @code{\\pageref} cross
reference mechanism.  Line numbering may be extended to footnote lines, using
the @code{fnlineno} package.")
    (license license:lppl1.3a+)))

(define-public texlive-babel-czech
  (let ((template (simple-texlive-package
                   "texlive-babel-czech"
                   (list "/source/generic/babel-czech/")
                   (base32
                    "1274pzgdya7gkvxjmdm3v5rb7hc0sj6mqn9pd8y9418yx5449spg"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/babel-czech")
         ((#:build-targets _ '())
          ''("czech.ins"))))
      (home-page "https://www.ctan.org/pkg/babel-czech")
      (synopsis "Babel support for Czech")
      (description
       "This package provides the language definition file for support of
Czech in @code{babel}.  Some shortcuts are defined, as well as translations to
Czech of standard ``LaTeX names''.")
      (license license:lppl1.3+))))

(define-public texlive-babel-dutch
  (let ((template (simple-texlive-package
                   "texlive-babel-dutch"
                   (list "/source/generic/babel-dutch/")
                   (base32
                    "1a40rz6rznawgarnhk0wh751sln2x9js4420i0758y2clf4rlhg9"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/babel-dutch")
         ((#:build-targets _ '())
          ''("dutch.ins"))))
      (home-page "https://www.ctan.org/pkg/babel-dutch")
      (synopsis "Babel support for Dutch")
      (description
       "This package provides the language definition file for support of Dutch
in @code{babel}.  It provides all the necessary macros, definitions and
settings to typeset Dutch documents.")
      (license license:lppl1.3c+))))

(define-public texlive-babel-finnish
  (let ((template (simple-texlive-package
                   "texlive-babel-finnish"
                   (list "/source/generic/babel-finnish/")
                   (base32
                    "1930zxk4l6k5q4wcbvpvijv4s0gxp2mkxvblczn4gcbar10vfd4x"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/babel-finnish")
         ((#:build-targets _ '())
          ''("finnish.ins"))))
      (home-page "https://www.ctan.org/pkg/babel-finnish")
      (synopsis "Babel support for Finnish")
      (description
       "This package provides the language definition file for support of
Finnish in @code{babel}.  It provides all the necessary macros, definitions and
settings to typeset Finnish documents.")
      (license license:lppl1.3c+))))

(define-public texlive-babel-norsk
  (package
    (name "texlive-babel-norsk")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/generic/babel-norsk/"
                   "source/generic/babel-norsk/"
                   "tex/generic/babel-norsk/")
             (base32
              "1zsssgcdllhjk7r58k4rv8bh59nmj091syqj45chvp1i667ndryp")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/babel-norsk")
    (synopsis "Babel support for Norwegian")
    (description
     "The package provides the language definition file for support of
Norwegian in Babel.  Some shortcuts are defined, as well as translations to
Norsk of standard LaTeX names.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-generic-babel-norsk texlive-babel-norsk)

(define-public texlive-babel-danish
  (let ((template (simple-texlive-package
                   "texlive-babel-danish"
                   (list "/source/generic/babel-danish/")
                   (base32
                    "00dryb078fqckqjnxa2riq478j6d5i28j5cclv4bw7dn5naa3lz7"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/babel-danish")
         ((#:build-targets _ '())
          ''("danish.ins"))))
      (home-page "https://www.ctan.org/pkg/babel-danish")
      (synopsis "Babel support for Danish")
      (description
       "This package provides the language definition file for support of
Danish in @code{babel}.  It provides all the necessary macros, definitions and
settings to typeset Danish documents.")
      (license license:lppl1.3c+))))

(define-public texlive-babel-polish
  (let ((template (simple-texlive-package
                   "texlive-babel-polish"
                   (list "/source/generic/babel-polish/")
                   (base32
                    "1jymxl98mwxmq0yq90mhrr7bq7c613rh1rnhl7l3bih36af55rwr"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ '())
          "generic/babel-polish")
         ((#:build-targets _ '())
          ''("polish.ins"))))
      (home-page "https://www.ctan.org/pkg/babel-polish")
      (synopsis "Babel support for Polish")
      (description
       "This package provides the language definition file for support of
Polish in @code{babel}.  Some shortcuts are defined, as well as translations to
Polish of standard ``LaTeX names''.")
      (license license:lppl1.3+))))

(define-public texlive-mdframed
  (package
    (name "texlive-mdframed")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/mdframed/" "source/latex/mdframed/"
                   "tex/latex/mdframed/")
             (base32
              "1i5rm946wg43rjckxlfhx79zfx5cgd3bxk71206hd1dqkrgpdpa8")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-amsmath
           texlive-booktabs
           texlive-csquotes
           texlive-eso-pic
           texlive-etoolbox
           texlive-iftex
           texlive-geometry
           texlive-graphics
           texlive-kantlipsum
           texlive-kvoptions
           texlive-l3kernel
           texlive-l3packages
           texlive-lipsum
           texlive-listings
           texlive-microtype
           texlive-needspace
           texlive-ntheorem
           texlive-oberdiek
           texlive-pgf
           texlive-selinput
           texlive-tools
           texlive-xcolor
           texlive-zref))
    (home-page "https://ctan.org/pkg/mdframed")
    (synopsis "Framed environments that can split at page boundaries")
    (description
     "The @code{mdframed} package develops the facilities of @code{framed} in
providing breakable framed and coloured boxes.  The user may instruct the
package to perform its operations using default LaTeX commands, PStricks or
TikZ.")
    (license license:lppl)))

(define-public texlive-setspace
  (package
    (name "texlive-setspace")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/setspace/" "tex/latex/setspace/")
             (base32
              "00ik8qgkw3ivh3z827zjf7gbwkbsmdcmv22c6ap543mpgaqqjcfm")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/setspace")
    (synopsis "Set space between lines")
    (description
     "The @code{setspace} package provides support for setting the spacing
between lines in a document.  Package options include @code{singlespacing},
@code{onehalfspacing}, and @code{doublespacing}.  Alternatively the spacing
can be changed as required with the @code{\\singlespacing},
@code{\\onehalfspacing}, and @code{\\doublespacing} commands.  Other size
spacings also available.")
    (license license:lppl1.3+)))

(define-public texlive-pgfgantt
  (package
    (name "texlive-pgfgantt")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/pgfgantt/" "source/latex/pgfgantt/"
                   "tex/latex/pgfgantt/")
             (base32
              "0bm034iizk4sd7p5x7vkj7v57dc0bf2lswpsb32s4qlg4s7h6jqz")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs (list texlive-pgf))
    (home-page "https://ctan.org/pkg/pgfgantt")
    (synopsis "Draw Gantt charts with TikZ")
    (description
     "The @code{pgfgantt} package provides an environment for drawing Gantt charts
that contain various elements (titles, bars, milestones, groups and links).
Several keys customize the appearance of the chart elements.")
    (license license:lppl1.3+)))

(define-public texlive-pdflscape
  (package
    (name "texlive-pdflscape")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/pdflscape/"
                   "source/latex/pdflscape/"
                   "tex/latex/pdflscape/")
             (base32
              "05vvmwd8vlzs2x2rm6pfzlvrrihqf924d7krlrkvc6giiwyfsic4")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-atbegshi
           texlive-graphics
           texlive-iftex))
    (home-page "https://ctan.org/pkg/pdflscape")
    (synopsis "Make landscape pages display as landscape")
    (description
     "The @code{pdflscape} package adds PDF support to the @code{landscape}
environment of package @code{lscape}, by setting the PDF @code{/Rotate} page
attribute.  Pages with this attribute will be displayed in landscape
orientation by conforming PDF viewers.")
    (license license:lppl1.3+)))

(define-public texlive-datetime2
  (package
    (name "texlive-datetime2")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/datetime2/"
                   "source/latex/datetime2/"
                   "tex/latex/datetime2/")
             (base32
              "0yjkpfic1ni4j2g61rrjj5hjyd43shc9c0sg1aivbbsmqh30dn33")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-etoolbox
           texlive-pgf
           texlive-tracklang
           texlive-xkeyval))
    (home-page "https://ctan.org/pkg/datetime2")
    (synopsis "Formats for dates, times and time zones")
    (description
     "The @code{datetime2} package provides commands for formatting dates,
times and time zones and redefines @code{\\today} to use the same formatting
style.  In addition to @code{\\today}, you can also use
@code{\\DTMcurrenttime} (current time) or @code{\\DTMnow} (current date and
time).  Dates and times can be saved for later use.  The accompanying
@code{datetime2-calc} package can be used to convert date-times to UTC+00:00.
Language and regional support is provided by independently maintained and
installed modules.  The @code{datetime2-calc} package uses the
@code{pgfcalendar} package (part of the PGF/TikZ bundle).  This package
replaces @code{datetime.sty}, which is now obsolete.")
    (license license:lppl1.3+)))

(define-public texlive-tracklang
(package
  (name "texlive-tracklang")
  (version (number->string %texlive-revision))
  (source (texlive-origin
           name version
           (list "doc/generic/tracklang/"
                 "source/latex/tracklang/"
                 "tex/generic/tracklang/"
                 "tex/latex/tracklang/")
           (base32
            "1386sg25y6zb4ixvrbdv6n1gp54h18mjd984bnwwqda6jafxx4zr")))
  (outputs '("out" "doc"))
  (build-system texlive-build-system)
  (home-page "https://ctan.org/pkg/tracklang")
  (synopsis "Language and dialect tracker")
  (description
   "The @code{tracklang} package is provided for package developers who want
a simple interface to find out which languages the user has requested through
packages such as @code{babel} or @code{polyglossia}.  This package does not
provide any translations!  Its purpose is simply to track which languages have
been requested by the user.  Generic TeX code is in @file{tracklang.tex} for
non-LaTeX users.")
  (license license:lppl1.3+)))

(define-public texlive-ltablex
  (package
    (name "texlive-ltablex")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/ltablex/" "tex/latex/ltablex/")
             (base32
              "14lmgj820j6zwj1xnd6ad38kzb9w132kp7sp55cv5bk9vhx3621w")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-tools))
    (home-page "https://ctan.org/pkg/ltablex")
    (synopsis "Table package extensions")
    (description
     "The @code{ltablex} package modifies the @code{tabularx} environment to
combine the features of the @code{tabularx} package (auto-sized columns in
a fixed-width table) with those of the @code{longtable} package (multi-page
tables).")
    (license license:lppl)))

(define-public texlive-ragged2e
  (package
    (name "texlive-ragged2e")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/ragged2e/" "source/latex/ragged2e/"
                   "tex/latex/ragged2e/")
             (base32
              "1cxj5jdgvr3xk1inrb3yzpm3l386jjawgpqiwsz53k6yshb6yfml")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list #:tex-format "latex"))
    (propagated-inputs
     (list texlive-everysel
           texlive-footmisc))
    (home-page "https://ctan.org/pkg/ragged2e")
    (synopsis "Alternative versions of ragged-type commands")
    (description
     "The @code{ragged2e} package defines new commands @code{\\Centering},
@code{\\RaggedLeft}, and @code{\\RaggedRight} and new environments
@code{Center}, @code{FlushLeft}, and @code{FlushRight}, which set ragged text
and are easily configurable to allow hyphenation (the corresponding commands
in LaTeX, all of whose names are lower-case, prevent hyphenation
altogether).")
    (license license:lppl1.3c)))

(define-public texlive-refstyle
  (package
    (name "texlive-refstyle")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/refstyle/" "source/latex/refstyle/"
                   "tex/latex/refstyle/")
             (base32
              "0ckfm04kfi67babpn3m99nqj4b9r1fs0ivq5m7yz90mz4lqykhbs")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-graphics))
    (home-page "https://ctan.org/pkg/refstyle")
    (synopsis "Advanced formatting of cross references")
    (description
     "The package provides a consistent way of producing references throughout
a project.  Enough flexibility is provided to make local changes to a single
reference.  The user can configure their own setup.  The package offers
a direct interface to varioref (for use, for example, in large projects such
as a series of books, or a multivolume thesis written as a series of
documents), and name references from the nameref package may be incorporated
with ease.  For large projects such as a series of books or a multi volume
thesis, written as freestanding documents, a facility is provided to interface
to the @code{xr} package for external document references.")
    (license license:lppl)))

(define-public texlive-relsize
  (package
    (name "texlive-relsize")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/relsize/" "tex/latex/relsize/")
             (base32
              "07g9wqxsh3a9rmfbppaqhyic82a1i1habizaf4hpdi3246w6nnby")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/relsize")
    (synopsis "Set the font size relative to the current font size")
    (description
     "The basic command of the package is @code{\\relsize}, whose argument is
a number of @code{\\magsteps} to change size; from this are defined commands
@code{\\larger}, @code{\\smaller}, @code{\\textlarger}, etc.")
    (license license:public-domain)))

(define-public texlive-everypage
  (package
    (name "texlive-everypage")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/everypage/"
                   "source/latex/everypage/"
                   "tex/latex/everypage/")
             (base32
              "1kw7n7az823sc8gjrd4gjkkak1780yn76zswlnwapxmvl62pv9xk")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/everypage")
    (synopsis "Provide hooks to be run on every page of a document")
    (description
     "The package provides hooks to perform actions on every page, or on the
current page.  Specifically, actions are performed after the page is composed,
but before it is shipped, so they can be used to prepare the output page in
tasks like putting watermarks in the background, or in setting the next page
layout, etc.")
    (license license:lppl1.3c)))

(define-public texlive-everysel
  (package
    (name "texlive-everysel")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/everysel/" "source/latex/everysel/"
                   "tex/latex/everysel/")
             (base32
              "0skzm2qsk5vpjxgslclp4pvbbcrrnm1w3df8xfvfq252dyd7w8s5")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list #:tex-format "latex"))
    (home-page "https://ctan.org/pkg/everysel")
    (synopsis "Provides hooks into @code{\\selectfont}")
    (description
     "The @code{everysel} package provided hooks whose arguments are executed
just after LaTeX has loaded a new font by means of @code{\\selectfont}.  It
has become obsolete with LaTeX versions 2021/01/05 or newer, since LaTeX now
provides its own hooks to fulfill this task.  For newer versions of LaTeX
@code{everysel} only provides macros using LaTeX's hook management due to
compatibility reasons.")
    (license license:lppl1.3c)))

(define-public texlive-everyshi
  (package
    (name "texlive-everyshi")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/everyshi/" "source/latex/everyshi/"
                   "tex/latex/everyshi/")
             (base32
              "11y6xazv1nk0m2hzsainjr8ijn5cff04xfccm6a65hzg7ipggraj")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (arguments
     (list #:tex-format "latex"))
    (home-page "https://ctan.org/pkg/everyshi")
    (synopsis "Take action at every @code{\\shipout}")
    (description
     "The @code{everyshi} package provides hooks into @code{\\sshipout} called
@code{\\EveryShipout} and @code{\\AtNextShipout} analogous to
@code{\\AtBeginDocument}.  With the introduction of the LaTeX hook management
this package became obsolete in 2020 and is only provided for backwards
compatibility.  For current versions of LaTeX it is only mapping the hooks to
the original @code{everyshi} macros.  In case you use an older LaTeX format,
@code{everyshi} will automatically fall back to its old implementation by
loading @code{everyshi-2001-05-15}.")
    (license license:lppl1.3c)))

(define-public texlive-abstract
  (let ((template (simple-texlive-package
                   "texlive-abstract"
                   '("doc/latex/abstract/"
                     "source/latex/abstract/"
                     "tex/latex/abstract/")
                   (base32
                    "1axm78qgrpml09pkh252g1hsjx9c2w7mbdrm9rdl4yqh5ppwq4y9"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #f)
          "latex/abstract")
         ((#:build-targets _ #t)
          #~(list "abstract.ins"))))
      (home-page "https://ctan.org/pkg/abstract")
      (synopsis "Control the typesetting of the abstract environment")
      (description "The abstract package gives you control over the typesetting
of the abstract environment, and in particular provides for a one column
abstract in a two column paper.")
      (license license:lppl))))

(define-public texlive-breqn
  (let ((template (simple-texlive-package
                   "texlive-breqn"
                   '("/doc/latex/breqn/"
                     "/source/latex/breqn/")
                   (base32
                    "186cypxiyf30fq6dxvvlbwn5yx7c8d4cd243wvvb3243n5l4rpl3"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #f)
          "latex/breqn")
         ((#:build-targets _ #t)
          #~(list "breqnbundle.ins"))))
      (home-page "https://wspr.io/breqn/")
      (synopsis "Automatic line breaking of displayed equations")
      (description "This package provides solutions to a number of common
difficulties in writing displayed equations and getting high-quality output.
The single most ambitious goal of the package is to support automatic
linebreaking of displayed equations.  Such linebreaking cannot be done without
substantial changes under the hood in the way formulae are processed; the code
must be watched carefully, keeping an eye on possible glitches.  The bundle
also contains the @code{flexisym} and @code{mathstyle} packages, which are
both designated as support for @code{breqn}.")
      (license license:lppl1.3+))))

(define-public texlive-breakurl
  (package
    (name "texlive-breakurl")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/breakurl/" "source/latex/breakurl/"
                   "tex/latex/breakurl/")
             (base32
              "1lihfrihf1i300sddz09rsn6gj30g299warn88gli9hbrfy6nvw5")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-iftex texlive-xkeyval))
    (home-page "https://ctan.org/pkg/breakurl")
    (synopsis "Line-breakable links in @code{hyperref} for dvips/ps2pdf")
    (description
     "This package provides a command much like @code{hyperref}'s @code{\\url}
that typesets a URL using a typewriter-like font.  However, if the dvips
driver is being used, the original @code{\\url} doesn't allow line breaks in
the middle of the created link: the link comes in one atomic piece.  This
package allows such line breaks in the generated links.")
    (license license:lppl)))

(define-public texlive-comment
  (package
    (name "texlive-comment")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/comment/" "tex/latex/comment/")
             (base32
              "1c1mqziwxyf1bqzpw6ji65n7ypygm3lyknblxmf0c70w0ivw76pa")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/comment")
    (synopsis "Selectively include/exclude portions of text")
    (description "This package provides environments for selectively including
or excluding pieces of text, allowing the user to define new, separately
controlled comment versions.")
    (license license:gpl2+)))

(define-public texlive-datatool
  (let ((template (simple-texlive-package
                   "texlive-datatool"
                   '("/bibtex/bst/datatool/"
                     "/doc/latex/datatool/"
                     "/source/latex/datatool/")
                   (base32
                    "0hh2623zlwgq8zb2lv4d8yfaqwzrz54dqhc1xk0jd1k4fp281kl5"))))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #f)
          "latex/datatool")
         ((#:build-targets _ #t)
          #~(list "datatool.ins"))))
      (home-page "https://ctan.org/pkg/datatool")
      (synopsis "Tools to load and manipulate data")
      (description "This package provides tools to create databases using LaTeX
commands or by importing external files.  Databases may be sorted, filtered,
and visualized using several kinds of configurable plots.  Particular support
is provided for mail merging, indexing, creating glossaries, manipulating
bibliographies, and displaying personal pronouns.")
      (license license:lppl1.3+))))

(define-public texlive-physics
  (package
    (name "texlive-physics")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/physics/" "tex/latex/physics/")
             (base32
              "1wy58wwcv1pv18xs1n71abnm73dqnxqijxvhfxk0rcmvbc6wvwrb")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-amsmath
           texlive-l3packages))
    (home-page "https://ctan.org/pkg/physics")
    (synopsis "Macros supporting the Mathematics of Physics")
    (description
     "The package defines simple and flexible macros for typesetting equations
in the languages of vector calculus and linear algebra, using Dirac
notation.")
    (license license:lppl)))

(define-public texlive-sourcesanspro
  (package
    (name "texlive-sourcesanspro")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/sourcesanspro/"
                   "fonts/enc/dvips/sourcesanspro/"
                   "fonts/map/dvips/sourcesanspro/"
                   "fonts/opentype/adobe/sourcesanspro/"
                   ;; ^ It would be tempting to use our
                   ;; font-adobe-source-sans-pro for these, but the version in
                   ;; texlive could differ from our version: probably the
                   ;; difference would be small, but debugging would not be
                   ;; fun.  If the files are really identical, Guix will
                   ;; hard-link them anyway.
                   "fonts/tfm/adobe/sourcesanspro/"
                   "fonts/type1/adobe/sourcesanspro/"
                   "fonts/vf/adobe/sourcesanspro/"
                   "tex/latex/sourcesanspro/")
             (base32
              "18z7ln8dyh0sp6v0vdvc6qqxnpg3h3ix0f5magjcjbpay54kl0i3")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-fontaxes
           texlive-iftex
           texlive-mweights
           texlive-xkeyval))
    (home-page "https://ctan.org/pkg/sourcesanspro")
    (synopsis "Use Source Sans Pro with TeX(-alike) systems")
    (description
     "This package provides the Source Sans Pro font family from Adobe in both
Adobe Type 1 and OpenType formats, plus macros supporting the use of the fonts
in LaTeX (Type 1) and XeLaTeX/LuaLaTeX (OTF).")
    (license (list license:lppl1.3+ license:silofl1.1))))

(define-public texlive-sourceserifpro
  (package
    (name "texlive-sourceserifpro")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/sourceserifpro/"
                   "fonts/enc/dvips/sourceserifpro/"
                   "fonts/map/dvips/sourceserifpro/"
                   "fonts/opentype/adobe/sourceserifpro/"
                   ;; ^ See comment in `texlive-sourcesanspro'.
                   "fonts/tfm/adobe/sourceserifpro/"
                   "fonts/type1/adobe/sourceserifpro/"
                   "fonts/vf/adobe/sourceserifpro/"
                   "tex/latex/sourceserifpro/")
             (base32
              "18xxncg8ybv86r46zq5mvgkrfnvlhx93n55fy8nkk8vdmminrh8w")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-fontaxes
           texlive-iftex
           texlive-mweights
           texlive-xkeyval))
    (home-page "https://ctan.org/pkg/sourceserifpro")
    (synopsis "Use Source Serif Pro with TeX(-alike) systems")
    (description
     "This package provides the Source Serif Pro font family from Adobe in
both Adobe Type 1 and OpenType formats, plus macros supporting the use of the
fonts in LaTeX (Type 1) and XeLaTeX/LuaLaTeX (OTF).")
    (license (list license:lppl1.3+ license:silofl1.1))))

(define-public texlive-sourcecodepro
  (package
    (name "texlive-sourcecodepro")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/sourcecodepro/"
                   "fonts/enc/dvips/sourcecodepro/"
                   "fonts/map/dvips/sourcecodepro/"
                   "fonts/opentype/adobe/sourcecodepro/"
                   ;; ^ See comment in `texlive-sourcesanspro'.
                   "fonts/tfm/adobe/sourcecodepro/"
                   "fonts/type1/adobe/sourcecodepro/"
                   "fonts/vf/adobe/sourcecodepro/"
                   "tex/latex/sourcecodepro/")
             (base32
              "009v9y7d3vsljgq9nw5yx4kzyqavxbwrlvwhfjj83s6rmb9xcrmh")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-fontaxes
           texlive-iftex
           texlive-mweights
           texlive-xkeyval))
    (home-page "https://ctan.org/pkg/sourcecodepro")
    (synopsis "Use Source Code Pro with TeX(-alike) systems")
    (description "This package provides the Source Code Pro font family from
Adobe in both Adobe Type 1 and OpenType formats, plus macros supporting the
use of the fonts in LaTeX (Type 1) and XeLaTeX/LuaLaTeX (OTF).")
    (license (list license:lppl1.3+ license:silofl1.1))))

(define-public texlive-hyphenat
  (package
    (name "texlive-hyphenat")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/hyphenat/" "source/latex/hyphenat/"
                   "tex/latex/hyphenat/")
             (base32
              "0gm7s7bidp9b4sfgylvwydban8jylfcskmqrf0sxlwxsqxqq5fy5")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/hyphenat")
    (synopsis "Disable/enable hypenation")
    (description
     "This package can disable all hyphenation or enable hyphenation of
non-alphabetics or monospaced fonts.  The package can also enable hyphenation
within words that contain non-alphabetic characters (e.g., that include
underscores), and hyphenation of text typeset in monospaced (e.g.,
@code{cmtt}) fonts.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-hyphenat texlive-hyphenat)

(define-public texlive-lastpage
  (let ((template  (simple-texlive-package
                    "texlive-lastpage"
                    (list "doc/latex/lastpage/"
                          "source/latex/lastpage/"
                          "tex/latex/lastpage/")
                    (base32
                     "1cmzl0jkid4w60bjlyxrc5bynbc3lwq5nr77rsip0q9hprxykxks"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t) "latex/lastpage")
         ((#:build-targets _ '()) '(list "lastpage.ins"))))
      (home-page "https://ctan.org/pkg/lastpage")
      (synopsis "Reference last page for Page N of M type footers")
      (description
       "This package enables referencing the number of pages in a LaTeX
document through the introduction of a new label which can be referenced like
@code{\\pageref{LastPage}} to give a reference to the last page of a document.
It is particularly useful in the page footer that says: @samp{Page N of M}.")
      (license license:lppl1.3+))))

(define-deprecated-package texlive-latex-lastpage texlive-lastpage)

(define-public texlive-tabto-ltx
  (package
    (name "texlive-tabto-ltx")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/tabto-ltx/" "tex/latex/tabto-ltx/")
             (base32
              "0q0v1pc4hvj71nayfpkj6gfwcbi18s5c526r1k7j4p9m5fcqmbgm")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/tabto-ltx")
    (synopsis "Tab to a measured position in the line")
    (description
     "This package provides @code{\\tabto{<length>}}, which moves the
typesetting position to @code{<length>} from the left margin of the paragraph.
If the typesetting position is already further along, @code{\\tabto} starts
a new line; the command @code{\\tabto*} will move position backwards if
necessary, so that previous text may be overwritten.  In addition, the command
@code{\\TabPositions} may be used to define a set of tabbing positions, after
which the command @code{\\tab} advances typesetting position to the next
defined tab stop.")
    (license license:lppl1.3+)))

(define-deprecated-package texlive-latex-tabto-ltx texlive-tabto-ltx)

(define-public texlive-soul
  (let ((template (simple-texlive-package
                   "texlive-soul"
                   (list "doc/generic/soul/"
                         "source/generic/soul/"
                         "tex/generic/soul/")
                   (base32
                    "0ikipdswzsafi4rr6q9xh3hkxk2n2683ym1879qcax41xs6cizdl"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t) "generic/soul")
         ((#:build-targets _ '()) '(list "soul.ins"))))
      (home-page "http://www.ctan.org/pkg/soul")
      (synopsis "Hyphenation for letterspacing, underlining, and more")
      (description
       "@code{soul} enables hyphenatable spacing out (letterspacing),
underlining, striking out, etc., using the TeX hyphenation algorithm to find
the proper hyphens automatically.  The package also provides a mechanism that
can be used to implement similar tasks, that have to treat text syllable by
syllable.  The package itself does not support UTF-8 input in ordinary
(PDF)LaTeX; some UTF-8 support is offered by package @code{soulutf8}.")
      (license license:lppl))))

(define-deprecated-package texlive-generic-soul texlive-soul)

(define-public texlive-soulutf8
  (let ((template (simple-texlive-package
                   "texlive-soulutf8"
                   (list "doc/latex/soulutf8/"
                         "source/latex/soulutf8/"
                         "tex/generic/soulutf8/")
                   (base32
                    "0d9lv3xsads8ms642ys3pghxnsa2hlzafkcx66d2hbq224bz1phc"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t) "generic/soulutf8")
         ((#:build-targets _ '()) '(list "soulutf8.dtx"))))
      (propagated-inputs
       (list texlive-etexcmds
             texlive-infwarerr
             texlive-soul))
      (home-page "https://ctan.org/pkg/soulutf8")
      (synopsis "Permit use of UTF-8 characters in @code{soul}")
      (description
       "This package extends package @code{soul} and adds some support for
UTF-8.  Namely the input encodings in @file{utf8.def} from package
@code{inputenc} and @file{utf8x.def} from package @code{ucs} are supported.")
      (license license:lppl1.3+))))

(define-public texlive-xstring
  (package
    (name "texlive-xstring")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/generic/xstring/" "tex/generic/xstring/")
             (base32
              "1azpq855kq1l4686bjp8haxim5c8wycz1b6lcg5q7x8kb4g9sppn")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/xstring")
    (synopsis "String manipulation for (La)TeX")
    (description
     "The @code{xstring} package provides macros for manipulating strings, i.e.,
testing a string's contents, extracting substrings, substitution of substrings
and providing numbers such as string length, position of, or number of
recurrences of, a substring.  The package works equally in Plain TeX and
LaTeX (though e-TeX is always required).  The strings to be processed may
contain (expandable) macros.")
    (license license:lppl1.3c)))

(define-deprecated texlive-generic-xstring texlive-xstring)

(define-public texlive-substr
  (package
    (name "texlive-substr")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/substr/" "tex/latex/substr/")
             (base32
              "0kfd4kq5yrg65f2mpric1cs1xr416wgj9bdixpibgjsdg5fb73sw")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/substr")
    (synopsis "Deal with substrings in strings")
    (description
     "The package provides commands to deal with substrings of strings.
Macros are provided to determine if one string is a substring of another,
return the parts of a string before or after a substring, and count the number
of occurrences of a substring.")
    (license license:lppl1.0+)))

(define-public texlive-totcount
  (let ((template (simple-texlive-package
                   "texlive-totcount"
                   (list "doc/latex/totcount/"
                         "source/latex/totcount/"
                         "tex/latex/totcount/")
                   (base32
                    "1rj9ncip5h2cbdljjqwxqsg14pb4mimzhz290q872n32w7rxkp28"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (build-system texlive-build-system)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t) "latex/totcount")
         ((#:tex-format _ #t) "latex")
         ((#:build-targets _ '()) '(list "totcount.ins"))))
      (propagated-inputs
       (list texlive-graphics))
      (home-page "https://ctan.org/pkg/totcount")
      (synopsis "Find the last value of a counter")
      (description
       "This package records the value that was last set, for any counter of
interest.  Since most such counters are simply incremented when they are
changed, the recorded value will usually be the maximum value.")
      (license license:lppl1.3c+))))

(define-deprecated-package texlive-latex-totcount texlive-totcount)

(define-public texlive-totpages
  (let ((template (simple-texlive-package
                   "texlive-totpages"
                   (list "doc/latex/totpages/"
                         "source/latex/totpages/"
                         "tex/latex/totpages/")
                   (base32
                    "1mmya2fqdskyavw3hvdiygfyp9cll7bl4lpi7pl2jf9s7ds49j5a"))))
    (package
      (inherit template)
      (outputs '("out" "doc"))
      (build-system texlive-build-system)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:tex-directory _ #t) "latex/totpages")
         ((#:tex-format _ #t) "latex")
         ((#:build-targets _ '()) '(list "totpages.ins"))))
      (native-inputs
       (list (texlive-updmap.cfg)))
      (propagated-inputs
       (list texlive-everyshi texlive-graphics))
      (home-page "https://ctan.org/pkg/totpages")
      (synopsis "Count pages in a document, and report last page number")
      (description
       "The package counts the actual pages in the document (as opposed to
reporting the number of the last page, as does @code{lastpage}).  The counter
itself may be shipped out to the DVI file.")
      (license license:lppl))))

(define-public texlive-xetexconfig
  (package
    (name "texlive-xetexconfig")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "tex/xelatex/xetexconfig/")
             (base32
              "1253njshiwdayzq0xir9cmbi8syhjb3sc4pyrw9p6kzyqvckkcxm")))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/xetexconfig")
    (synopsis "@file{crop.cfg} for XeLaTeX")
    (description "The @file{crop.cfg} file attempts to persuade
@file{crop.sty} to work with XeTeX.")
    (license license:public-domain)))

(define-public texlive-xetex
  (package
    (name "texlive-xetex")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/man/man1/xelatex.1"
                   "doc/man/man1/xelatex.man1.pdf"
                   "doc/man/man1/xetex.1"
                   "doc/man/man1/xetex.man1.pdf"
                   "doc/xetex/base/"
                   "fonts/misc/xetex/fontmapping/base/")
             (base32
              "15bjr41p9l5d6837hy3nrhkkylgv04b0150vysyg5730svh3fnan")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (propagated-inputs
     (list texlive-atbegshi
           texlive-atveryend
           texlive-babel
           texlive-cm
           texlive-dvipdfmx
           texlive-etex
           texlive-everyshi
           texlive-firstaid
           texlive-hyphen-base
           texlive-l3backend
           texlive-l3kernel
           texlive-l3packages
           texlive-latex-base
           texlive-latex-fonts
           texlive-lm
           texlive-plain
           texlive-tex-ini-files
           texlive-unicode-data
           texlive-xetexconfig))
    (home-page "https://ctan.org/pkg/xetex")
    (synopsis "Extended variant of TeX for use with Unicode sources")
    (description
     "XeTeX is a TeX typesetting engine using Unicode and supporting modern font
technologies such as OpenType, TrueType or Apple Advanced Typography (AAT),
including OpenType mathematics fonts.  XeTeX supports many extensions that
reflect its origins in linguistic research; it also supports micro-typography
(as available in pdfTeX).  XeTeX was developed by the SIL (the first version
was specifically developed for those studying linguistics, and using Macintosh
computers).  XeTeX's immediate output is an extended variant of DVI format,
which is ordinarily processed by a tightly bound processor (called
@code{xdvipdfmx}), that produces PDF.")
    (license license:x11)))

(define-public texlive-xfor
  (package
    (name "texlive-xfor")
    (version (number->string %texlive-revision))
    (source (texlive-origin
             name version
             (list "doc/latex/xfor/"
                   "source/latex/xfor/"
                   "tex/latex/xfor/")
             (base32
              "1j241j8sixqkaj2xmcvmrfwm1sdw6xdssnzml1bjs54rqzyh768a")))
    (outputs '("out" "doc"))
    (build-system texlive-build-system)
    (home-page "https://ctan.org/pkg/xfor")
    (synopsis "Reimplementation of the LaTeX @code{for-loop} macro")
    (description
     "The package redefines the LaTeX internal @code{\\@@for} macro so that
the loop may be prematurely terminated.  The action is akin to the C/Java
break statement, except that the loop does not terminate until the end of the
current iteration.")
    (license license:lppl)))

;;;
;;; Avoid adding new packages to the end of this file. To reduce the chances
;;; of a merge conflict, place them above by existing packages with similar
;;; functionality or similar names.
;;;
