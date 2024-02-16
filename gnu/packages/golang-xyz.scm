;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2017, 2018, 2019 Leo Famulari <leo@famulari.name>
;;; Copyright © 2018 Pierre-Antoine Rouby <pierre-antoine.rouby@inria.fr>
;;; Copyright © 2019 Brian Leung <bkleung89@gmail.com>
;;; Copyright © 2020 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2021 Sarah Morgensen <iskarian@mgsn.dev>
;;; Copyright © 2022 Dominic Martinez <dom@dominicm.dev>
;;; Copyright © 2023 Benjamin <benjamin@uvy.fr>
;;; Copyright © 2023 Hilton Chain <hako@ultrarare.space>
;;; Copyright © 2023 Katherine Cox-Buday <cox.katherine.e@gmail.com>
;;; Copyright © 2023, 2024 Sharlatan Hellseher <sharlatanus@gmail.com>
;;; Copyright © 2023 Thomas Ieong <th.ieong@free.fr>
;;; Copyright © 2023 Timo Wilken <guix@twilken.net>
;;; Copyright © 2024 Artyom V. Poptsov <poptsov.artyom@gmail.com>
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

(define-module (gnu packages golang-xyz)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system go)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages golang)
  #:use-module (gnu packages golang-build)
  #:use-module (gnu packages golang-check)
  #:use-module (gnu packages golang-compression)
  #:use-module (gnu packages golang-crypto))

;;; Commentary:
;;;
;;; Nomad Golang modules (libraries) are welcome here.
;;;
;;; Please: Try to add new module packages in alphabetic order.
;;;
;;; Code:

(define-public go-github-com-a8m-envsubst
  (package
    (name "go-github-com-a8m-envsubst")
    (version "1.4.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/a8m/envsubst")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1mjs729g9nmalx25l4nn3p07amm4vsciqmdf0jbh2jwpy1zymz41"))))
    (build-system go-build-system)
    (arguments
     (list #:import-path "github.com/a8m/envsubst"))
    (home-page "https://github.com/a8m/envsubst")
    (synopsis "Environment variables substitution for Go")
    (description
     "This package provides a library for environment variables
substitution.")
    (license license:expat)))

(define-public go-github-com-alecthomas-participle-v2
  (package
    (name "go-github-com-alecthomas-participle-v2")
    (version "2.1.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/alecthomas/participle")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0k2vsd58rgwyylyn5zja6z6k1sg4m39g2fhd88lvja60ca51bh98"))))
    (build-system go-build-system)
    (arguments
     (list #:go go-1.18
           #:import-path "github.com/alecthomas/participle/v2"))
    (native-inputs
     (list go-github-com-alecthomas-assert-v2))
    (home-page "https://github.com/alecthomas/participle")
    (synopsis "Parser library for Go")
    (description
     "This package provides a parser library for Golang which constructs
parsers from definitions in struct tags and parses directly into those
structs.  The approach is similar to how other marshallers work in Golang,
\"unmarshalling\" an instance of a grammar into a struct.")
    (license license:expat)))

(define-public go-github-com-anmitsu-go-shlex
  (package
    (name "go-github-com-anmitsu-go-shlex")
    (version "0.0.0-20200514113438-38f4b401e2be")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/anmitsu/go-shlex")
               (commit (go-version->git-ref version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "17iz68yzbnr7y4s493asbagbv79qq8hvl2pkxvm6bvdkgphj8w1g"))))
    (build-system go-build-system)
    (arguments '(#:import-path "github.com/anmitsu/go-shlex"))
    (home-page "https://github.com/anmitsu/go-shlex")
    (synopsis "Simple shell-like lexical analyzer for Go")
    (description "This package provides a simple lexical analyzer to parse
shell-like commands.")
    (license license:expat)))

(define-public go-github-com-armon-go-radix
  (package
    (name "go-github-com-armon-go-radix")
    (version "1.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/armon/go-radix")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1m1k0jz9gjfrk4m7hjm7p03qmviamfgxwm2ghakqxw3hdds8v503"))))
    (build-system go-build-system)
    (arguments '(#:import-path "github.com/armon/go-radix"))
    (home-page "https://github.com/armon/go-radix")
    (synopsis "Go implementation of Radix trees")
    (description "This package provides a single @code{Tree} implementation,
optimized for sparse nodes of
@url{http://en.wikipedia.org/wiki/Radix_tree,radix tree}.")
    (license license:expat)))

(define-public go-github-com-bitly-go-hostpool
  (package
    (name "go-github-com-bitly-go-hostpool")
    (version "0.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/bitly/go-hostpool")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1iibj7dwymczw7cknrh6glc6sdpp4yap2plnyr8qphynwrzlz73w"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/bitly/go-hostpool"))
    (native-inputs (list go-github-com-stretchr-testify))
    (home-page "https://github.com/bitly/go-hostpool")
    (synopsis "Pool among multiple hosts from Golang")
    (description
     "This package provides a Go package to intelligently and flexibly pool among
multiple hosts from your Go application.  Host selection can operate in round
robin or epsilon greedy mode, and unresponsive hosts are avoided.")
    (license license:expat)))

(define-public go-github-com-bitly-timer-metrics
  (package
    (name "go-github-com-bitly-timer-metrics")
    (version "1.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/bitly/timer_metrics")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "02fhx8hx8126m2cgxw9fm8q2401r7zfann8b5zy5yyark1sgkrb4"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/bitly/timer_metrics"))
    (home-page "https://github.com/bitly/timer_metrics")
    (synopsis "Capture timings and enable periodic metrics every @var{n} events")
    (description "This package provides an efficient way to capture timing
information and periodically output metrics")
    (license license:expat)))

(define-public go-github-com-blang-semver
  (let ((commit "60ec3488bfea7cca02b021d106d9911120d25fe9")
        (revision "0"))
    (package
      (name "go-github-com-blang-semver")
      (version (git-version "0.0.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/blang/semver")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "19pli07y5592g4dyjyj0jq5rn548vc3fz0qg3624vm1j5828p1c2"))))
      (build-system go-build-system)
      (arguments
       '(#:import-path "github.com/blang/semver"))
      (home-page "https://github.com/blang/semver")
      (synopsis "Semantic versioning library written in Go")
      (description
       "Semver is a library for Semantic versioning written in Go.")
      (license license:expat))))

(define-public go-github-com-bmizerany-perks-quantile
  (package
    (name "go-github-com-bmizerany-perks-quantile")
    (version "0.0.0-20230307044200-03f9df79da1e")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/bmizerany/perks")
             (commit (go-version->git-ref version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1f2a99v3618bz2mf61iwhdjm3xi1gam6v4apqgcrz71gj7ba9943"))))
    (build-system go-build-system)
    (arguments
     (list #:unpack-path "github.com/bmizerany/perks"
           #:import-path "github.com/bmizerany/perks/quantile"))
    (home-page "https://github.com/bmizerany/perks")
    (synopsis "Library for computing quantiles")
    (description
     "Perks contains the Go package @code{quantile} that computes approximate
quantiles over an unbounded data stream within low memory and CPU bounds.")
    (license license:bsd-2)))

(define-public go-github-com-burntsushi-toml
  (package
    (name "go-github-com-burntsushi-toml")
    (version "1.2.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/BurntSushi/toml")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1v9czq4hsyvdz7yx70y6sgq77wmrgfmn09r9cj4w85z38jqnamv7"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/BurntSushi/toml"))
    (home-page "https://github.com/BurntSushi/toml")
    (synopsis "Toml parser and encoder for Go")
    (description
     "This package is toml parser and encoder for Go.  The interface is
similar to Go's standard library @code{json} and @code{xml} package.")
    (license license:expat)))

(define-public go-github-com-coreos-go-systemd-activation
  (package
    (name "go-github-com-coreos-go-systemd-activation")
    (version "0.0.0-20191104093116-d3cd4ed1dbcf")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/coreos/go-systemd")
                    (commit (go-version->git-ref version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "193mgqn7n4gbb8jb5kyn6ml4lbvh4xs55qpjnisaz7j945ik3kd8"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/coreos/go-systemd/activation"
       #:unpack-path "github.com/coreos/go-systemd"))
    (home-page "https://github.com/coreos/go-systemd")
    (synopsis "Go bindings to systemd socket activation")
    (description "Go bindings to systemd socket activation; for writing and
using socket activation from Go.")
    (license license:asl2.0)))

(define-public go-github-com-coreos-go-systemd-daemon
  (package
    (inherit go-github-com-coreos-go-systemd-activation)
    (name "go-github-com-coreos-go-systemd-daemon")
    (arguments
     '(#:import-path "github.com/coreos/go-systemd/daemon"
       #:unpack-path "github.com/coreos/go-systemd"))
    (home-page "https://github.com/coreos/go-systemd")
    (synopsis "Go bindings to systemd for notifications")
    (description "Go bindings to systemd for notifying the daemon of service
status changes")))

(define-public go-github-com-coreos-go-systemd-dbus
  (package
    (inherit go-github-com-coreos-go-systemd-activation)
    (name "go-github-com-coreos-go-systemd-dbus")
    (arguments
     '(#:tests? #f ;Tests require D-Bus daemon running.
       #:import-path "github.com/coreos/go-systemd/dbus"
       #:unpack-path "github.com/coreos/go-systemd"))
    (native-inputs (list go-github-com-godbus-dbus))
    (home-page "https://github.com/coreos/go-systemd")
    (synopsis "Go bindings to systemd for managing services")
    (description "Go bindings to systemd for starting/stopping/inspecting
running services and units.")))

(define-public go-github-com-coreos-go-systemd-journal
  (package
    (inherit go-github-com-coreos-go-systemd-activation)
    (name "go-github-com-coreos-go-systemd-journal")
    (arguments
     '(#:tests? #f ;Tests require access to journald socket.
       #:import-path "github.com/coreos/go-systemd/journal"
       #:unpack-path "github.com/coreos/go-systemd"))
    (home-page "https://github.com/coreos/go-systemd")
    (synopsis "Go bindings to systemd for writing journald")
    (description "Go bindings to systemd for writing to systemd's logging
service, journald.")))

(define-public go-github-com-coreos-go-systemd-login1
  (package
    (inherit go-github-com-coreos-go-systemd-activation)
    (name "go-github-com-coreos-go-systemd-login1")
    (arguments
     '(#:tests? #f ;Tests require D-Bus daemon running.
       #:import-path "github.com/coreos/go-systemd/login1"
       #:unpack-path "github.com/coreos/go-systemd"))
    (native-inputs (list go-github-com-godbus-dbus))
    (home-page "https://github.com/coreos/go-systemd")
    (synopsis "Go bindings to systemd for integration with logind API")
    (description "Go bindings to systemd for integration with the systemd
logind API.")))

(define-public go-github-com-coreos-go-systemd-machine1
  (package
    (inherit go-github-com-coreos-go-systemd-activation)
    (name "go-github-com-coreos-go-systemd-machine1")
    (arguments
     '(#:tests? #f ;Tests require D-Bus daemon running.
       #:import-path "github.com/coreos/go-systemd/machine1"
       #:unpack-path "github.com/coreos/go-systemd"))
    (native-inputs (list go-github-com-godbus-dbus))
    (home-page "https://github.com/coreos/go-systemd")
    (synopsis "Go bindings to systemd for registering machines/containers")
    (description "Go bindings to systemd for registering
machines/containers.")))

(define-public go-github-com-coreos-go-systemd-sdjournal
  (package
    (inherit go-github-com-coreos-go-systemd-activation)
    (name "go-github-com-coreos-go-systemd-sdjournal")
    (arguments
     '(#:tests? #f ;Tests require D-Bus daemon running.
       #:import-path "github.com/coreos/go-systemd/sdjournal"
       #:unpack-path "github.com/coreos/go-systemd"
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'fix-sdjournal-header
           (lambda* (#:key import-path #:allow-other-keys)
             (substitute* (format #f
                                  "src/~a/journal.go"
                                  import-path)
               (("systemd/sd-journal.h")
                "elogind/sd-journal.h")
               (("systemd/sd-id128.h")
                "elogind/sd-id128.h")))))))
    (inputs (list elogind))
    (synopsis "Go bindings to systemd for journald")
    (description "Go bindings to systemd for reading from journald by wrapping
its C API.")))

(define-public go-github-com-coreos-go-systemd-unit
  (package
    (inherit go-github-com-coreos-go-systemd-activation)
    (name "go-github-com-coreos-go-systemd-unit")
    (arguments
     '(#:tests? #f ;Tests require D-Bus daemon running.
       #:import-path "github.com/coreos/go-systemd/unit"
       #:unpack-path "github.com/coreos/go-systemd"))
    (native-inputs (list go-github-com-godbus-dbus))
    (home-page "https://github.com/coreos/go-systemd")
    (synopsis "Go bindings to systemd for working with unit files")
    (description "Go bindings to systemd for (de)serialization and comparison
of unit files.")))

(define-public go-github-com-cyberdelia-go-metrics-graphite
  (package
    (name "go-github-com-cyberdelia-go-metrics-graphite")
    (version "0.0.0-20161219230853-39f87cc3b432")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/cyberdelia/go-metrics-graphite")
               (commit (go-version->git-ref version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1nnpwryw8i110laffyavvhx38gcd1jnpdir69y6fxxzpx06d094w"))))
    (build-system go-build-system)
    (propagated-inputs
     (list go-github-com-rcrowley-go-metrics))
    (arguments
     '(#:tests? #f ; Tests require network interface access
       #:import-path "github.com/cyberdelia/go-metrics-graphite"))
    (home-page "https://github.com/cyberdelia/go-metrics-graphite")
    (synopsis "Graphite client for go-metrics")
    (description "This package provides a reporter for the
@url{https://github.com/rcrowley/go-metrics,go-metrics} library which posts
metrics to Graphite.")
    (license license:bsd-2)))

(define-public go-github-com-dimchansky-utfbom
  (package
    (name "go-github-com-dimchansky-utfbom")
    (version "1.1.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/dimchansky/utfbom")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0ll3wqvifmdanfyg6wsvz31c7n4mnczg2yxb65j35qxrnak89hn3"))))
    (build-system go-build-system)
    (arguments
     (list #:import-path "github.com/dimchansky/utfbom"))
    (home-page "https://github.com/dimchansky/utfbom")
    (synopsis "Go Unicode byte order mark detection library")
    (description
     "This package provides a library for @acronym{BOM, Unicode Byte Order
Mark} detection.")
    (license license:asl2.0)))

(define-public go-github-com-djherbis-atime
  (package
    (name "go-github-com-djherbis-atime")
    (version "1.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/djherbis/atime")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0xsz55zpihd9wyrj6qvm3miqzb6x3mnp5apzs0dx1byndhb8adpq"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/djherbis/atime"))
    (home-page "https://github.com/djherbis/atime")
    (synopsis "Access Times for files")
    (description "Package atime provides a platform-independent way to get
atimes for files.")
    (license license:expat)))

(define-public go-github-com-gabriel-vasile-mimetype
  (package
    (name "go-github-com-gabriel-vasile-mimetype")
    (version "1.4.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/gabriel-vasile/mimetype")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "11swnjczhrza0xi8q2wlk056nnbcghm44vqs52zfv6rwqvy6imhj"))))
    (build-system go-build-system)
    (arguments
     (list
      #:go go-1.20
      #:import-path "github.com/gabriel-vasile/mimetype"
      #:phases #~(modify-phases %standard-phases
                   (add-before 'check 'add-supported-mimes-md
                     (lambda* (#:key import-path #:allow-other-keys)
                       ;; This file needs to be available for writing during the
                       ;; tests otherwise they will fail.
                       (let ((file (format #f "src/~a/supported_mimes.md"
                                           import-path)))
                         (invoke "touch" file)
                         (chmod file #o644)))))))
    (propagated-inputs (list go-golang-org-x-net))
    (home-page "https://github.com/gabriel-vasile/mimetype")
    (synopsis "Golang library for media type and file extension detection")
    (description
     "This package provides a Golang module that uses magic number signatures
to detect the MIME type of a file.

Main features:
@itemize
@item Fast and precise MIME type and file extension detection.
@item Supports
@url{https://github.com/gabriel-vasile/mimetype/blob/master/supported_mimes.md,
many MIME types}.
@item Allows to
@url{https://pkg.go.dev/github.com/gabriel-vasile/mimetype#example-package-Extend,
extend} with other file formats.
@item Common file formats are prioritized.
@item
@url{https://pkg.go.dev/github.com/gabriel-vasile/mimetype#example-package-TextVsBinary,
Differentiation between text and binary files}.
@item Safe for concurrent usage.
@end itemize")
    (license license:expat)))

(define-public go-github-com-matryer-try
  (package
    (name "go-github-com-matryer-try")
    (version "1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/matryer/try")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "15f0m5ywihivnvwzcw0mh0sg27aky9rkywvxqszxka9q051qvsmy"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/matryer/try"
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'fix-tests
            (lambda* (#:key import-path #:allow-other-keys)
              (substitute* (string-append "src/" import-path
                                          "/try_test.go")
                (("var value string")
                 "")
                (("value, err = SomeFunction\\(\\)")
                 "_, err = SomeFunction()")))))))
    (native-inputs
     (list go-github-com-cheekybits-is))
    (home-page "https://github.com/matryer/try")
    (synopsis "Simple idiomatic retry package for Go")
    (description "This package provides an idiomatic Go retry module.")
    (license license:expat)))

(define-public go-github-com-mattn-go-shellwords
  (package
    (name "go-github-com-mattn-go-shellwords")
    (version "1.0.12")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mattn/go-shellwords")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0l0l5s4hlsrm4z6hygig2pp1qirk5ycrzn9z27ay3yvg9k7zafzx"))))
    (build-system go-build-system)
    (arguments
     `(#:import-path "github.com/mattn/go-shellwords"
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-sh-path
           (lambda* (#:key import-path #:allow-other-keys)
             (substitute* (string-append
                           "src/" import-path "/util_posix.go")
               (("/bin/sh") (which "sh"))))))))
    (home-page "https://github.com/mattn/go-shellwords")
    (synopsis "Parse lines into shell words")
    (description "This package parses text into shell arguments.  Based on
the @code{cpan} module @code{Parse::CommandLine}.")
    (license license:expat)))

(define-public go-github-com-miekg-dns
  (package
    (name "go-github-com-miekg-dns")
    (version "1.1.48")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/miekg/dns")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "14m4wnbgmc1prj4ds1fsz1nwb1awaq365lhbp8clzsidxmhjf3hl"))))
    (build-system go-build-system)
    (arguments '(#:import-path "github.com/miekg/dns"))
    (propagated-inputs
     (list go-golang-org-x-tools
           go-golang-org-x-sys
           go-golang-org-x-sync
           go-golang-org-x-net))
    (home-page "https://github.com/miekg/dns")
    (synopsis "Domain Name Service library in Go")
    (description
      "This package provides a fully featured interface to the @acronym{DNS,
Domain Name System}.  Both server and client side programming is supported.
The package allows complete control over what is sent out to the @acronym{DNS,
Domain Name Service}.  The API follows the less-is-more principle, by
presenting a small interface.")
    (license license:bsd-3)))

(define-public go-github-com-mreiferson-go-options
  (package
    (name "go-github-com-mreiferson-go-options")
    (version "1.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mreiferson/go-options")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1pxs9ybrh196qy14ijn4zn51h2z28lj31y6vxrz2xxhgvpmfmxyl"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/mreiferson/go-options"))
    (home-page "https://github.com/mreiferson/go-options")
    (synopsis "Go package to structure and resolve options")
    (description
     "The @code{options} Go package resolves configuration values set via
command line flags, config files, and default struct values.")
    (license license:expat)))

(define-public go-github-com-mreiferson-go-svc
  ;; NSQ specific fork of github.com/judwhite/go-svc, as Guix go build system
  ;; does not support go.mod with `replace' statement.
  (let ((commit "7a96e00010f68d9436e3de53a70c53f209a0c244")
        (revision "0"))
    (package
      (name "go-github-com-mreiferson-go-svc")
      (version (git-version "1.2.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/mreiferson/go-svc")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1acgb0n3svhnraqj1fz5qc5n3b4vc5ffwyk9vfi6gcfkibm0hgmd"))))
      (build-system go-build-system)
      (arguments
       '(#:import-path "github.com/judwhite/go-svc"))
      (propagated-inputs (list go-golang-org-x-sys))
      (home-page "https://github.com/mreiferson/go-svc")
      (synopsis "Go Windows Service wrapper for GNU/Linux")
      (description
       "Go Windows Service wrapper compatible with GNU/Linux.  Windows tests
@url{https://github.com/judwhite/go-svc/raw/master/svc/svc_windows_test.go,here}.")
      (license license:expat))))

(define-public go-github-com-nats-io-nats-go
  (package
    (name "go-github-com-nats-io-nats-go")
    (version "1.32.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/nats-io/nats.go")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "08b3n5mdpxvn9hipz0j001bp5r67i43cqji9x9dyzikypqdfg38k"))))
    (build-system go-build-system)
    (arguments
     (list
      #:go go-1.20
      #:import-path "github.com/nats-io/nats.go"))
    (propagated-inputs (list go-golang-org-x-text
                         go-github-com-nats-io-nuid
                         go-github-com-nats-io-nkeys
                         go-github-com-klauspost-compress))
    (home-page "https://github.com/nats-io/nats.go")
    (synopsis "Go Client for NATS server")
    (description
     "This package provides a Go client for the NATS messaging system.")
    (license license:asl2.0)))

(define-public go-github-com-nats-io-nuid
  (package
    (name "go-github-com-nats-io-nuid")
    (version "1.0.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/nats-io/nuid")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "11zbhg4kds5idsya04bwz4plj0mmiigypzppzih731ppbk2ms1zg"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/nats-io/nuid"))
    (home-page "https://github.com/nats-io/nuid")
    (synopsis "Go library implementing identifier generator for NATS ecosystem")
    (description
     "This package provides a unique identifier generator that is high performance,
very fast, and tries to be entropy pool friendly.")
    (license license:asl2.0)))

(define-public go-github-com-nbrownus-go-metrics-prometheus
  (package
    (name "go-github-com-nbrownus-go-metrics-prometheus")
    (version "0.0.0-20210712211119-974a6260965f")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/nbrownus/go-metrics-prometheus")
               (commit (go-version->git-ref version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1kl9l08aas544627zmhkgp843qx94sxs4inxm20nw1hx7gp79dz0"))))
    (build-system go-build-system)
    (arguments '(#:import-path "github.com/nbrownus/go-metrics-prometheus"))
    (propagated-inputs
     (list go-github-com-stretchr-testify
           go-github-com-rcrowley-go-metrics
           go-github-com-prometheus-client-golang))
    (home-page "https://github.com/nbrownus/go-metrics-prometheus")
    (synopsis "Prometheus support for go-metrics")
    (description "This package provides a reporter for the @code{go-metrics}
library which posts the metrics to the Prometheus client registry and just
updates the registry.")
    (license license:asl2.0)))

(define-public go-github-com-nsqio-go-diskqueue
  (package
    (name "go-github-com-nsqio-go-diskqueue")
    (version "1.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/nsqio/go-diskqueue")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1hp66hkmfn0nyf3c53a40f94ah11a9rj01r5zp3jph9p54j8rany"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/nsqio/go-diskqueue"))
    (home-page "https://github.com/nsqio/go-diskqueue")
    (synopsis "Go package providing a file system backed FIFO queue")
    (description
     "The @code{diskqueue} Go package provides a file system backed FIFO
queue.")
    (license license:expat)))

(define-public go-github-com-nsqio-go-nsq
  (package
    (name "go-github-com-nsqio-go-nsq")
    (version "1.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/nsqio/go-nsq")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1h9z3z225sdgg7fl3l7x11xn5ch6lm5flgmcj046cdp453qj2qhf"))))
    (build-system go-build-system)
    (arguments
     (list #:tests? #f                  ;tests require networking
           #:import-path "github.com/nsqio/go-nsq"))
    (propagated-inputs (list go-github-com-golang-snappy))
    (home-page "https://github.com/nsqio/go-nsq")
    (synopsis "Consumer/producer library for NSQ")
    (description
     "The @code{nsq} Go module provides a high-level @code{Consumer} and
@code{Producer} types as well as low-level functions to communicate over the
NSQ protocol @url{https://nsq.io/}.")
    (license license:expat)))

(define-public go-github-com-prometheus-client-model
  (let ((commit "14fe0d1b01d4d5fc031dd4bec1823bd3ebbe8016")
        (revision "2"))
    (package
      (name "go-github-com-prometheus-client-model")
      (version (git-version "0.0.2" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/prometheus/client_model")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0zdmk6rbbx39cvfz0r59v2jg5sg9yd02b4pds5n5llgvivi99550"))))
      (build-system go-build-system)
      (arguments
       '(#:import-path "github.com/prometheus/client_model"
         #:tests? #f
         #:phases
         (modify-phases %standard-phases
           ;; Source-only package
           (delete 'build))))
      (propagated-inputs
       (list go-github-com-golang-protobuf-proto))
      (synopsis "Data model artifacts for Prometheus")
      (description "This package provides data model artifacts for Prometheus.")
      (home-page "https://github.com/prometheus/client_model")
      (license license:asl2.0))))

(define-public go-github-com-rcrowley-go-metrics
  (let ((commit "cac0b30c2563378d434b5af411844adff8e32960")
        (revision "2"))
    (package
      (name "go-github-com-rcrowley-go-metrics")
      (version (git-version "0.0.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/rcrowley/go-metrics")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1hfxffnpaw49pr3wrkbzq3pnv3nyzsvk5dxndv0yz70xlrbg8a04"))))
      (build-system go-build-system)
      (arguments
       ;; Arbitrary precision tests are known to be broken on aarch64, ppc64le
       ;; and s390x. See: https://github.com/rcrowley/go-metrics/issues/249
       `(#:tests? ,(not (string-prefix? "aarch64" (or (%current-target-system)
                                                      (%current-system))))
         #:import-path "github.com/rcrowley/go-metrics"))
      (propagated-inputs
       (list go-github-com-stathat-go))
      (synopsis "Go port of Coda Hale's Metrics library")
      (description "This package provides a Go implementation of Coda Hale's
Metrics library.")
      (home-page "https://github.com/rcrowley/go-metrics")
      (license license:bsd-2))))

(define-public go-github-com-skip2-go-qrcode
  (package
    (name "go-github-com-skip2-go-qrcode")
    (version "0.0.0-20200617195104-da1b6568686e")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/skip2/go-qrcode")
             (commit (go-version->git-ref version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0pghd6y2x8a5fqy4rjn4d8j5jcslb236naycdza5an7vyvinsgs9"))
       (patches (search-patches "go-github-com-skip2-go-qrcode-fix-tests.patch"))))
    (build-system go-build-system)
    (arguments '(#:import-path "github.com/skip2/go-qrcode"))
    (home-page "https://github.com/skip2/go-qrcode")
    (synopsis "QR code encoder")
    (description "This package provides a QR code encoder for the Goloang.")
    (license license:expat)))

(define-public go-github-com-songgao-water
  (package
    (name "go-github-com-songgao-water")
    (version "0.0.0-20200317203138-2b4b6d7c09d8")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/songgao/water")
               (commit (go-version->git-ref version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1k5aildfszp6x66jzar4y36lic8ijkb5020hfaivpvq3bnwdiikl"))))
    (build-system go-build-system)
    (arguments '(#:tests? #f ; Tests require network interface access
                 #:import-path "github.com/songgao/water"))
    (home-page "https://github.com/songgao/water")
    (synopsis "Simple network TUN/TAP library")
    (description
      "This package provides a simple TUN/TAP interface library for Go that
efficiently works with standard packages like @code{io}, @code{bufio}, etc..
Use waterutil with it to work with TUN/TAP packets/frames.")
    (license license:bsd-3)))

(define-public go-github-com-stathat-go
  (let ((commit "74669b9f388d9d788c97399a0824adbfee78400e")
        (revision "0"))
    (package
      (name "go-github-com-stathat-go")
      (version (git-version "0.0.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/stathat/go")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1zzlsl24dyr202qkr2pay22m6d0gb7ssms77wgdx0r0clgm7dihw"))))
      (build-system go-build-system)
      (arguments
       `(#:import-path "github.com/stathat/go"))
      (synopsis "Post statistics to StatHat")
      (description "This is a Go package for posting to a StatHat account.")
      (home-page "https://github.com/stathat/go")
      (license license:expat))))

(define-public go-go-uber-org-automaxprocs
  (package
    (name "go-go-uber-org-automaxprocs")
    (version "1.5.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/uber-go/automaxprocs")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "03arxcfaj7k6iwfdk0liaynxf9rjfj9m5glsjp7ws01xjkgrdpbc"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "go.uber.org/automaxprocs"))
    (native-inputs (list go-github-com-stretchr-testify
                         go-github-com-prashantv-gostub))
    (home-page "https://github.com/uber-go/automaxprocs")
    (synopsis "CPU-count detection library for Go")
    (description
     "This package automatically set GOMAXPROCS to match Linux container
CPU quota.")
    (license license:expat)))

;;;
;;; Avoid adding new packages to the end of this file. To reduce the chances
;;; of a merge conflict, place them above by existing packages with similar
;;; functionality or similar names.
;;;
