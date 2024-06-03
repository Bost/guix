;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2012-2021, 2023 Ludovic Courtès <ludo@gnu.org>
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

(define-module (test-store)
  #:use-module (guix tests)
  #:use-module (guix config)
  #:use-module (guix store)
  #:use-module (guix utils)
  #:use-module (guix monads)
  #:use-module ((gcrypt hash) #:prefix gcrypt:)
  #:use-module ((gcrypt pk-crypto) #:prefix gcrypt:)
  #:use-module (guix pki)
  #:use-module (guix base32)
  #:use-module (guix packages)
  #:use-module (guix derivations)
  #:use-module (guix serialization)
  #:use-module (guix build utils)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (gnu packages bootstrap)
  #:use-module (ice-9 match)
  #:use-module (ice-9 regex)
  #:use-module (rnrs bytevectors)
  #:use-module (rnrs io ports)
  #:use-module (web uri)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (srfi srfi-26)
  #:use-module (srfi srfi-34)
  #:use-module (srfi srfi-64))

;; Test the (guix store) module.

(define %store
  (open-connection-for-tests))
(format #t "############## %store : ~a\n" %store)

(define %shell
  (or (getenv "SHELL") (getenv "CONFIG_SHELL") "/bin/sh"))

(format #t "############## %shell : ~a\n" %shell)

(test-begin "my-store")

(test-assert "substitute, corrupt output hash, build trace"
  ;; Likewise, and check the build trace.
  (with-store s
    (let* ((c   "hello, world")                   ; contents of the output
           (d   (build-expression->derivation
                 s "corrupt-substitute"
                 `(mkdir %output)
                 #:guile-for-build
                 (package-derivation s %bootstrap-guile (%current-system))))
           (o   (derivation->output-path d)))
      ;; Make sure we use 'guix substitute'.
      (set-build-options s
                         #:print-extended-build-trace? #t
                         #:print-build-trace #t
                         #:use-substitutes? #t
                         #:fallback? #f
                         #:substitute-urls (%test-substitute-urls))

      (with-derivation-substitute d c
        (sha256 => (make-bytevector 32 0)) ;select a hash that doesn't match C

        (define output
          (call-with-output-string
            (lambda (port)
              (parameterize ((current-build-output-port port))
                (guard (c ((store-protocol-error? c) #t))
                  (build-derivations s (list d))
                  #f)))))

        (format #t ">>>>>>>>>>>>>>>>>>> output :\n~a\n<<<<<<<<<<<<<<<<<<<<<<<<\n" output)

        (define actual-hash
          (let-values (((port get-hash)
                        (gcrypt:open-hash-port
                         (gcrypt:hash-algorithm gcrypt:sha256))))
            (write-file-tree "foo" port
                             #:file-type+size
                             (lambda _
                               (values 'regular (string-length c)))
                             #:file-port
                             (lambda _
                               (open-input-string c)))
            (close-port port)
            (bytevector->nix-base32-string (get-hash))))

        (define expected-hash
          (bytevector->nix-base32-string (make-bytevector 32 0)))

        (define mismatch
          (string-append "@ hash-mismatch " o " sha256 "
                         expected-hash " " actual-hash "\n"))

        (define failure
          (string-append "@ substituter-failed " o))

        (and (string-contains output mismatch)
             (string-contains output failure))))))

(test-end "my-store")
