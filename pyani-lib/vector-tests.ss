#lang scheme

(require (planet schematics/schemeunit:3)
         srfi/1)

(require "vector.ss")

(provide vector-tests)

(define-test-suite vector-tests
  (test-case
    "Nondestructive vector items swapping (swap-vector-items)"
    (check-equal? (swap-vector-items '#(1 2) 0 1) '#(2 1))
    (check-equal? (swap-vector-items (list->vector (iota 5)) 1 3) '#(0 3 2 1 4))
    (check-equal? (swap-vector-items '#(9 17 2 -5 -5 0 0 1) 2 5) '#(9 17 0 -5 -5 2 0 1))
    (check-equal? (swap-vector-items '#(0 0 0 0 1) 4 4) '#(0 0 0 0 1))
    (check-equal? (swap-vector-items '#(3 3 3) 1 2) '#(3 3 3)))

   (test-case
    "vector-sum"
    (check-= (vector-sum '#(1 3 -13 32 7 4)) 34 0)
    (check-= (vector-sum '#(0 0 1 1 -1000 0 0 0 1000 -1)) 1 0)
    (check-= (vector-sum '#(1 2 3 4 5 5 4 3 2 1)) 30 0)
    (check-= (vector-sum '#(1 4 2 4)) (vector-sum '#(2 1 5 3)) 0)
    (check-= (vector-sum '#(-0 0 -0.0)) 0 0))
   
  (check-true #f "Tests are not implemented"))
