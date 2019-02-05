#CSCE 625 AI 19 Sp 

#HW1 Search, BFS, Lazy Evalution

Tianqi Li

2019/02/04

UIN: 926000933

##	Task 1

Please check and run file `hw1_task1_Tianqi.scm`

## Task 2

- for the modification of the function, which uses $x!$, $\sqrt x$, and `floor(x)` funtions to expand, please check and run file `hw1_task2_Tianqi.scm`
- To ensure the program run without crashing, I made some constraints

1. Constraint on $x!​$: $x \in Integer, x < 1000​$

2. Constraint on 2-3 tree depth, which is input for searching

3. Use `car & cdr` function in scheme to pop out the searched nodes to shorten list length.

   Given an ideal machine, the solution to the puzzle will be achieved by these three functions, but the constraints made may cause the failure for solution. 