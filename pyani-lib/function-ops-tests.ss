#lang scheme

(require (planet schematics/schemeunit:3)
         (planet schematics/schemeunit:3/text-ui))

(require srfi/43
         "function-ops.ss")

(provide function-ops-tests)

(define test-epsilon 1e-6)

;; Check that vectors of equal length have the same components
(define-check (check-vectors v1 v2 epsilon)
  (vector= (lambda (x y) (check-= x y epsilon)) v1 v2))

;; Check numbers or vectors of numbers for equality
(define-check (mcheck-= v1 v2)
  (if (and (vector? v1) (vector? v2))
      (check-vectors v1 v2 test-epsilon)
      (check-= v1 v2 test-epsilon)))

(define (f x y z t)
  (+ (* z (sqr x)) (sqrt y) (- (exp z) (* x (expt t 3)))))

(define (g x y)
  (* (sqr x) (sqrt y)))

(define v '#(1 2 3 4))

(define-test-suite function-ops-tests
  (test-case
   "at-vector"
   (check-equal? (@ + '#(1 2 3)) (+ 1 2 3))
   (check-equal? (@ f '#(-1 3.4 2 3/6)) (f -1 3.4 2 3/6))
   (check-equal? (@ f '#(0 0.4 22222 3/6)) (f 0 0.4 22222 3/6)))
  
  (test-case
   "Derivative"
   (mcheck-= ((deriv sin) 0) 1)
   (mcheck-= ((deriv cos) (/ pi 2)) -1)
   (mcheck-= ((deriv sqr) -5) -10)
   (mcheck-= ((deriv (compose sqr sqr)) 7) 1372)
   (mcheck-= ((deriv (compose sqr sin)) (/ pi 4)) 1))

  (test-case
   "Partial derivative"
   (mcheck-= ((deriv sin 1) 0) 1)
   (mcheck-= ((deriv sqr 1) 7) 14)
   (mcheck-= (@ (deriv f 1) v) -58)
   (mcheck-= (@ (deriv f 2) v) (/ 1 (* 2 (sqrt 2))))
   (mcheck-= (@ (deriv f 3) v) (+ 1 (exp 3)))
   (mcheck-= (@ (deriv f 4) v) -48))

  (test-case
   "Gradient"
   (mcheck-= (@ (gradient f) v)
             (vector -58 (/ 1 (* 2 (sqrt 2))) (+ 1 (exp 3)) -48))
   (mcheck-= (@ (gradient (lambda (x y) (+ (sqr x) (sqr y)))) '#(5 -7.5))
             '#(10 -15)))

  (test-case
   "Hessian"
   (check-true #f "Tests are not implemented")))
