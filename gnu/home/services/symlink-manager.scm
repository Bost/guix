;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2021 Andrew Tropin <andrew@trop.in>
;;; Copyright © 2021 Xinglu Chen <public@yoctocell.xyz>
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

(define-module (gnu home services symlink-manager)
  #:use-module (gnu home services)
  #:use-module (guix gexp)
  #:use-module (guix modules)
  #:export (home-symlink-manager-service-type))

;;; Comment:
;;;
;;; symlink-manager cares about configuration files: it backs up files
;;; created by user, removes symlinks and directories created by a
;;; previous generation, and creates new directories and symlinks to
;;; configuration files according to the content of files/ directory
;;; (created by home-files-service) of the current home environment
;;; generation.
;;;
;;; Code:

(define (update-symlinks-script)
  (program-file
   "update-symlinks"
   (with-imported-modules (source-module-closure
                           '((guix build utils)
                             (guix i18n)))
     #~(begin
         (use-modules (ice-9 ftw)
                      (ice-9 curried-definitions)
                      (ice-9 match)
                      (srfi srfi-1)
                      (guix i18n)
                      (guix build utils))

         (define ((simplify-file-tree parent) file)
           "Convert the result produced by `file-system-tree' to less
verbose and more suitable for further processing format.

Extract dir/file info from stat and compose a relative path to the
root of the file tree.

Sample output:

((dir . \".\")
 ((dir . \"config\")
  ((dir . \"config/fontconfig\")
   (file . \"config/fontconfig/fonts.conf\"))
  ((dir . \"config/isync\")
   (file . \"config/isync/mbsyncrc\"))))
"
           (match file
             ((name stat) `(file . ,(string-append parent name)))
             ((name stat children ...)
              (cons `(dir . ,(string-append parent name))
                    (map (simplify-file-tree
                          (if (equal? name ".")
                              ""
                              (string-append parent name "/")))
                         children)))))

         (define ((file-tree-traverse preordering) node)
           "Traverses the file tree in different orders, depending on PREORDERING.

if PREORDERING is @code{#t} resulting list will contain directories
before files located in those directories, otherwise directory will
appear only after all nested items already listed."
           (let ((prepend (lambda (a b) (append b a))))
             (match node
               (('file . path) (list node))
               ((('dir . path) . rest)
                ((if preordering append prepend)
                 (list (cons 'dir path))
                 (append-map (file-tree-traverse preordering) rest))))))

         (define home-path
           (getenv "HOME"))

         (define backup-dir
           (string-append home-path "/" (number->string (current-time))
                          "-guix-home-legacy-configs-backup"))

         (define (get-target-path path)
           (string-append home-path "/." path))

         (define (get-backup-path path)
           (string-append backup-dir "/." path))

         (define (empty-directory? dir)
           (equal? (scandir dir) '("." "..")))

         (define (symlink-to-store? path)
           (and (equal? (stat:type (lstat path)) 'symlink)
                (store-file-name? (readlink path))))

         (define (backup-file path)
           (mkdir-p backup-dir)
           (format #t (G_ "Backing up ~a...") (get-target-path path))
           (mkdir-p (dirname (get-backup-path path)))
           (rename-file (get-target-path path) (get-backup-path path))
           (display (G_ " done\n")))

         (define (cleanup-symlinks old-tree)
           ;; Delete from directory OLD-TREE symlinks that correspond to a
           ;; previous generation.
           (let ((to-delete ((file-tree-traverse #f) old-tree)))
             (display
              (G_
               "Cleaning up symlinks from previous home-environment.\n\n"))
             (for-each
              (match-lambda
                (('dir . ".")
                 (display (G_ "Cleanup finished.\n\n")))

                (('dir . path)
                 (if (and
                      (file-exists? (get-target-path path))
                      (file-is-directory? (get-target-path path))
                      (empty-directory? (get-target-path path)))
                     (begin
                       (format #t (G_ "Removing ~a...")
                               (get-target-path path))
                       (rmdir (get-target-path path))
                       (display (G_ " done\n")))
                     (format
                      #t
                      (G_ "Skipping ~a (not an empty directory)... done\n")
                      (get-target-path path))))

                (('file . path)
                 (when (file-exists? (get-target-path path))
                   ;; DO NOT remove the file if it is no longer a symlink to
                   ;; the store, it will be backed up later during
                   ;; create-symlinks phase.
                   (if (symlink-to-store? (get-target-path path))
                       (begin
                         (format #t (G_ "Removing ~a...") (get-target-path path))
                         (delete-file (get-target-path path))
                         (display (G_ " done\n")))
                       (format
                        #t
                        (G_ "Skipping ~a (not a symlink to store)... done\n")
                        (get-target-path path))))))
              to-delete)))

         (define (create-symlinks new-tree new-files-path)
           ;; Create in directory NEW-TREE symlinks to the files under
           ;; NEW-FILES-PATH, creating backups as needed.
           (define (get-source-path path)
             (readlink (string-append new-files-path "/" path)))

           (let ((to-create ((file-tree-traverse #t) new-tree)))
             (for-each
              (match-lambda
                (('dir . ".")
                 (display
                  (G_ "New symlinks to home-environment will be created soon.\n"))
                 (format
                  #t (G_ "All conflicting files will go to ~a.\n\n") backup-dir))

                (('dir . path)
                 (let ((target-path (get-target-path path)))
                   (when (and (file-exists? target-path)
                              (not (file-is-directory? target-path)))
                     (backup-file path))

                   (if (file-exists? target-path)
                       (format
                        #t (G_ "Skipping   ~a (directory already exists)... done\n")
                        target-path)
                       (begin
                         (format #t (G_ "Creating   ~a...") target-path)
                         (mkdir target-path)
                         (display (G_ " done\n"))))))

                (('file . path)
                 (when (file-exists? (get-target-path path))
                   (backup-file path))
                 (format #t (G_ "Symlinking ~a -> ~a...")
                         (get-target-path path) (get-source-path path))
                 (symlink (get-source-path path) (get-target-path path))
                 (display (G_ " done\n"))))
              to-create)))

         #$%initialize-gettext

         (let* ((he-path (string-append (getenv "HOME") "/.guix-home"))
                (new-he-path (string-append he-path ".new"))
                (new-home (getenv "GUIX_NEW_HOME"))
                (old-home (getenv "GUIX_OLD_HOME"))

                (new-files-path (string-append new-home "/files"))
                ;; Trailing dot is required, because files itself is symlink and
                ;; to make file-system-tree works it should be a directory.
                (new-files-dir-path (string-append new-files-path "/."))

                (old-tree (if old-home
                              ((simplify-file-tree "")
                               (file-system-tree
                                (string-append old-home "/files/.")))
                              #f))
                (new-tree ((simplify-file-tree "")
                           (file-system-tree new-files-dir-path))))

           (when old-tree
             (cleanup-symlinks old-tree))

           (create-symlinks new-tree new-files-path)

           (symlink new-home new-he-path)
           (rename-file new-he-path he-path)

           (display (G_" done\nFinished updating symlinks.\n\n")))))))

(define (update-symlinks-gexp _)
  #~(primitive-load #$(update-symlinks-script)))

(define home-symlink-manager-service-type
  (service-type (name 'home-symlink-manager)
                (extensions
                 (list
                  (service-extension
                   home-activation-service-type
                   update-symlinks-gexp)))
                (default-value #f)
                (description "Provide an @code{update-symlinks}
script, which creates symlinks to configuration files and directories
on every activation.  If an existing file would be overwritten by a
symlink, backs up that file first.")))
