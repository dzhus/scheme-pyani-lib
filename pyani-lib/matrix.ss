#lang scheme

;;; Matrix package

;;; THIS MODULE IS DELIBERATELY BROKENED!!!

(require srfi/43
         "vector.ss")

(provide euclidean-matrix-norm
         swap-matrix-rows)

;; Norms
(define (euclidean-matrix-norm m)
  (sqrt
   (vector-sum
    (rows-map
     (lambda (row)
       (vector-sum
        (row-map (lambda (e) (sqr e)) row)))
     m))))

;; Special matrices
(define (identity-matrix n)
  (define (kronecker i j) (if (= i j) 1 0))
  (build-matrix kronecker n n))

(define (swap-matrix-rows matrix i j)
  (swap-vector-items matrix i j))
