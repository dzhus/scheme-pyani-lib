#lang scheme

(require (planet schematics/schemeunit:3))

(require "matrix.ss"
         "generic-ops.ss")

(provide generic-ops-tests)

(define-test-suite generic-ops-tests
  (test-case
   "Numbers"
   (check-equal? (+ 1 2) 3)
   (check-equal? (* -1 2) -2)
   (check-equal? (+ -1 2 -3 4 -5 6) 3))

  (test-case
   "Vectors"
   (check-equal? (+ '#(1 2 3) '#(4 1 -23)) '#(5 3 -20))
   (check-equal? (- '#(1 0 213) '#(2 4 2)) '#(-1 -4 211))
   (check-equal? (+ '#( 1  2  3    4)
                    '#( 2  4  2    5)
                    '#(-5  5  2 -100)
                    '#( 2 10 -2 1334))
                    '#( 0 21  5 1243)))

  (test-case
   "Matrices"
   (check-equal? (+ (matrix (row 1 2) (row 3 4))
                    (matrix (row 5 6) (row -3.2 -10))
                    (matrix (row 0 0) (row 5.5 4)))
                 (matrix (row 6 8) (row 5.3 -2)))
   (check-equal? (+ (matrix (row  1  2  3     4)
                            (row  2  4  2     5)
                            (row -5  6  2  -100)
                            (row  2 10 -2  1334))
                    (matrix (row -7  2  3  3454)
                            (row  3  0 12     5)
                            (row 15  5 2.1   20)
                            (row 92  0 -7  0724)))
                    (matrix (row -6  4  6  3458)
                            (row  5  4 14    10)
                            (row 10 11 4.1  -80)
                            (row 94 10 -9  2058)))))