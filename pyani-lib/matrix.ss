#lang scheme

;;; Matrix package

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
  (->d ([rows natural-number/c] [cols natural-number/c] [proc procedure?])
       ()
       #:pre-cond (= (procedure-arity proc) 2)
       (m matrix?)
       #:post-cond (and (= (matrix-rows m) rows)
                        (= (matrix-cols m) cols)))]
 [matrix-size
  (->d ([m matrix?])
       ()
       #:pre-cond (= (matrix-rows m) (matrix-cols m))
       (n natural-number/c))]
 [identity-matrix
  (natural-number/c . -> . matrix?)]
 [matrix-map
  (->d ([proc procedure?] [m matrix?])
       ()
       #:pre-cond (= (procedure-arity proc) 3)
       (o matrix?))])

(define (euclidean-matrix-norm m)
  (sqrt
   (apply +
          (for/list ((x (in-matrix m))) (sqr (abs x))))))

;; Very slow
(define (swap-matrix-rows m r1 r2)
  (for/matrix (matrix-rows m) (matrix-cols m)
              (((i j x) (in-matrix m)))
              (cond ((= i r1) (matrix-ref m r2 j))
                    ((= i r2) (matrix-ref m r1 j))
                    (else x))))

;; Build matrix with `n` rows and `m` columns, where each element is
;; computed as `(proc i j)`. Note that rows and columns are 0-based.
(define (build-matrix n m proc)
  (for*/matrix n m
               ((i (in-range n))
                (j (in-range m)))
               (proc i j)))

(define (matrix-map proc m)
  (build-matrix (matrix-rows m)
                (matrix-cols m)
                (lambda (i j) (proc i j (matrix-ref m i j)))))

;; Square matrix size
(define (matrix-size m)
  (matrix-rows m))

(define (kronecker i j)
  (if (= i j) 1 0))

(define (identity-matrix m)
  (build-matrix m m kronecker))
