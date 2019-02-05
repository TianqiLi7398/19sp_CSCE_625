; This file is created by Jan 28, 2019 for HW1 in CSCE 625 AI, TAMU
; Author: Tianqi Li
; This is the algorithm for searching in P73 Russell & Norving 2016,
; question of infinite space raised by Donald Knuth.
; ========================================================================
; HW1 - Taks 2
; In task 2, function x!, sqrt(x) and floor(x) are used to get traget value from
; initial value (root). To avoid blowing up the memory, serveral conditions should
; be taken into consideration:
; 1.  factorial function only take integers;
; 2.  Avoid make factorial for larger input, I set x < 1000;
; 3.  shorten the searching list as possible as I could, which I use car and cdr
;     function to pop out the searched values
; 4.  This tree is not a strict ternary tree, but a 2-3 tree, which the maximun
;     nodes for depth n should be considered as 3^n;
; 5.  Due to it is not a strict ternary nor binary tree, I cannot use index to
;     find the sequences of the function to get target number as I did in task1:(

(display "Functions I chose to solve Donald Knuth's problem are:")
(newline)
(display "f(x) = x!")
(newline)
(display "g(x) = sqrt(x)")
(newline)
(display "l(x) = floor(x)")
(newline)
(display "please type '(BestFirstSearch_maxdepth root target maxDepth)' to make this work :)")
(newline)

(define factorial
    (lambda (n)
        (do
            (
            (i n (- i 1))
            (x 1 (* x i))
            )
            ((zero? i) x))
    )
)

; functions to generate 2 children from 1 root, which uses lazy evaluation
(define (lazy_tree x)
; the right child is generated from f(), left from g()
(if (eq? x (floor x))
    (if (> x 1000) ; I pervent factorial calculation over 1000!
        (delay (list (sqrt x) (floor x)))
        (delay (list (factorial x) (sqrt x) (floor x)))
    )
    (delay (list (sqrt x) (floor x)))
    )
)




; append an element from right side of list, opposite of cons
(define (append_element lst elem)
  (append lst (list elem)))


; This is a recursive function, which expands the list while searching, and stops
; when get the target value or searched over maxindex time
(define (searching_depth root target Tree index maxindex)
(if (= root target)
     ;if find the result, return result
    index
    (begin (if (> index maxindex)
        -1; when the searching result will exceed the traget, stop
        (begin

            (set! Tree (append Tree (force (lazy_tree root)))) ;expand the tree
            (set! Tree (cdr Tree))
            (set! index (+ index 1))
            (searching_check (car Tree) target Tree index maxindex) ; I didn't use list_ref to save memory
            )
        )
    )
    )
)

; Given depth limit of the ternary tree, this function returns the maximum number
; of vertices in this tree, which is the max index number in the converted searching list
(define (max_index depth)
(define index 0)
(let loop ((i depth))
    (if (= i 0)
        (set! index (+ index 1))
        (begin (set! index (+ index (expt 3 i)))
            (loop (- i 1))
        )
    )
)
index
)

; Main function to trigger the searching
(define (BestFirstSearch_maxdepth root target maxdepth)
(define index 0)
(define Tree `()) ; Here Tree is the list for searching, whcih converts binary tree to 1-d list
(define result 0)
(define maxindex (max_index maxdepth))
(set! Tree (append_element Tree root)) ; initialize the searching list
(set! result (searching_depth root target Tree index maxindex))

(if (> result 0)
    (begin (display "Index of target value in searching list: ")(display result)
        (newline)
    )
    (begin (display "result cannot be achieved by depth of ") ;cannot find result
    (display maxdepth) ;cannot find result
    (newline))
    )

)
