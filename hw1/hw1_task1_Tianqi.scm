; This file is created by Jan 28, 2019 for HW1 in CSCE 625 AI, TAMU
; Author: Tianqi Li
; This is the algorithm for searching in P73 Russell & Norving 2016,
; question of infinite space raised by Donald Knuth.
; ========================================================================
; HW1 - Taks 1
; In task 1, function f(x) = 2x + 1, g(x) = 3x + 1 are used to get traget value from
; initial value (root). To avoid blowing up the memory, serveral conditions should
; be taken into consideration:
; 1.  Due to our funtion f and g are all monotone increasing functions, thus if we find
;     the expanded node is larger than target, we can stop searching;
; 2.  Our searching list is flatterned from the binary tree, based on the feature of binary
;     tree, I implemented a function exp_function to return the sequences of f(x) and g(x)
;     that obtain the target from root.


(display "Functions I chose to solve Donald Knuth's problem are:")
(newline)
(display "f(x) = 2x + 1")
(newline)
(display "g(x) = 3x + 1")
(newline)
(display "please type '(BestFirstSearch root target)' to make this work :)")
(newline)

; functions to generate 2 children from 1 root, which uses lazy evaluation
(define (lazy_tree x)
; the right child is generated from f(), left from g()
(delay (list (+ (* 2 x) 1) (+ (* 3 x) 1)))
)

; function to get log_2(x)
(define logB
(lambda (x B)
    (/ (log x) (log B)))
)

; append an element from right side of list, opposite of cons
(define (append_element lst elem)
  (append lst (list elem)))

; get the function sequences from the index get in the list,
; This is generated from the feature of binary tree
(define (exp_function index)
    (define y (+ index 1))
    (define n (truncate (logB y 2))) ; get tree's level / height
    (define funs `())
    (set! y (- y (- (expt 2 n) 1)))
    (set! n (- n 1))
    (let loop ((i n)) ; level by level, compare the index with 2^i, which i is the level height
        (if (< i 0)
            (display "the result can be achieved by function f(x) and g(x) in sequence")
            (begin (if (<= y (expt 2 i)) ; if index is smaller than 2^i, in ith level f() generated, vice versa.
                    (set! funs (append_element funs "f"))
                    (begin (set! funs (append_element funs "g"))

                        (set! y (- y (expt 2 i)))

                        )
                    )
                (loop (- i 1))
            )
        )
    )
    funs
)


; This is a recursive function, which expands the list while searching, and stops
; when get the target value or the value is larger than target
(define (searching root target Tree index)
(if (eq? root target)
     ;if find the result, return result
    index
    (begin (if (> root target)
        -1 ; when the searching result will exceed the traget, stop
        (begin
            (set! Tree (append Tree (force (lazy_tree root)))) ;expand the tree
            (set! index (+ index 1))
            (searching (list-ref Tree index) target Tree index)
            )
        )
    )
    )
)


; Main function to trigger the searching
(define (BestFirstSearch root target)
(define index 0)
(define Tree `()) ; Here Tree is the list for searching, whcih converts binary tree to 1-d list
(define result 0)
(set! Tree (append_element Tree root)) ; initialize the searching list
(set! result (searching root target Tree index))

(if (> result 0)
    (begin (display "Index of target value in searching list: ")(display result)
        (newline)
        (display (exp_function result))
        (newline)
    )
    ((display "result cannot be achieved...") ;cannot find result
    (newline))
    )

)
