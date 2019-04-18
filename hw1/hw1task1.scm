; ============================
; Name: Shivanand Pattanshetti
; Homework 1 Task 1
; ============================
;
; ----------------------
; Execution instructions
; ----------------------
; (1) Start the interpreter : gsi
; (2) Load the file : > (load "hw1task1.scm")
; (3) Run the hw1task1 function (example) : > (hw1task1 1 4)
;
;
; =====================
; function "BinaryTree"
; =====================
; For questions, contact shivanand.pattanshetti@gmail.com
; ------
; Inputs
; ------
; d = depth value assigned to the root node
; v = value assigned to the root node
; ------
; Output
; ------
; Returns an infinite binary tree implemented with nodes represented as a 4-element list
; (1) List element 1 = d = depth value assigned to the root node
; (2) List element 2 = v = value assigned to the root node
; (3) List element 3 is a lazy (delayed evaluation) version of the binary tree with
;                    d = depth = current-depth + 1
;                    v = value = 2 * current-value + 1
; (4) List element 4 is also a lazy (delayed evaluation) version of the binary tree with
;                    d = depth = current-depth + 1
;                    v = value = 2 * current-value + 1
(define (BinaryTree d v)
    (list
        d
        v
        (delay
            (BinaryTree
                (+ d 1)
                (+ (* 2 v) 1)
            )
        )
        (delay
            (BinaryTree
                (+ d 1)
                (+ (* 2 v) 0)
                ; (+ (* 3 v) 1)
            )
        )
    )
)
; ===================

; ===============================
; function "getListOfAllChildren"
; ===============================
; For questions, contact shivanand.pattanshetti@gmail.com
; ------
; Inputs
; ------
; listOfNodes = a list of BinaryTree objects (which are basically 4-element lists with some lazy/delayed elements)
; ------
; Output
; ------
; The output is a list of all the child-nodes of all the input nodes (n nodes will have 2n children),
; combined together with good-old 'cons'ing. The decision to use a custom 'let loop' with 'cons'ing instead of
; a 'map' on the list was influenced by the inability of 'map' to seamlessly combine an output with multiple sub-elements.
; The output of 'map' iteration corresponding to every item in the input list is packaged separately, unraveling
; which will prove to be cumbersome. That cannot be done inside or outside an element-wise lambda function either.
(define (getListOfAllChildren listOfNodes)
    (let loop(                                     ; A loop which accumulates left and right child nodes from each node from a list, into a new list/queue
                (currentNode    (car listOfNodes)) ; The starting value of 'currentNode' is the first node
                (remainingNodes (cdr listOfNodes)) ; The starting value of 'remainingNodes'
                (runningList                  '()) ; The running list which accumulates all the unraveled child nodes
    )
        (if (not (null? remainingNodes))
            (loop                                                                                ; Continue dealing with the remaining nodes
                (car remainingNodes)                                                             ; New current node
                (cdr remainingNodes)                                                             ; New remaining nodes
                (cons (force (caddr currentNode)) (cons (force (last currentNode)) runningList)) ; Preprend the running list with the left and right child nodes
            )
            (cons (force (caddr currentNode)) (cons (force (last currentNode)) runningList))     ; Preprend the running list with the left and right child nodes
        )
    )
)
; =============================

; ===================
; function "getDepth"
; ===================
; For questions, contact shivanand.pattanshetti@gmail.com
; ------
; Inputs
; ------
; binaryTree = an infinite binary tree implemented with nodes represented as a 4-element list (depth, value, left-child, and right-child)
; endValue   = the target value to be reached in the tree
; ------
; Output
; ------
; The output is one of the following three things:
; (1) The depth value of the current node IF the target end value is reached OR
; (2) A string message saying that the end value is unreachable within the tree if the current node value exceeds a threshold OR
; (3) Recursion
(define (getDepth binaryTree endValue)
    (let loop(                                     ; A loop that traverses all the nodes at a particular depth level and starts a deeper loop if needed
                (currentNode           binaryTree) ; The starting value of currentNode is the root node of the binary tree
                (remainingNodes               '()) ; The starting value of the remainingNodes is empty because there is only one node for the root
                (listOfAllNodes (list binaryTree)) ; The starting value for the list of all nodes at the current level is a list containing the root node
                (maxValue          (* 4 endValue)) ; A local variable that stores 4 times the end value, which is the threshold/bound for any node's value
    )
        (cond
            ((= (cadr currentNode) endValue)       ; If the value (second element) of the current node has reached the end value
                (car currentNode)                  ; Return the depth of the current node (first element)
            )
            ((> (cadr currentNode) maxValue)       ; If the value (second element) of the current node has reached the threshold/bound value
                "Unreachable..."                   ; Display a message saying that the goal cannot be reached
            )
            (else                                  ; If the search needs to continue
                (if (not (null? remainingNodes))   ; If this is not the last node at a particular depth
                    (loop                          ; Continue checking the next node at the same depth (in the list/queue)
                        (car remainingNodes)       ; New starting node
                        (cdr remainingNodes)       ; New remaining nodes
                        listOfAllNodes             ; No change in the list of nodes
                        maxValue                   ; No change in the maximum bound for the node value
                    )
                    (let (                         ; This is in the 'else' section, when you reach the last node at a particular depth
                            (childList (getListOfAllChildren listOfAllNodes)) ; Unravel all the children of all the nodes at this depth (n nodes -> 2n children)
                        )
                            (loop                  ; Loop over each element in the child list (at a higher depth)
                                (car childList)    ; New starting node
                                (cdr childList)    ; New remaining nodes
                                childList          ; The new list of nodes is different this time - the list of child nodes
                                maxValue           ; No change in the maximum bound for the node value
                            )
                    )
                )
            )
        )
    )
)
; ===================

; ===================
; function "hw1task1"
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
; (2) A string message saying that the end value is unreachable within the tree if the current node value exceeds a threshold OR
(define (hw1task1 startValue endValue)
    (getDepth
        (BinaryTree 0 startValue) ; create a binary tree where the root is assigned depth = 0 and a starting value given by the user input
        endValue
    )
)
; ===================
