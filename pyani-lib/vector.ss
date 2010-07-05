#lang scheme

;;; Various functions for vectors

(require srfi/43
         (planet wmfarr/simple-matrix:1:0/matrix))

(provide vector-sum
         vectors-add
         swap-vector-items
         swap-vector-items!
         absmax-vector-element p-vector-norm
         zero-vector)

;; Sum of all vector elements
(define (vector-sum vec)
  (vector-fold (lambda (i sum x) (+ sum x)) 0 vec))

;; Variable arity version of vector-add
(define-syntax vectors-add
  (syntax-rules ()
    [(vectors-add v1 v2) (vector-add v1 v2)]
    [(vectors-add v1 v2 ...) (vector-add v1 (vectors-add v2 ...))]))

(define (absmax-vector-element v)
  (vector-fold (lambda (i max e) (if (> (abs e) max) (abs e) max))
               (vector-ref v 0) v))

(define (p-vector-norm v [p 2])
  (expt (vector-sum
         (vector-map (lambda (i e) (expt (abs e) p)) v))
        (/ 1 p)))

(define (zero-vector n)
  (make-vector n 0))

(define (swap-vector-items vec i j)
  (build-vector (vector-length vec)
                (lambda (n)
                  (cond ((= n i) (vector-ref vec j))
                        ((= n j) (vector-ref vec i))
                        (else (vector-ref vec n))))))

(define (swap-vector-items! vec i j)
  (let ((old-i (vector-ref vec i))
        (old-j (vector-ref vec j)))
    (vector-set! vec i old-j)
    (vector-set! vec j old-i)))
