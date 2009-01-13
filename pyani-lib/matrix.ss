#lang scheme

;;; Matrix package

;;; THIS MODULE IS DELIBERATELY BROKENED!!!

(require srfi/43
         (planet wmfarr/simple-matrix:1:0/matrix))

(provide/contract
 [euclidean-matrix-norm
  (matrix? . -> . (>=/c 0))]
 [swap-matrix-rows
  (->d ([m matrix?]
        [r1 (and/c natural-number/c
                   (</c (matrix-rows m)))]
        [r2 (and/c natural-number/c
                   (</c (matrix-rows m)))])
       ()
       (_ matrix?))]
 [build-matrix
  (->d ([proc procedure?] [rows natural-number/c] [cols natural-number/c])
       ()
       #:pre-cond (= (procedure-arity proc) 2)
       (m matrix?)
       #:post-cond (and (= (matrix-rows m) rows)
                        (= (matrix-cols m) cols)))])

;; Norms
(define (euclidean-matrix-norm m)
  (sqrt
   (apply +
          (for/list ((x (in-matrix m))) (sqr (abs x))))))

(define (swap-matrix-rows m r1 r2)
  (for/matrix (matrix-rows m) (matrix-cols m)
              (((i j x) (in-matrix m)))
              (cond ((= i r1) (matrix-ref m r2 j))
                    ((= i r2) (matrix-ref m r1 j))
                    (else x))))

;; Build matrix with `n` rows and `m` columns, where each element is
;; computed as `(proc i j)`. Note that rows and columns are 0-based.
(define (build-matrix proc n m)
  (for*/matrix n m
               ((i (in-range n))
                (j (in-range m)))
               (proc i j)))
