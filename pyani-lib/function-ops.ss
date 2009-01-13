#lang scheme

;;; Various functions for functions

(require srfi/43
         "matrix.ss")

(provide deriv gradient hessian
         at-vector @)

;; `(at-vector f '#(a b))` is `(f a b)`
(define (at-vector f v)
  (apply f (vector->list v)))

(define-syntax-rule [@ f v] [at-vector f v])

(define deriv-dx 1e-6)

;; Derivative (partial probably)
;; 
;; (numbers -> numbers) -> (numbers -> numbers)
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
;;
;; (numbers -> numbers) -> (numbers -> vector)
(define (gradient f [dx deriv-dx])
  (let ((n (procedure-arity f)))
    (lambda args
      (build-vector n
                    (lambda (i)
                      (apply (deriv f (add1 i) dx) args))))))

;; Hessian matrix
;; 
;; (numbers -> numbers) -> (numbers -> matrix)
(define (hessian f [dx deriv-dx])
  (let ((n (procedure-arity f)))
    (lambda args
      (build-matrix (lambda (i j)
                      (apply (deriv (deriv f i dx) j dx)
                             args))
                    n n))))
