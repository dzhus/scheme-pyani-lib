#lang scheme

;;; Solving linear equations

(require srfi/1
         srfi/43
         (planet wmfarr/simple-matrix:1:0/matrix)
         "matrix.ss"
         "vector.ss")

(provide solve-linear
         solve-tridiagonal
         solve-by-components)

;; Miscellaneous functions used to provide abstraction from matrix
;; representation
;;
;; Functions like `add-column`, `matrix-but-first-row`,
;; `matrix-but-first-column` are very slow because they use
;; `build-matrix`.

(define-syntax-rule [row-ref r n] [vector-ref r n])

(define-syntax-rule [row-length r] [vector-length r])

(define-syntax-rule [column-ref c n] [vector-ref c n])

(define-syntax-rule [column-length c] [vector-length c])

(define (first-row m)
  (build-vector (matrix-cols m)
                (lambda (n) (matrix-ref m 0 n))))

(define (first-column m)
  (build-vector (matrix-rows m)
                (lambda (n) (matrix-ref m n 0))))

(define (add-row m r)
  (let ((rows (add1 (matrix-rows m))))
    (build-matrix rows
                  (matrix-cols m)
                  (lambda (i j)
                    (if (= i (sub1 rows))
                        (row-ref r j)
                        (matrix-ref m i j))))))

(define (add-column m c)
  (let ((cols (add1 (matrix-cols m))))
    (build-matrix (matrix-rows m)
                  cols
                  (lambda (i j)
                    (if (= j (sub1 cols))
                        (column-ref c i)
                        (matrix-ref m i j))))))

(define (row-drop-right row n)
  (vector-copy row 0 (- (vector-length row) n)))

(define (row-drop-left row n)
  (vector-copy row n))

(define (row-but-first row)
  (row-drop-left row 1))

(define (row-but-last row)
  (row-drop-right row 1))

(define (matrix-but-first-row m)
  (build-matrix (sub1 (matrix-rows m))
                (matrix-cols m)
                (lambda (i j) (matrix-ref m (add1 i) j))))

(define (matrix-but-first-column m)
  (build-matrix (matrix-rows m)
                (sub1 (matrix-cols m))
                (lambda (i j) (matrix-ref m i (add1 j)))))

;; Return index of column element with maximum absolute value
(define (absmax-nonzero-column-index column)
  (fold
   (lambda (i prev)
     (if (> (abs (column-ref column i))
            (abs (column-ref column prev)))
         i
         prev))
   0
   (iota (column-length column))))

(define (matrix-map proc m)
  (build-matrix (matrix-rows m)
                (matrix-cols m)
                (lambda (i j) (proc i j (matrix-ref m i j)))))


;; Solve a system of linear equations given its matrix A and right
;; vector v using Gauss elimination.
;;
;; A must be _invertible_.
(define (solve-linear A v)
  ;; Get the top left coefficient of an augmented matrix
  (define (top-left equations)
    (matrix-ref equations 0 0))
  ;; Get the top right coefficient of an augmented matrix
  (define (top-right equations)
    (matrix-ref equations 0 (sub1 (matrix-cols equations))))
  ;; Make all zeros in leading column of augmented matrix
  (define (column-reduce equations)
    (let ((first-equation (first-row equations))
          (top-left (top-left equations)))
      (matrix-but-first-column
       (matrix-map
        (lambda (i j a)
          (- a
             (/ (* (row-ref first-equation j)
                   ;; We skip the first row, so add 1 to row index
                   (matrix-ref equations (add1 i) 0))
                top-left)))
        (matrix-but-first-row equations)))))
  ;; Given an augmented matrix with one equation of n variables and a
  ;; vector with values of (n-1) of them, make a system of the only
  ;; trivial equation ax=c
  (define (make-trivial equations subsolution)
    (let ((coeffs-row (row-but-first
                       (row-but-last (first-row equations)))))
      (matrix*
       1 2
       (top-left equations)
       (- (top-right equations)
          (vector-sum
           (vector-map (lambda (i x)
                         (* x (row-ref coeffs-row i)))
                       subsolution))))))
  (define (trivial? equations)
    (and (= (matrix-size equations) 1)
         (= (row-length (first-row equations)) 2)))
  ;; Solve a system of linear equations given its augmented matrix
  (define (solve-equations equations)
    (if (trivial? equations)
        ;; Solve trivial equation (ax=c) immediately
        (if (= (top-left equations) 0)
            (error "No solution: dependant rows")
            (vector (/ (top-right equations)
                       (top-left equations))))
        ;; Choose maximum element in first column and make that row a
        ;; new top to avoid accidental division by zero (non-zero
        ;; element always exists as A is invertible)
        (let* ((leading-row (absmax-nonzero-column-index
                             (first-column equations)))
               (equations (swap-matrix-rows equations 0 leading-row)))
          (if (= (top-left equations) 0)
              (error "No solution: dependant columns")
              (let ((subsolution (solve-equations
                                  (column-reduce equations))))
                (vector-append
                 ;; Solve an equation with only 1 variable (backward
                 ;; pass)
                 (solve-equations (make-trivial equations subsolution))
                 subsolution))))))
  (let ((augmented (add-column A v)))
    (solve-equations augmented)))


;; Solve system of equations with tridiagonal matrix
(define (solve-tridiagonal A v)
  (let ([k (vector-length v)])
    (define (a i) (matrix-ref A i (sub1 i)))
    (define (b i) (matrix-ref A i i))
    (define (c i) (matrix-ref A i (add1 i)))
    (define (d i) (vector-ref v i))
    (let ([alpha-beta (vector-unfold
                       (lambda (i alpha beta)
                         (let ([i (add1 i)])
                           (if (< i k)
                               (let ([gamma (+ (* (a i) alpha) (b i))])
                                 (values (cons alpha beta)
                                         ;; Don't calculate alpha on
                                         ;; last step (not needed
                                         ;; anyways)
                                         (if (< i (sub1 k))
                                             (/ (- (c i)) gamma)
                                             #f)
                                         (/ (- (d i) (* (a i) beta)) gamma)))
                               ;; We don't want to calculate anything
                               ;; beyond folding limit
                               (values (cons alpha beta) #f #f))))
                       k
                       (/ (- (c 0)) (b 0))
                       (/ (d 0) (b 0)))])
      (define (alpha i) (car (vector-ref alpha-beta i)))
      (define (beta i) (cdr (vector-ref alpha-beta i)))
      ;; alpha-beta is sorted by index in _descending_ order, so
      ;; `(beta 0)` is actually the last calculated beta
      (vector-unfold-right
       (lambda (i x)
         (let* ([i (- k i)])
           ;; Yet again calculations beyond folding
           ;; bound are unnecessary
           (if (< i k)
               (values x (+ (* (alpha (- k (add1 i))) x) (beta (- k (add1 i)))))
               (values x #f))))
       k
       (beta (sub1 k))))))


;; Assuming all elements of `A` are scalar and those of `v` are
;; vectors of equal length, solve corresponding linear system for each
;; component of `v` elements, then merge solutions so that the result
;; is a vector of vectors again
(define (solve-by-components A v method)
  (let ((partial-solutions (map (lambda (v-dimension)
                                  (method A v-dimension))
                                (map
                                 (lambda (component)
                                   (vector-map
                                    (lambda (i v-element)
                                      (vector-ref v-element component))
                                    v))
                                 (iota (vector-length (vector-ref v 0)))))))

    ;; Merge solutions
    (map list->vector
         (apply zip (map vector->list partial-solutions)))))
