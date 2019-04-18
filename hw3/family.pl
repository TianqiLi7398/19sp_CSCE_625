parent(habd, ben).

if_then_else(Condition,Then,Else) :- Condition, !, Then.
% if_then_else(Condition,Then,Else) :- Else. 

max(X,Y,Max) :- 
X>Y -> Max is X; Max is Y.


add_list([], L, L).
add_list([H|T], L, L1) :- add(H, L2, L1), add_list(T, L, L2).

safe((1,1)).
safe((2,2)).

wirte_second(Alist, Sec) :-
   nth0(3, Alist, Sec).
    

run_agent(Percept, Action ):-
     nth0(2, Percept, Glitter),
     Glitter,
    Action is grab.

