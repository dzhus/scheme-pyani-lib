#lang scheme

;;; Various functions for functions

(require srfi/43
         (planet wmfarr/simple-matrix:1:0/matrix)
         "matrix.ss")

(provide/contract
 [deriv
  (->d ([f procedure?])
       ([arg (and/c integer?
                    (>=/c 0)
                    (</c (procedure-arity f)))]
        [dx number?])
       (derivative procedure?))]
 [gradient
  (->* (procedure?) (number?) procedure?)]
 [hessian
  (->* (procedure?) (number?) procedure?)]
 [at-vector
  (->d ([f procedure?]
        [v (vector-of-length/c (procedure-arity f))])
       ()
       any)])

(provide @)

;; `(at-vector f '#(a b))` is `(f a b)`
(define (at-vector f v)
  (apply f (vector->list v)))

(define-syntax-rule [@ f v] [at-vector f v])

(define deriv-dx 1e-6)

;; Derivative (partial probably)
(define (deriv f [arg 0] [dx deriv-dx])
  (lambda args
    (/
     (-
      (apply f
             (append
              (take args arg)
              (list (+ (list-ref args arg) dx))
              (drop args (add1 arg))))
      (apply f
             (append
              (take args arg)
              (list (- (list-ref args arg) dx))
              (drop args (add1 arg)))))
     (* 2 dx))))

;; Gradient of a function (still a vector for unary function)
(define (gradient f [dx deriv-dx])
  (let ((n (procedure-arity f)))
    (lambda args
      (build-vector n
                    (lambda (i)
                      (apply (deriv f i dx) args))))))

;; Hessian matrix
(define (hessian f [dx deriv-dx])
  (let ((n (procedure-arity f)))
    (lambda args
      (build-matrix n n
                    (lambda (i j)
                      (apply (deriv (deriv f i dx) j dx)
                             args))))))
