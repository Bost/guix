(define-module (two)
  #:use-module (one)
  #:export (bar))

(define bar
  (list run-time))
