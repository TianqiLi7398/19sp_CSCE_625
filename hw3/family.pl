
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

show_records([]).
show_records([A|B]) :-
format('ID = ~w\tName = ~w\tGrade = ~w~n',A),
show_records(B).



aunt(A, B) :-
A ='no', B is 0; B is 1.


init_agent:-
    assert(safelocation((1,1))),
    assert(gobackOrig(0)),
    assert(searchPit(0)),
    assert(searchWump(0)),
    assert(wumpDead(0)),
    assert(current_location(1,1)),
    assert(current_orientation(0)).

add_savelocation(X,Y):-
    X>=1, Y>=1,assert(safelocation(X,Y)).


revise_location(X,Y):-
    current_orientation(Z),
    Z = 0, X < 8,
    retractall(current_location(_,_)),
    NewX is X + 1,
    assert(current_location(NewX ,Y)).
revise_location(X,Y):-
    current_orientation(Z),
    Z = 90, Y < 8,
    retractall(current_location(_,_)),
    NewY is Y + 1,
    assert(current_location(X ,NewY)).
revise_location(X,Y):-
    current_orientation(Z),
    Z = 180, X>= 2,
    retractall(current_location(_,_)),
    NewX is X - 1,
    assert(current_location(NewX ,Y)).
revise_location(X,Y):-
    current_orientation(Z),
    Z = 270, Y>= 2,
    retractall(current_location(_,_)),
    NewY is Y - 1,
    assert(current_location(X ,NewY)).


isorequal(X, Y):-
    X = 'no', Y = 1.
isorequal(X, Y):-
    X = 'yes', Y = 2.



%=============================

run_agent(Percept, goforward):-
    nth0(0, Percept, Stench),
    nth0(1, Percept, Breeze),
    nth0(3, Percept, Bump  ),
    Stench = 'no', Breeze = 'no', Bump = 'no',
    current_location(X,Y),
    X < 9, Y < 9,
    add_safe_location(X+1,Y),
    add_safe_location(X-1,Y),
    add_safe_location(X,Y+1),
    add_safe_location(X,Y-1),
    revise_location(X,Y),
    format('\n=====================================================\n'),
    format('This is run_agent(.,.):\n\t It gets called each time step.\n\tThis default one simply moves forward\n'),
    format('You might find "display_world" useful, for your debugging.\n'),
    display_world,
    format('=====================================================\n\n').

add_safe_location(X,Y):-
    X>=1, Y>=1, assert(safelocation(X,Y)).

% when move (means action is goforward, execute the movement)
revise_location(X,Y):-
    current_orientation(Z),
    Z = 0, X < 8,
    retractall(current_location(_,_)),
    NewX is X + 1,
    assert(current_location(NewX ,Y)).
revise_location(X,Y):-
    current_orientation(Z),
    Z = 90, Y < 8,
    retractall(current_location(_,_)),
    NewY is Y + 1,
    assert(current_location(X ,NewY)).
revise_location(X,Y):-
    current_orientation(Z),
    Z = 180, X>= 2,
    retractall(current_location(_,_)),
    NewX is X - 1,
    assert(current_location(NewX ,Y)).
revise_location(X,Y):-
    current_orientation(Z),
    Z = 270, Y>= 2,
    retractall(current_location(_,_)),
    NewY is Y - 1,
    assert(current_location(X ,NewY)).

safelocation(1,1).
safelocation(1,2).
a_question(X,Y, Value):-
    \+ safelocation(X, Y), Value is 1.
