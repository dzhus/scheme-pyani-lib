#lang scheme

;;; Various functions for functions

;;; THIS MODULE IS DELIBERATELY BROKENED!!!

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
(define (deriv f [arg 1] [dx deriv-dx])
  (define (der . args)
    (/
     (-
      (apply f
             (append
              (take args (sub1 arg))
              (list (+ (list-ref args (sub1 arg)) dx))
              (drop args arg)))
      (apply f
             (append
              (take args (sub1 arg))
              (list (- (list-ref args (sub1 arg)) dx))
              (drop args arg))))
     (* 2 dx)))
  der)

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
                      (apply (deriv
                              (deriv f (add1 i) dx) (add1 j) dx)
                             args))
                    n n))))