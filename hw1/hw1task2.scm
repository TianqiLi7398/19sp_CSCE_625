; ============================
; Name: Shivanand Pattanshetti 
; Homework 1 Task 2
; ============================
;
; ----------------------
; Execution instructions
; ----------------------
; (1) Start the interpreter : gsi
; (2) Load the file : > (load "hw1task2.scm")
; (3) Run the hw1task2 function (example) : > (hw1task2 9 3)
;
;
; ====================
; function "factorial"
; ====================
; For questions, contact shivanand.pattanshetti@gmail.com
; ------
; Inputs
; ------
; n = the number whose factorial is required
; ------
; Output
; ------
; The factorial of the input n calculated through recursion, but the intermediate solution is passed along.
(define (factorial n)
    ; every iteration of this loop multiplies the accumulated value with the current value
    ; and the current value is decremented by 1 for the next recursion
    (let loop(               
        (currentValue n)     ; the starting value is the number whose factorial is desired
        (accumulatedValue 1) ; the running product or accumulated value starts with 1
    )
        (if (not (= currentValue 1))              ; if the recursion has not yet reached down to 1 (from n)
            (loop                                 ; start the next level of recursion   
                (- currentValue 1)                ; the new current value will be the current one minus 1
                (* currentValue accumulatedValue) ; the new accumulated product = the current value times the previous accumulated product
            )
            accumulatedValue                      ; this is in the 'else' part where the recursion is down to 1, and the accumulated product is the factorial
        )        
    )
)
; ====================

; ======================
; function "TernaryTree"
; ======================
; For questions, contact shivanand.pattanshetti@gmail.com
; ------
; Inputs
; ------
; d = depth value assigned to the root node
; v = value assigned to the root node
; ------
; Output
; ------
; Returns an infinite ternary tree implemented with nodes represented as a 5-element list
; (1) List element 1 = d = depth value assigned to the root node
; (2) List element 2 = v = value assigned to the root node
; (3) List element 3 is a lazy (delayed evaluation) version of the ternary tree with
;                    d = depth = current-depth + 1
;                    v = value = factorial of the parent's value
; (4) List element 4 is also a lazy (delayed evaluation) version of the ternary tree with
;                    d = depth = current-depth + 1
;                    v = value = square-root of the parent's value
; (5) List element 5 is yet another lazy (delayed evaluation) version of the ternary tree with
;                    d = depth = current-depth + 1
;                    v = value = floor of the parent's value
(define (TernaryTree d v)
    (list
        d
        v
        (delay 
            (TernaryTree
                (+ d 1)
                (factorial v)
            )
        )
        (delay
            (TernaryTree
                (+ d 1)
                (sqrt v)
            )
        )
        (delay
            (TernaryTree
                (+ d 1)
                (floor v)
            )
        )
    )
)
; ======================

; ===============================
; function "getListOfAllChildren"
; ===============================
; For questions, contact shivanand.pattanshetti@gmail.com
; ------
; Inputs
; ------
; listOfNodes = a list of TernaryTree objects (which are basically 5-element lists with some lazy/delayed elements)
; ------
; Output
; ------
; The output is a list of all the child-nodes of all the input nodes (n nodes will have 3n children),
; combined together with good-old 'cons'ing. The decision to use a custom 'let loop' with 'cons'ing instead of 
; a 'map' on the list was influenced by the inability of 'map' to seamlessly combine an output with multiple sub-elements.
; The output of 'map' iteration corresponding to every item in the input list is packaged separately, unraveling
; which will prove to be cumbersome. That cannot be done inside or outside an element-wise lambda function either.
(define (getListOfAllChildren listOfNodes)
    (let loop(                                         ; A loop which accumulates left and right child nodes from each node from a list, into a new list/queue               
                (currentNode    (car listOfNodes))     ; The starting value of 'currentNode' is the first node
                (remainingNodes (cdr listOfNodes))     ; The starting value of 'remainingNodes'
                (runningList                  '())     ; The running list which accumulates all the unraveled child nodes
    )
        (if (not (null? remainingNodes))               ; If there are more nodes in the list 
            (loop                                      ; Continue dealing with the other nodes
                (car remainingNodes)                   ; New current node
                (cdr remainingNodes)                   ; New remaining nodes
                (cons                                  ; The unraveled three child elements below are 'prepend'ed to the running list
                    (force (caddr currentNode))        ; The first child node of the current parent (but third element), evaluated by force  
                    (cons
                        (force (cadddr currentNode))   ; The second child node of the current parent (but fourth element), evaluated by force  
                        (cons
                            (force (last currentNode)) ; The third child node of the current parent (but fifth element), evaluated by force
                            runningList                ; The running list to which the above child nodes are 'prepend'ed
                        )
                    )
                )
            )
            (cons                                      ; This is in the 'else' part where this is the last parent node in the list
                (force (caddr currentNode))            ; The first child node of the current parent (but third element), evaluated by force  
                (cons               
                    (force (cadddr currentNode))       ; The second child node of the current parent (but fourth element), evaluated by force  
                    (cons
                        (force (last currentNode))     ; The third child node of the current parent (but fifth element), evaluated by force
                        runningList                    ; The running list to which the above child nodes are 'prepend'ed
                    )
                )
            )
        )
    )
)
; ===============================

; ===================
; function "getDepth"
; ===================
; For questions, contact shivanand.pattanshetti@gmail.com
; ------
; Inputs
; ------
; ternaryTree = an infinite ternary tree implemented with nodes represented as a 5-element list (depth, value, and three child nodes)
; endValue    = the target value to be reached within the tree
; ------
; Output
; ------
; The output is one of the following three things:
; (1) The depth value of the current node IF the target end value is reached OR
; (2) A string message saying that the end value was not reached after crossing the depth threshold/bound
; (3) Recursion 
(define (getDepth ternaryTree endValue)
    (let loop(                                      ; A loop that traverses all the nodes at a particular depth level and starts a deeper loop if neededs
                (currentNode     ternaryTree)       ; The starting value of currentNode is the root node of the binary tree
                (remainingNodes '())                ; The starting value of the remainingNodes is empty because there is only one node for the root
                (listOfAllNodes (list ternaryTree)) ; The starting value for the list of all nodes at the current level is a list containing the root node
                (maxDepth 10)                       ; A local variable that stores the maximum depth beyond while computation will discontinue
    )
        (cond                                       ; 
            ((= (cadr currentNode) endValue)        ; If the value (second element) of the current node has reached the end value s
                (car currentNode)                   ; Return the depth of the current node (first element)
            )
            ((> (car currentNode) maxDepth)         ; If the depth (first element) of the current node has exceeded a threshold depth
                "Went deep, but could not find a solution :( ..."                   
            )
            (else                                   ; If the search needs to continue
                (if (not (null? remainingNodes))    ; If this is not the last node at a particular depth
                    (loop                           ; Continue checking the next node at the same depth (in the list/queue)
                        (car remainingNodes)        ; New starting node
                        (cdr remainingNodes)        ; New remaining nodes
                        listOfAllNodes              ; No change in the list of nodes
                        maxDepth                    ; No change in the depth threshold
                    )
                    (let (                          ; This is in the 'else' section, when you reach the last node at a particular depth
                            (childList (getListOfAllChildren listOfAllNodes)) ; Unravel all the children of all the nodes at this depth (n nodes -> 3n children)
                        )
                            (loop                   ; Loop over each element in the child list (at a higher depth) 
                                (car childList)     ; New starting node
                                (cdr childList)     ; New remaining nodes
                                childList           ; The new list of nodes is different this time - the list of child nodes
                                maxDepth            ; No change in the depth threshold
                            )                             
                    )
                )
            )
        )
    )
)
; ===================

; ===================
; function "hw1task2"
; ===================
; For questions, contact shivanand.pattanshetti@gmail.com
; ------
; Inputs
; ------
; startValue = the starting value 
; endValue   = the target value to be reached
; ------
; Output
; ------
; The output is one of the following two things:
; (1) The depth value of the current node IF the target end value is reached OR
; (2) A string message saying that the end value is unreachable within the specified depth threshold/bound
(define (hw1task2 startValue endValue)
    (getDepth
        (TernaryTree 0 startValue)
        endValue
    )
)
; ===================