#lang scheme

(require (planet schematics/schemeunit:3)
         (planet schematics/schemeunit:3/text-ui)
         (planet wmfarr/simple-matrix:1:0/matrix))

(require srfi/43
         "function-ops.ss")

(provide function-ops-tests)

(define test-epsilon 1e-2)

;; Check that vectors of the same length have equal components
(define-check (check-vectors v1 v2 epsilon)
  (vector= (lambda (x y) (check-= x y epsilon)) v1 v2))

;; Check that two matrices of the same dimensions have equal
;; components
(define-check (matrix-= m1 m2 epsilon)
  (for/matrix (matrix-cols m1)
              (matrix-rows m1)
              ((x (in-matrix m1))
               (y (in-matrix m2)))
              (check-= x y epsilon)))

;; Check numbers or vectors of numbers or matrices of numbers for
;; equality
(define-check (mcheck-= v1 v2)
  (cond ((and (vector? v1) (vector? v2))
         (check-vectors v1 v2 test-epsilon))
        ((and (matrix? v1) (matrix? v2))
         (matrix-= v1 v2 test-epsilon))
        (else (check-= v1 v2 test-epsilon))))

(define-test-suite function-ops-tests
  (let ((v '#(1 2 3 4))
        (g (lambda (x y) (* (sqr x) (sqrt y))))
        (f (lambda (x y z t) (+ (* z (sqr x)) (sqrt y) (- (exp z) (* x (expt t 3)))))))
    
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
     (mcheck-= ((deriv sin 0) 0) 1)
     (mcheck-= ((deriv sqr 0) 7) 14)
     (mcheck-= (@ (deriv f 0) v) -58)
     (mcheck-= (@ (deriv f 1) v) (/ 1 (* 2 (sqrt 2))))
     (mcheck-= (@ (deriv f 2) v) (+ 1 (exp 3)))
     (mcheck-= (@ (deriv f 3) v) -48))

    (test-case
     "Gradient"
     (mcheck-= (@ (gradient f) v)
               (vector -58 (/ 1 (* 2 (sqrt 2))) (+ 1 (exp 3)) -48))
     (mcheck-= (@ (gradient (lambda (x y) (+ (sqr x) (sqr y)))) '#(5 -7.5))
               '#(10 -15)))

    (test-case
     "Hessian"
     (mcheck-= (@ (hessian f 1e-6) '#(2 1 0 3))
               (matrix* 4 4
                        0 0 4 -27
                        0 -1/4 0 0
                        4 0 1 0
                        -27 0 0 -36))
     (mcheck-= (@ (hessian g) '#(1 4))
               (matrix* 2 2
                        4 1/2
                        1/2 -1/32)))))
