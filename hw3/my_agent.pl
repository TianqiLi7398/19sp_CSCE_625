%my_agent.pl

%   'this procedure requires the external definition of two procedures:
%
%     init_agent: called after new world is initialized.  should perform
%                 any needed agent initialization.
%
%     run_agent(percept,action): given the current percept, this procedure
%                 should return an appropriate action, which is then
%                 executed.
%
% This is what should be fleshed out'

init_agent:-
    retractall(safelocation(_,_)),
    retractall(gobackOrig(_)),
    retractall((meetWump(_))),
    retractall(meetPit(_)),
    retractall(wumpDead(_)),
    retractall(current_location(_,_)),
    retractall(current_orientation(_)),
    retractall(arrow(_)),
    retractall(pickGold(_)),
    retractall(num_actions(_)),
    retractall(visited(_,_)),
    assert(safelocation(1,1)),
    assert(gobackOrig(0)),
    assert(meetWump(0)),
    assert(meetPit(0)),
    assert(wumpDead(0)),
    assert(current_location(1,1)),
    assert(current_orientation(0)),
    assert(pickGold(0)),
    assert(arrow(1)),
    retractall(wumpus_check(_,_)),
    format('\n=====================================================\n'),
    format('This is init_agent:\n\tIt gets called once, use it for your initialization\n\n'),
    format('=====================================================\n\n'),
    assert(num_actions(0)),
    assert(visited(1,1)).



%run_agent(Percept, Action ):-
% 'Percept = [Stench,Breeze,Glitter,Bump,Scream]'
% The five parameters are either 'yes' or 'no'.

% when meet gold, grab
run_agent([_,_,yes,_,_], grab ):-
    !,
    current_location(X,Y),
    location_safe(X, Y),
    pickGold(Golds),
    Newgold is Golds + 1,
    retractall(pickGold(Golds)),
    assert(pickGold(Newgold)),
    current_location(X,Y),
    add_safe_location(X,Y),
    update_action_num,
    format('I got a Gold!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n'),
    format('Life is hard, let\'s go home...\n\n').

run_agent(_, climb):-
    (gobackOrig(1); pickGold(Gold), Gold > 0),
    current_location(X,Y), X == 1, Y == 1,
    !, format('get out!!! \n\n').

% first let us design the exploring mode
run_agent([Stench,no,no,no,no], goforward ):-
    gobackOrig(0), (Stench == no; wumpDead(1)),
    current_location(X,Y),current_orientation(Z),
    (Z == 0, X0 is X + 1, X0 < 5, \+ visited(X0, Y);
    Z == 90, Y0 is Y + 1, Y0 < 5, \+ visited(X, Y0);
    Z == 180, X0 is X - 1, X0 > 0, \+ visited(X0, Y);
    Z == 270, Y0 is Y - 1, Y0 > 0, \+ visited(X, Y0);
    Z == 0, Y1 is Y + 1, Y2 is Y - 1, X < 4,
    (visited(X, Y1); \+safelocation(X, Y1)), (visited(X, Y2); \+safelocation(X, Y2));
    Z == 90, X1 is X + 1, X2 is X - 1, Y < 4,
    (visited(X1, Y); \+safelocation(X1, Y)), (visited(X2, Y); \+safelocation(X2, Y));
    Z == 180, Y1 is Y + 1, Y2 is Y - 1, X > 1,
    (visited(X, Y1); \+safelocation(X, Y1)), (visited(X, Y2); \+safelocation(X, Y2));
    Z == 270, X1 is X + 1, X2 is X - 1, Y > 1,
    (visited(X1, Y); \+safelocation(X1, Y)), (visited(X2, Y); \+safelocation(X2, Y))),
    !,
    update_action_num, location_safe(X,Y),
    revise_location(X,Y,Z), assert(visited(X,Y)),
    display_world.

run_agent([Stench,no,no,no,no], turnleft):-
    gobackOrig(0), (Stench == no; wumpDead(1)),
    current_location(X,Y),  current_orientation(Z),
    (Z == 0, X0 is X + 1, X0 == 5, Y < 3;
    Z == 90, Y0 is Y + 1, Y0 == 5, X > 2;
    Z == 180, X0 is X - 1, X0 == 0, Y > 2;
    Z == 270, Y0 is Y - 1, Y0 == 0, X < 3;
    Z == 0, X0 is X + 1, visited(X0, Y);
    Z == 90, Y0 is Y + 1, visited(X, Y0);
    Z == 180, X0 is X - 1, visited(X0, Y);
    Z == 270, Y0 is Y - 1, visited(X, Y0)),
    !,
    location_safe(X,Y),
    ori_turnleft, update_action_num.

run_agent([Stench,no,no,no,no], turnright):-
    gobackOrig(0), (Stench == no; wumpDead(1)),
    current_location(X,Y),  current_orientation(Z),
    (Z == 0, X0 is X + 1, X0 == 5, Y > 2;
    Z == 90, Y0 is Y + 1, Y0 == 5, X < 3;
    Z == 180, X0 is X - 1, X0 == 0, Y < 3;
    Z == 270, Y0 is Y - 1, Y0 == 0, X > 2;

    Z == 0, X0 is X + 1, visited(X0, Y),
    Y1 is Y + 1, (visited(X, Y1); \+ safelocation(X, Y1)),
    Y2 is Y - 1, \+ visited(X, Y2), safelocation(X, Y2);

    Z == 90, Y0 is Y + 1, visited(X, Y0),
    X1 is X + 1, (visited(X1, Y); \+ safelocation(X1, Y)),
    X2 is X - 1, \+ visited(X2, Y), safelocation(X2, Y);

    Z == 180, X0 is X - 1, visited(X0, Y),
    Y1 is Y - 1, (visited(X, Y1); \+ safelocation(X, Y1)),
    Y2 is Y + 1, \+ visited(X, Y2), safelocation(X, Y2);

    Z == 270, Y0 is Y - 1, visited(X, Y0),
    X1 is X - 1, (visited(X1, Y); \+ safelocation(X1, Y)),
    X2 is X + 1, \+ visited(X2, Y), safelocation(X2, Y)),
    !,
    location_safe(X,Y),
    ori_turnright, update_action_num.

% the point go back
run_agent(_, grab):-
    gobackOrig(0),
    num_actions(N), current_location(X, Y),
    M is N + 2 * (X + Y), M > 120,
    !,
    retract(gobackOrig(0)), assert(gobackOrig(1)).


% try to go back
run_agent([_,_,no, _,_], goforward):-
    (gobackOrig(1); pickGold(Gold), Gold > 0),
    current_location(X,Y),current_orientation(Z),
    Sum is X + Y, Sum > 2,
    (Z == 0, X0 is X + 1, safelocation(X0, Y);
    Z == 90, Y0 is Y + 1, safelocation(X, Y0);
    Z == 180, X0 is X - 1, safelocation(X0, Y);
    Z == 270, Y0 is Y - 1,  safelocation(X, Y0);
    Z == 0, X0 is X + 1, visited(X0, Y);
    Z == 90, Y0 is Y + 1, visited(X, Y0);
    Z == 180, X0 is X - 1, visited(X0, Y);
    Z == 270, Y0 is Y - 1,  visited(X, Y0)
    ),
    !,
    revise_location(X,Y,Z), display_world.

% when to turn, try to turn the place is safe, closer to (1,1)
run_agent([_,_,no, _,_], turnright):-
    (gobackOrig(1); pickGold(Gold), Gold > 0),
    current_location(X,Y), current_orientation(Z),
    Sum is X + Y, Sum > 2,
    (Z == 0, X0 is X + 1, \+ safelocation(X0, Y);
    Z == 270, Y0 is Y - 1, \+ safelocation(X, Y0)
    ),
    !,
    ori_turnright.

run_agent([_,_,no, _,_], turnright):-
    (gobackOrig(1); pickGold(Gold), Gold > 0),
    current_location(X,Y), current_orientation(Z),
    Sum is X + Y, Sum > 2,
    (Z == 90, Y0 is Y + 1, \+ safelocation(X, Y0);
    Z == 180, X0 is X - 1, \+ safelocation(X0, Y)
    ),
    !,
    ori_turnright.

% last step, climb out!!



% stench =======================================================================
% stench =======================================================================
%|     |  X  |     |
%--------------------
%|  X  |  ^  |  X  |
%--------------------
%|  B  |     |  B  |
% meet the wumpus
% it takes procedure to fully analyze, first time we get stench, try to determine
% if 2 B cells in the above graph has stench
run_agent([yes,no, no, no, no], turnleft):-
    current_location(X,Y),
    current_orientation(Z),
    meetWump(0),        % first time see wumpus
    retractall(wumpus_check(_,_)),
    set_checkpoints(X, Y, Z),  % the supectful cells
    aggregate_all(count, wumpus_check(A,B), Count),
    Count == 1, wumpus_check(A,B),
    (X == A, Z == 0;
    X == A, Z == 180;
    Y == B, Z == 90;
    Y == B, Z == 270),
    !,
    retract(meetWump(0)),
    assert(meetWump(1)),
    ori_turnleft,

    update_action_num.


% stench,  =======================================================================
% only 1 wumpus check point, and facing the person
% when the only wumpus check is facing the person, first time meet stench, shoot it!
run_agent([yes,no, no, no, no], shoot):-

    meetWump(0), arrow(1),

    current_location(X,Y),
    current_orientation(Z),
    retractall(wumpus_check(_,_)),
    set_checkpoints(X, Y, Z),  % the supectful cells
    aggregate_all(count, wumpus_check(A,B), Count),
    Count == 1, wumpus_check(A,B),
    (X0 is X + 1, X0 == A, Y == B, Z == 0;
    X0 is X - 1, X0 == A, Y == B, Z == 180;
    Y0 is Y + 1, Y0 == B, X == A, Z == 90;
    Y0 is Y - 1, Y0 == B, X == A, Z == 270),
    !,
    retract(meetWump(0)),
    assert(meetWump(1)),
    retract(arrow(1)),
    assert(arrow(0)),
    update_action_num.


% stench =======================================================================
% second step after shoot + only Wumpus facing the people
run_agent([yes,no, no, no, yes], goforward):-
    arrow(0),current_location(X,Y),
    meetWump(1),
    !,
    assert(occupy_wumpus(1)), location_safe(X,Y),
    update_action_num,current_orientation(Z),
    revise_location(X,Y,Z), display_world, assert(visited(X,Y)),
    retract(wumpDead(0)), assert(wumpDead(1)).

% stench =======================================================================
% only 1 suspectful spot and it is on left/right side of the person
% CONDITION B

%
run_agent([yes,no, no, no, no], turnleft):-
    current_location(X,Y),
    current_orientation(Z),
    meetWump(0),        % first time see wumpus
    retractall(wumpus_check(_,_)),
    set_checkpoints(X, Y, Z),  % the supectful cells
    aggregate_all(count, wumpus_check(A,B), Count),
    Count == 1,wumpus_check(A,B),
    (Z == 0, Y0 is Y + 1, X == A, B == Y0;
    Z == 90, A0 is A + 1, X == A0, B == Y;
    Z == 180, Y0 is Y - 1,X == A , B == Y0;
    Z == 270, A0 is A - 1, X == A0, B == Y),
    !,
    retract(meetWump(0)),ori_turnleft,
    assert(meetWump(1)),
    assert(ready_to_shoot(1)),
    update_action_num.

run_agent([yes,no, no, no, no], turnright):-
    current_location(X,Y),
    current_orientation(Z),
    meetWump(0),
    retractall(wumpus_check(_,_)),
    set_checkpoints(X, Y, Z),  % the supectful cells
    aggregate_all(count, wumpus_check(A,B), Count),
    Count == 1,wumpus_check(A,B),
    (Z == 0, Y0 is Y - 1, X == A, B == Y0;
    Z == 90, A0 is A - 1, X == A0, B == Y;
    Z == 180, Y0 is Y + 1,X == A , B == Y0;
    Z == 270, A0 is A + 1, X == A0, B == Y),
    !,
    retract(meetWump(0)),ori_turnright,
    assert(meetWump(1)),
    assert(ready_to_shoot(1)),
    update_action_num.




% after the the person turns to the right direction, shoot
run_agent([yes,no, no, no, no], shoot):-
    meetWump(1),  ready_to_shoot(1), arrow(1),
    !,
    retract(arrow(1)),
    assert(arrow(0)),
    retract(meetWump(1)),
    assert(meetWump(2)),
    update_action_num.

% then occupy the wumpus spot
run_agent([yes,no, no, no, yes], goforward):-
    arrow(0),
    current_location(X,Y),
    meetWump(2),
    !,
    update_action_num, assert(occupy_wumpus(1)),current_orientation(Z), location_safe(X, Y),
    revise_location(X,Y,Z), display_world, assert(visited(X,Y)),  % this is for forward action
    retract(wumpDead(0)), assert(wumpDead(1)).




% stench =======================================================================
% CONDITION C
% more than 1 wumpus suspectful cells
% C.1 first turn
run_agent([yes,no, no, no, no], turnleft):-
    current_location(X,Y), current_orientation(Z),
    meetWump(0),
    retractall(wumpus_check(_,_)),
    set_checkpoints(X, Y, Z),  % the supectful cells
    aggregate_all(count, wumpus_check(_,_), Count),
    Count > 1,
    !,
    retract(meetWump(0)),
    assert(meetWump(1)),
    ori_turnleft,
    assert(condition_C(1)),
    update_action_num.

% C.2, second turn
run_agent([yes,no, no, no, no], turnleft):-
    meetWump(1),        % first time see wumpus
    condition_C(1),
    !,
    retract(meetWump(1)),
    assert(meetWump(2)),
    ori_turnleft,
    retract(condition_C(1)),
    assert(condition_C(2)),
    update_action_num.

% C.3 go straight
run_agent([yes,no, no, no, no], goforward):-
    current_location(X, Y),
    meetWump(2),
    condition_C(2),
    !,
    retract(meetWump(2)),
    assert(meetWump(3)),
    retract(condition_C(2)),
    assert(condition_C(3)),current_orientation(Z),
    revise_location(X,Y,Z),    display_world,    assert(visited(X,Y)),
    update_action_num.

% 4. after goes back, decide which direction to go first, default is left first
% condition_C(4): wumpus has 2 or 3 points to check


%|     |  X  |     |      |     |     |     |     |     |  X  |     |
%--------------------     --------------------    --------------------
%|  X  |     |  X  |      |  X  |     |  X  |     |     |     |  X  |
%--------------------     --------------------    --------------------
%|     |  v  |     |      |     |  v  |     |     |     |  v  |     |
run_agent([no,no, no, no, no], turnleft):-
    current_location(X, Y), current_orientation(Z),meetWump(3),condition_C(3),
    (Z == 0, NewX is X + 1, NewY is Y - 1, wumpus_check(NewX, NewY);
    Z == 90, NewX is X - 1, NewY is Y - 1, wumpus_check(NewX, NewY);
    Z == 180, NewX is X - 1, NewY is Y + 1, wumpus_check(NewX, NewY);
    Z == 270, NewX is X + 1, NewY is Y + 1, wumpus_check(NewX, NewY)
    ),
    !,
    retract(meetWump(3)),
    assert(meetWump(4)),
    retract(condition_C(3)), assert(condition_C(4)),
    ori_turnleft, update_action_num.

%|     |  X  |     |
%--------------------
%|  X  |     |     |
%--------------------
%|     |  v  |     |
% condition_C(5): wumpus has 2 points to check, one is at buttom left, one on top
run_agent([no,no, no, no, no], turnright):-
    meetWump(3),condition_C(3),
    current_location(X, Y), current_orientation(Z),
    (Z == 0, NewX is X + 1, NewY is Y - 1, \+ wumpus_check(NewX, NewY);
    Z == 90, NewX is X - 1, NewY is Y - 1, \+ wumpus_check(NewX, NewY);
    Z == 180, NewX is X - 1, NewY is Y + 1, \+ wumpus_check(NewX, NewY);
    Z == 270, NewX is X + 1, NewY is Y + 1, \+ wumpus_check(NewX, NewY)
    ),
    !,
    retract(meetWump(3)),assert(meetWump(4)),
    retract(condition_C(3)), assert(condition_C(5)),
    ori_turnright, update_action_num.

% 5. then we go forward to discover
run_agent([no,no, no,  no, no], goforward):-
    meetWump(4),
    !,
    retract(meetWump(4)), assert(meetWump(5)),current_orientation(Z),
    revise_location(X,Y,Z),    display_world,    assert(visited(X,Y)),
    update_action_num.

% 6. after get to the adjecent, first check point, we found the stench, ignore pitch alongside
run_agent([yes, _, no, no, no, no], turnleft):-
    meetWump(5), condition_C(4),
    !,
    retract(meetWump(5)), assert(meetWump(6)),
    assert(wumpus_found(1)),        % this gave the hint for shoot next step
    ori_turnleft, update_action_num.

run_agent([yes, _, no,  no, no], turnright):-
    meetWump(5), condition_C(5),
    !,
    retract(meetWump(5)), assert(meetWump(6)),
    assert(wumpus_found(1)),        % this gave the hint for shoot next step
    ori_turnright, update_action_num.

% else, turn back
run_agent([no, _, no,  no, no], turnleft):-
    meetWump(5),
    current_location(X, Y), wumpus_check(A, B),
    (B == Y; A == X),
    !,
    retract(meetWump(5)),assert(meetWump(7)),
    retract(wumpus_check(A, B)), ori_turnleft,
    update_action_num.

% 7. if wumpus found, shoot,
% shoot if get stench
run_agent([yes, _, no, no,  no], shoot):-
    meetWump(6), wumpus_found(1),
    !,
    retract(arrow(1)), assert(arrow(0)),
    update_action_num.


% 8. check if shoot works
% killed the wumpus!
run_agent([yes, _, no, no, yes], goforward):-
    arrow(0),
    current_location(X,Y),
    meetWump(6),
    !,
    update_action_num, assert(occupy_wumpus(1)),current_orientation(Z), location_safe(X,Y),
    revise_location(X,Y,Z), display_world, assert(visited(X,Y)),  % this is for forward action
    retract(wumpDead(0)), assert(wumpDead(1)).

% otherwise turn the second step
run_agent([no, _, no, no,  no], turnleft):-
    meetWump(7),
    !,
    retract(meetWump(7)),assert(meetWump(8)),
    ori_turnleft,
    update_action_num.

% 9. go straight to center point

run_agent([no, _, no, no,  no], goforward):-
    meetWump(8),
    !,
    retract(meetWump(8)),assert(meetWump(9)),
    current_location(X,Y),current_orientation(Z),
    update_action_num,
    revise_location(X,Y,Z), display_world, assert(visited(X,Y)).

% 10.
%|     |  X  |     |      |     |     |     |
%--------------------     --------------------
%|  X  |     |     |      |  X  |     |     |
%--------------------     --------------------
%|     |  <  |     |      |     |  <  |     |


% D.1 go forward, bacause there is one left to check just at the left/right side
run_agent([no, no, no, no,  no], goforward):-
    meetWump(9),
    current_location(X, Y), wumpus_check(A, _),
    E is X - A,
    abs2(E, 1),
    !,
    assert(condition_D(1)),
    retract(meetWump(9)), assert(meetWump(10)),
    update_action_num,current_orientation(Z),
    revise_location(X,Y,Z), display_world, assert(visited(X,Y)).

    %|     |  X  |     |      |     |  X  |     |
    %--------------------     --------------------
    %|     |     |     |      |     |     |     |
    %--------------------     --------------------
    %|     |  <  |     |      |     |  >  |     |
% D.2 turn to the center checkpoint because the only suspectful cell is middle one
run_agent([no, no, no, no,  no], turnright):-
    meetWump(9),
    current_location(X, Y), wumpus_check(A, B), current_orientation(Z),
    E is X - A,
    \+ abs2(E, 1),
    (Z == 0, B0 is B + 2, Y == B0;
    Z == 180, A0 is A - 2, A0 == X;
    Z == 90, B0 is B - 2, Y == B0;
    Z  == 270, A0 is A + 2, A0 == X),
    !,
    retract(meetWump(9)), assert(meetWump(10)),assert(condition_D(2)),
    ori_turnright, update_action_num.

run_agent([no, no, no, no, no], turnleft):-
    meetWump(9),
    current_location(X, Y), wumpus_check(A, B), current_orientation(Z),
    E is X-A,
    \+ abs2(E, 1),
    (Z == 0, B0 is B - 2, Y == B0;
    Z == 180, A0 is A + 2, A0 == X;
    Z == 90, B0 is B + 2, Y == B0;
    Z  == 270, A0 is A - 2, A0 == X),
    !,
    retract(meetWump(9)), assert(meetWump(10)),assert(condition_D(2)),
    ori_turnleft, update_action_num.

% 11.
% D.3 if go straight, smell stench, assure the place
%|     |  X  |     |      |     |     |     |
%--------------------     --------------------
%|  X  |     |     |      |  X  |     |     |
%--------------------     --------------------
%|  <  |     |     |      |  <  |     |     |
run_agent([yes, _, no, no, no], turnright):-
    meetWump(10),
    condition_D(1),
    !,
    retract(meetWump(10)), assert(meetWump(11)),
    retract(condition_D(1)), assert(condition_D(3)),
    ori_turnright, update_action_num.

% D.4 if go straight, dont smell stench,
%|     |  X  |     |
%--------------------
%|     |     |     |
%--------------------
%|  <  |     |     |
run_agent([no, _, no, no, no], turnright):-
    meetWump(10),
    condition_D(1),
    !,
    retract(meetWump(10)), assert(meetWump(11)),
    retract(condition_D(1)), assert(condition_D(4)),
    ori_turnright, update_action_num.


    %|     |  X  |     |
    %--------------------
    %|     |     |     |
    %--------------------
    %|     |  ^  |     |
% D.2, ready to shoot
run_agent([no, _, no, no, no], shoot):-
    meetWump(10),
    condition_D(2), arrow(1),
    !,
    retract(meetWump(10)), assert(meetWump(12)),
    retract(arrow(1)), assert(arrow(0)),
    update_action_num.


% 12.

% D.3 shoot, facing the wumpus
%|     |     |     |      |     |     |     |
%--------------------     --------------------
%|  X  |     |     |      |  X  |     |     |
%--------------------     --------------------
%|  ^  |     |     |      |  ^  |     |     |
run_agent([yes, _, no, no, no], shoot):-
    meetWump(11),
    condition_D(3), arrow(1),
    !,
    retract(meetWump(11)), assert(meetWump(12)),
    retract(arrow(1)), assert(arrow(0)),
    update_action_num.

% D.4, no wumpus, goforward and get close to wumpus
%|     |  X  |     |
%--------------------
%|     |     |     |
%--------------------
%|  ^  |     |     |
run_agent([no, no, no, no, no], goforward):-
    meetWump(11),
    condition_D(4),
    !,
    retract(meetWump(11)), assert(meetWump(12)),
    update_action_num, current_location(X, Y),current_orientation(Z),
    revise_location(X,Y,Z), display_world, assert(visited(X,Y)).

% 13.
%|     |  ~  |     |
%--------------------
%|     |     |     |
%--------------------
%|     |  ^  |     |
% D.2, after shoot, wumpus dead
run_agent([no, _, no, no, yes], goforward):-
    meetWump(12),
    condition_D(2), arrow(0),
    !,
    retract(meetWump(12)), assert(meetWump(13)),
    retract(wumpDead(0)), assert(wumpDead(1)),
    update_action_num, current_location(X, Y),current_orientation(Z),
    revise_location(X,Y,Z), display_world, assert(visited(X,Y)).

% D.3 wumpus killed
%|     |     |     |      |     |     |     |
%--------------------     --------------------
%|  ~  |     |     |      |  ~  |     |     |
%--------------------     --------------------
%|  ^  |     |     |      |  ^  |     |     |
run_agent([yes, _, no, no, no, yes], goforward):-
    meetWump(12),
    condition_D(3), arrow(0),
    !,
    retract(meetWump(12)), assert(meetWump(13)),
    retract(wumpDead(0)), assert(wumpDead(1)),
    update_action_num, current_location(X, Y),current_orientation(Z),
    assert(occupy_wumpus(1)), location_safe(X,Y),
    revise_location(X,Y,Z), display_world, assert(visited(X,Y)).

% D.4, no wumpus, goforward and get close to wumpus
%|     |  X  |     |
%--------------------
%|  ^  |     |     |
%--------------------
%|     |     |     |
run_agent([no, no, no, no, no], goforward):-
    meetWump(12),
    condition_D(4),
    !,
    retract(meetWump(12)), assert(meetWump(13)),
    update_action_num, current_location(X, Y),current_orientation(Z),
    revise_location(X,Y,Z), display_world, assert(visited(X,Y)).

% D.5 dangerous ahead, need turn left
%|  !  |  X  |     |
%--------------------
%|  ^  |     |     |
%--------------------
%|     |     |     |
run_agent([no, yes, no, no, no], turnleft):-
    meetWump(12),
    condition_D(4),
    !,
    retract(meetWump(12)), assert(meetWump(13)),
    retract(condition_D(4)), assert(condition_D(5)),
    ori_turnleft, update_action_num.

% 14
%|     |  ~  |     |
%--------------------
%|     |  ^  |     |
%--------------------
%|     |     |     |
% D.2, after shoot, wumpus dead
run_agent([no, _, no, no, yes], goforward):-
    meetWump(13),
    condition_D(2), wumpDead(1),
    !,
    retract(meetWump(13)), assert(meetWump(14)),current_orientation(Z),
    update_action_num, current_location(X, Y), assert(occupy_wumpus(1)),
    revise_location(X,Y,Z), display_world, assert(visited(X,Y)),
    location_safe(X,Y).

% D.4
%|  ^  |  X  |     |
%--------------------
%|     |     |     |
%--------------------
%|     |     |     |
run_agent([yes, no, no, no, no], turnright):-
    meetWump(13),
    condition_D(4),
    !,
    retract(meetWump(13)), assert(meetWump(14)),
    update_action_num, ori_turnright.

% D.5
%|  !  |  X  |     |
%--------------------
%|  >  |     |     |
%--------------------
%|     |     |     |
run_agent([no, yes, no, no, no], goforward):-
    meetWump(13),
    condition_D(5),
    !,
    retract(meetWump(13)), assert(meetWump(14)),
    update_action_num, current_location(X, Y),current_orientation(Z),
    revise_location(X,Y,Z), display_world, assert(visited(X,Y)).

% 15
% D.4, shoot!
%|  >  |  X  |     |
%--------------------
%|     |     |     |
%--------------------
%|     |     |     |
run_agent([yes, no, no, no, no], shoot):-
    meetWump(14),
    condition_D(4), arrow(1),
    !,
    retract(meetWump(14)), assert(meetWump(16)),
    retract(arrow(1)), assert(arrow(0)),
    update_action_num.

% D.5 turn to face the wumpus
%|  !  |  X  |     |
%--------------------
%|     |  >  |     |
%--------------------
%|     |     |     |
run_agent([yes, no, no, no, no], turnleft):-
    meetWump(14),
    condition_D(5),
    !,
    retract(meetWump(14)), assert(meetWump(15)),
    update_action_num, ori_turnleft.

% 16
% D.5 turn to face the wumpus
%|  !  |  X  |     |
%--------------------
%|     |  ^  |     |
%--------------------
%|     |     |     |
run_agent([yes, no, no, no, no], shoot):-
    meetWump(15),
    condition_D(5), arrow(1),
    !,
    retract(meetWump(15)), assert(meetWump(16)),
    retract(arrow(1)), assert(arrow(0)),
    update_action_num.

% 17, just go ahead...
run_agent([yes, no, no, no, yes], goforward):-
    meetWump(16), arrow(1),
    !,
    retract(arrow(1)), assert(arrow(0)),current_orientation(Z),
    update_action_num, current_location(X, Y), assert(occupy_wumpus(1)),
    revise_location(X,Y,Z), display_world, assert(visited(X,Y)).

% stench ends=======================================================================


% breeze =======================================================================
% meet breeze, turn around and run!!!!!
run_agent([_, yes, no, no, no], turnleft):-
    \+ meetWump(12), meetPit(0),
    current_location(X,Y), current_orientation(Z),
    set_pit_check(X, Y, Z),
    !,

    retractall(meetPit(_)),

    assert(meetPit(1)),

    ori_turnleft,

    update_action_num.

% second turn
run_agent([_, yes, no, no, no], turnleft):-
    meetPit(1),
    !,
    retract(meetPit(1)), assert(meetPit(2)),
    ori_turnleft, update_action_num,
    format('second time pit, turn left').

% then run
run_agent([_, yes, no, no, no], goforward):-
    meetPit(2),
    !,
    update_action_num, current_location(X, Y),
    retractall(meetPit(_)),assert(meetPit(0)),
    current_orientation(Z),
    revise_location(X,Y,Z), display_world.

% check pit places once get breeze
set_pit_check(X, Y, 0):-
    Xn is X + 1, Yn is Y + 1, Ym is Y - 1,
    add_pit_check(Xn, Y),
    add_pit_check(X, Yn),
    add_pit_check(X, Ym).

set_pit_check(X, Y, 90):-
    Yn is Y + 1, Xn is X + 1, Xm is X - 1,
    add_pit_check(X, Yn),
    add_pit_check(Xn, Y),
    add_pit_check(Xm, Y).

set_pit_check(X, Y, 180):-
    Xn is X - 1, Yn is Y + 1, Ym is Y - 1,
    add_pit_check(Xn, Y),
    add_pit_check(X, Yn),
    add_pit_check(X, Ym).

set_pit_check(X, Y, 270):-
    Yn is Y - 1, Xn is X + 1, Xm is X - 1,
    add_pit_check(X, Yn),
    add_pit_check(Xn, Y),
    add_pit_check(Xm, Y).


% add suspectful Wumpus cells,
add_pit_check(X, Y):-
    \+ safelocation(X, Y),
    X > 0, X < 5, Y > 0, Y < 5,
    !,
    assert(pit_check(X,Y));
    !.




% this is used with turn left/right action
ori_turnleft:-
    current_orientation(Z),
    retractall(current_orientation(_)),
    NewZ is (Z + 90) mod 360, assert(current_orientation(NewZ)).

ori_turnright:-
    current_orientation(Z),
    retractall(current_orientation(_)),
    NewZ is (Z - 90) mod 360, assert(current_orientation(NewZ)).

% check wumpus places once get stench
set_checkpoints(X, Y, 0):-
    Xn is X + 1, Yn is Y + 1, Ym is Y - 1,
    add_wumpus_check(Xn, Y),
    add_wumpus_check(X, Yn),
    add_wumpus_check(X, Ym).

set_checkpoints(X, Y, 90):-
    Yn is Y + 1, Xn is X + 1, Xm is X - 1,
    add_wumpus_check(X, Yn),
    add_wumpus_check(Xn, Y),
    add_wumpus_check(Xm, Y).

set_checkpoints(X, Y, 180):-
    Xn is X - 1, Yn is Y + 1, Ym is Y - 1,
    add_wumpus_check(Xn, Y),
    add_wumpus_check(X, Yn),
    add_wumpus_check(X, Ym).

set_checkpoints(X, Y, 270):-
    Yn is Y - 1, Xn is X + 1, Xm is X - 1,
    add_wumpus_check(X, Yn),
    add_wumpus_check(Xn, Y),
    add_wumpus_check(Xm, Y).


% add suspectful Wumpus cells,
add_wumpus_check(X, Y):-
    \+ safelocation(X, Y), \+ pit_check(X,Y),
    X > 0, X < 5, Y > 0, Y < 5,
    !,
    assert(wumpus_check(X,Y));
    !.

location_safe(X, Y):-
    X0 is X -1, Y0 is Y - 1, X1 is X + 1, Y1 is Y + 1,
    add_safe_location(X0,Y), add_safe_location(X1,Y),
    add_safe_location(X,Y1), add_safe_location(X,Y0).

add_safe_location(X,Y):-
    X>=1, Y>=1, X < 5, Y < 5,
    !,
    assert(safelocation(X,Y));
    !.

% when move (means action is goforward, execute the movement)
revise_location(X,Y,0):-
    X < 4,
    !,
    retractall(current_location(_,_)),
    NewX is X + 1,
    assert(current_location(NewX ,Y));
    !.
revise_location(X,Y,90):-
    Y < 4,
    !,
    retractall(current_location(_,_)),
    NewY is Y + 1,
    assert(current_location(X ,NewY));
    !.
revise_location(X,Y,180):-
    X > 1,
    !,
    retractall(current_location(_,_)),
    NewX is X - 1,
    assert(current_location(NewX ,Y));
    !.
revise_location(X,Y,270):-
    Y > 1,
    !,
    retractall(current_location(_,_)),
    NewY is Y - 1,
    assert(current_location(X ,NewY));
    !.

update_action_num:-
    num_actions(X),
    NewX is X + 1,
    retractall(num_actions(_)),
    assert(num_actions(NewX)).

abs2(X,Y) :- X < 0 -> Y is -X ; Y = X.
