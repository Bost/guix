(define-module (one)
  #:use-module (srfi srfi-9)
  #:export (run-time
            expansion-time))

(define run-time 'one)
(define-syntax expansion-time
  (identifier-syntax 'one))
