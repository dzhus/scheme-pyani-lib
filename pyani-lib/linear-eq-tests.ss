#lang scheme

(require srfi/43
         (planet schematics/schemeunit:3)
         (planet wmfarr/simple-matrix:1:0/matrix)
         "linear-eq.ss")

(provide lineq-tests)

(define test-epsilon 1e-10)

(define-check (check-vectors v1 v2 epsilon)
  (vector= (lambda (x y) (check-= x y epsilon)) v1 v2))

(define-test-suite lineq-tests
  (test-case
   "Solve systems of linear equations"
   (check-vectors (solve-linear (matrix* 2 2
                                         1 3
                                         5 9)
                                (vector 4 14))
                  '#(1 1)
                  test-epsilon)
   (check-vectors (solve-linear (matrix* 3 3
                                         1 2 3
                                         4 5 9
                                         9 -10 0)
                                (vector 16 43 -50))
                  '#(0 5 2)
                  test-epsilon)
   (check-vectors (solve-linear (matrix* 4 4
                                         -4 5 2 65
                                         2 -10 11 13
                                         3/7 -6 192 2
                                         6 0 13/8 0.5)
                                (vector 580 262 27399/14 35.75))
                  '#(2.5 -3.0 10.0 9.0)
                  test-epsilon)
   (check-vectors (solve-linear (matrix* 3 3
                                         2 -9 5
                                         1.2 -5.3999 6
                                         1 -1 -7.5)
                                (vector -4 0.6001 -8.5))
                  '#(0.0 1.0 1.0)
                  test-epsilon))

  (test-case
   "TDMA"
   (check-vectors (solve-tridiagonal (matrix* 4 4
                                              5 -1 0 0
                                              2 4.6 -1 0
                                              0 2 3.6 -0.8
                                              0 0 3 4.4)
                                     (vector 2 3.3 2.6 7.2))
                  '#(0.52560 0.628 0.64 1.2)
                  test-epsilon)
   (check-vectors (solve-tridiagonal (matrix* 4 4
                                              1    2    0    0
                                              1.5  4    5    0
                                              0   -109 -1000 102
                                              0    0   -5.5  133.7)
                                     (vector 3
                                             10.5
                                             -1107.98
                                             -4.163))
                  '#(1 1 1 0.01)
                  test-epsilon)))
