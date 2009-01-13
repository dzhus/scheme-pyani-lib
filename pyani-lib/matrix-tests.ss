#lang scheme

(require (planet schematics/schemeunit:3)
         (planet wmfarr/simple-matrix:1:0/matrix))

(require "matrix.ss")

(provide matrix-tests)

(define-test-suite matrix-tests
  (test-case
   "Euclidean norm"
   ;; Yes, `check-equal?`, not `check-=`
   (check-equal? (euclidean-matrix-norm
                  (matrix* 3 3
                           0.1 -0.4 0
                           0.2 0 -0.3
                           0 0.1 0.3))
                 (sqrt 0.4))

   (check-equal? (euclidean-matrix-norm
                  (matrix* 2 2
                           0 6
                           8 0))
                 10)))
