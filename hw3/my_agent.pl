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
    assert(safelocation(1,1)),
    assert(gobackOrig(0)),
    assert(meetWump(0)),
    assert(wumpDead(0)),
    assert(current_location(1,1)),
    assert(current_orientation(0)),
    assert(pickGold(0)),
    assert(arrow(1)),
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
    update_action_num,current_location(X,Y),
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

% first let us design the exploring mode
run_agent([Stench,no,no,no,no], goforward ):-
    gobackOrig(0), (Stench == no; wumpDead(1)),
    format('go straight np\n\n'),
    current_location(X,Y), current_orientation(Z),
    (Z == 0, X0 is X + 1, X0 <9;
    Z == 90, Y0 is Y + 1, Y0 <9;
    Z == 180, X0 is X - 1, X0 > 0;
    Z == 270, Y0 is Y - 1, Y0 > 0),
    !,
    update_action_num, location_safe(X,Y),
    revise_location(X,Y), assert(visited(X,Y)),
    display_world.

run_agent([Stench,no,no,no,no], turnleft):-
    gobackOrig(0), (Stench == no; wumpDead(1)),
    update_action_num, current_location(X,Y), location_safe(X,Y), current_orientation(Z),
    (Z == 0, X0 is X + 1, X0 == 9, Y < 5;
    Z == 90, Y0 is Y + 1, Y0 == 9, X > 4;
    Z == 180, X0 is X - 1, X0 == 0, Y > 4;
    Z == 270, Y0 is Y - 1, Y0 == 0, X < 5;
    Z == 0, X0 is X + 1, visited(X0, Y);
    Z == 90, Y0 is Y + 1, visited(X, Y0);
    Z == 180, X0 is X - 1, visited(X0, Y);
    Z == 270, Y0 is Y - 1, visited(X, Y0)),
    ori_turnleft, update_action_num.

run_agent([Stench,no,no,no,no], turnright):-
    gobackOrig(0), (Stench == no; wumpDead(1)),
    update_action_num, current_location(X,Y), location_safe(X,Y), current_orientation(Z),
    (Z == 0, X0 is X + 1, X0 == 9, Y == 8;
    Z == 90, Y0 is Y + 1, Y0 == 9, X == 1;
    Z == 180, X0 is X - 1, X0 == 0, Y == 1;
    Z == 270, Y0 is Y - 1, Y0 == 0, X == 8),
    ori_turnright, update_action_num.

% the point go back
run_agent(_, grab):-
    gobackOrig(0),
    num_actions(N), current_location(X, Y),
    M is N + 2 * (X + Y), M > 128,
    retract(gobackOrig(0)), assert(gobackOrig(1)).

% try to go back
run_agent([_,_,no, _,_], goforward):-
    (gobackOrig(1); pickGold(Gold), Gold > 0),
    current_location(X,Y), current_orientation(Z),
    Sum is X + Y, Sum > 2,
    (Z == 0, X0 is X + 1, safelocation(X0, Y);
    Z == 90, Y0 is Y + 1, safelocation(X, Y0);
    Z == 180, X0 is X - 1, safelocation(X0, Y);
    Z == 270, Y0 is Y - 1,  safelocation(X, Y0);
    Z == 0, X0 is X + 1, visited(X0, Y);
    Z == 90, Y0 is Y + 1, visited(X, Y0);
    Z == 180, X0 is X - 1, svisited(X0, Y);
    Z == 270, Y0 is Y - 1,  visited(X, Y0)
    ),
    revise_location(X,Y), display_world.

% when to turn, try to turn the place is safe, closer to (1,1)
run_agent(_, turnright):-
    (gobackOrig(1); pickGold(Gold), Gold > 0),
    current_location(X,Y), current_orientation(Z),
    Sum is X + Y, Sum > 2,
    (Z == 0, X0 is X + 1, \+ safelocation(X0, Y);
    Z == 270, Y0 is Y - 1, \+ safelocation(X, Y0)
    ),
    revise_location(X,Y).

run_agent(_, turnright):-
    (gobackOrig(1); pickGold(Gold), Gold > 0),
    current_location(X,Y), current_orientation(Z),
    Sum is X + Y, Sum > 2,
    (Z == 90, Y0 is Y + 1, \+ safelocation(X, Y0);
    Z == 180, X0 is X - 1, \+ safelocation(X0, Y)
    ),
    revise_location(X,Y).

% last step, climb out!!
run_agent(_, climb):-
    (gobackOrig(1); pickGold(Gold), Gold > 0),
    current_location(X,Y), X == 1, Y == 1.


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
run_agent([yes,no, no, no, no, no], turnleft):-
    current_location(X,Y),
    current_orientation(Z),
    meetWump(0),        % first time see wumpus
    retract(meetWump(0)),
    assert(meetWump(1)),
    set_checkpoints(X, Y, Z),  % the supectful cells
    aggregate_all(count, wumpus_check(A,B), Count),
    Count == 1, wumpus_check(A,B), X == A, Z == 0,
    ori_turnleft,
    NextX is X-1,
    assert(nextcell(NextX, Y)),
    update_action_num.

run_agent([yes,no, no, no, no, no], turnleft):-
    current_location(X,Y),
    current_orientation(Z),
    meetWump(0),        % first time see wumpus
    retract(meetWump(0)),
    assert(meetWump(1)),
    set_checkpoints(X, Y, Z),  % the supectful cells
    aggregate_all(count, wumpus_check(A,B), Count),
    Count == 1, wumpus_check(A,B), X == A, Z == 180,
    ori_turnleft,
    NextX is X+1,
    assert(nextcell(NextX, Y)),
    update_action_num.

run_agent([yes,no, no, no, no, no], turnleft):-
    current_location(X,Y),
    current_orientation(Z),
    meetWump(0),        % first time see wumpus
    retract(meetWump(0)),
    assert(meetWump(1)),
    set_checkpoints(X, Y, Z),  % the supectful cells
    aggregate_all(count, wumpus_check(A,B), Count),
    Count == 1, wumpus_check(A,B), Y = B, Z == 90,
    ori_turnleft,
    NextY is Y-1,
    assert(nextcell(X, NextY)),
    update_action_num.

run_agent([yes,no, no, no, no, no], turnleft):-
    current_location(X,Y),
    current_orientation(Z),
    meetWump(0),        % first time see wumpus
    retract(meetWump(0)),
    assert(meetWump(1)),
    set_checkpoints(X, Y, Z),  % the supectful cells
    aggregate_all(count, wumpus_check(A,B), Count),
    Count == 1, wumpus_check(A,B), Y == B, Z == 270,
    ori_turnleft,
    NextY is Y+1,
    assert(nextcell(X, NextY)),
    update_action_num.

% stench,  =======================================================================
% only 1 wumpus check point, and facing the person
% when the only wumpus check is facing the person, first time meet stench, shoot it!
run_agent([yes,no, no, no, no, no], shoot):-
    retract(arrow(1)),
    assert(arrow(0)),
    current_location(X,Y),
    current_orientation(Z),
    meetWump(0),        % first time see wumpus
    retract(meetWump(0)),
    assert(meetWump(1)),
    set_checkpoints(X, Y, Z),  % the supectful cells
    aggregate_all(count, wumpus_check(A,B), Count),
    Count == 1, wumpus_check(A,B),
    (Y == B, Z == 0;
    Y == B, Z == 180;
    X == A, Z == 90;
    X == A, Z == 270),
    update_action_num.


% stench =======================================================================
% second step after shoot + only Wumpus facing the people
run_agent([yes,no, no, no, no, yes], goforward):-
    arrow(0),current_location(X,Y),
    meetWump(1), retract(meetWump(1)),assert(meetWump(2)),
    assert(occupy_wumpus(1)),
    update_action_num,
    revise_location(X,Y), display_world, assert(visited(X,Y)),
    retract(wumpDead(0)), assert(wumpDead(1)).

% stench =======================================================================
% only 1 suspectful spot and it is on left/right side of the person
% CONDITION B

% angle = 0
run_agent([yes,no, no, no, no, no], turnleft):-
    current_location(X,Y),
    current_orientation(Z),
    meetWump(0),        % first time see wumpus
    retract(meetWump(0)),
    assert(meetWump(1)),
    set_checkpoints(X, Y, Z),  % the supectful cells
    aggregate_all(count, wumpus_check(A,B), Count),
    Count == 1, ori_turnleft,
    (Z = 0, Y0 is Y + 1, X == A, B == Y0;
    Z = 90, A0 is A + 1, X == A0, B == Y;
    Z = 180, Y0 is Y - 1,X == A , B == Y0;
    Z = 270, A0 is A - 1, X == A0, B == Y),
    asseret(ready_to_shoot(1)),
    update_action_num,
    assert(previous_action(left)).

run_agent([yes,no, no, no, no, no], turnright):-
    current_location(X,Y),
    current_orientation(Z),
    meetWump(0),        % first time see wumpus
    retract(meetWump(0)),
    assert(meetWump(1)),
    set_checkpoints(X, Y, Z),  % the supectful cells
    aggregate_all(count, wumpus_check(A,B), Count),
    Count == 1, ori_turnright,
    (Z = 0, Y0 is Y - 1, X == A, B == Y0;
    Z = 90, A0 is A - 1, X == A0, B == Y;
    Z = 180, Y0 is Y + 1, X == A , B == Y0;
    Z = 270, A0 is A + 1, X == A0, B == Y),
    asseret(ready_to_shoot(1)),
    update_action_num,
    assert(previous_action(right)).




% after the the person turns to the right direction, shoot
run_agent([yes,no, no, no, no, no], shoot):-
    meetWump(1),        % first time see wumpus
    retract(meetWump(1)),
    assert(meetWump(2)),
    ready_to_shoot(1),
    update_action_num.

% then occupy the wumpus spot
run_agent([yes,no, no, no, no, yes], goforward):-
    arrow(0),
    current_location(X,Y),
    meetWump(2),        % first time see wumpus
    retract(meetWump(2)),
    assert(meetWump(3)),
    update_action_num, assert(occupy_wumpus(1)),
    revise_location(X,Y), display_world, assert(visited(X,Y)),  % this is for forward action
    retract(wumpDead(0)), assert(wumpDead(1)).




% stench =======================================================================
% CONDITION C
% more than 1 wumpus suspectful cells
% C.1 first turn
run_agent([yes,no, no, no, no, no], turnleft):-
    current_location(X,Y),
    meetWump(0),        % first time see wumpus
    retract(meetWump(0)),
    assert(meetWump(1)),
    set_checkpoints(X, Y, Z),  % the supectful cells
    aggregate_all(count, wumpus_check(A,B), Count),
    Count > 1,
    ori_turnleft,
    assert(condition_C(1)),
    update_action_num.

% C.2, second turn
run_agent([yes,no, no, no, no, no], turnleft):-
    meetWump(1),        % first time see wumpus
    retract(meetWump(1)),
    assert(meetWump(2)),
    ori_turnleft, condition_C(1),
    retract(condition_C(1)),
    assert(condition_C(2)),
    update_action_num.

% C.3 go straight
run_agent([yes,no, no, no, no, no], goforward):-
    current_location(X, Y),
    meetWump(2),
    retract(meetWump(2)),
    assert(meetWump(3)),
    condition_C(2),
    retract(condition_C(2)),
    assert(condition_C(3)),
    revise_location(X,Y),    display_world,    assert(visited(X,Y)),
    update_action_num.

% 4. after goes back, decide which direction to go first, default is left first
% condition_C(4): wumpus has 2 or 3 points to check


%|     |  X  |     |      |     |     |     |     |     |  X  |     |
%--------------------     --------------------    --------------------
%|  X  |     |  X  |      |  X  |     |  X  |     |     |     |  X  |
%--------------------     --------------------    --------------------
%|     |  v  |     |      |     |  v  |     |     |     |  v  |     |
run_agent([no,no, no, no, no, no], turnleft):-
    current_location(X, Y), current_orientation(Z),
    (Z == 0, NewX is X + 1, NewY is Y - 1, wumpus_check(NewX, NewY);
    Z == 90, NewX is X - 1, NewY is Y - 1, wumpus_check(NewX, NewY);
    Z == 180, NewX is X - 1, NewY is Y + 1, wumpus_check(NewX, NewY);
    Z == 270, NewX is X + 1, NewY is Y + 1, wumpus_check(NewX, NewY)
    ),
    meetWump(3),
    retract(meetWump(3)),
    assert(meetWump(4)),
    condition_C(3), retract(condition_C(3)), assert(condition_C(4)),
    ori_turnleft, update_action_num.

%|     |  X  |     |
%--------------------
%|  X  |     |     |
%--------------------
%|     |  v  |     |
% condition_C(5): wumpus has 2 points to check, one is at buttom left, one on top
run_agent([no,no, no, no, no, no], turnright):-
    current_location(X, Y), current_orientation(Z),
    (Z == 0, NewX is X + 1, NewY is Y - 1, \+ wumpus_check(NewX, NewY);
    Z == 90, NewX is X - 1, NewY is Y - 1, \+ wumpus_check(NewX, NewY);
    Z == 180, NewX is X - 1, NewY is Y + 1, \+ wumpus_check(NewX, NewY);
    Z == 270, NewX is X + 1, NewY is Y + 1, \+ wumpus_check(NewX, NewY)
    ),
    meetWump(3),
    retract(meetWump(3)),
    assert(meetWump(4)),
    condition_C(3),retract(condition_C(3)), assert(condition_C(5)),
    ori_turnright, update_action_num.

% 5. then we go forward to discover
run_agent([no,no, no, no, no, no], goforward):-
    meetWump(4), retract(meetWump(4)), assert(meetWump(5)),
    revise_location(X,Y),    display_world,    assert(visited(X,Y)),
    update_action_num.

% 6. after get to the adjecent, first check point, we found the stench, ignore pitch alongside
run_agent([yes, _, no, no, no, no], turnleft):-
    meetWump(5), retract(meetWump(5)), assert(meetWump(6)),
    condition_C(4), assert(wumpus_found(1)),        % this gave the hint for shoot next step
    ori_turnleft, update_action_num.

run_agent([yes, _, no, no, no, no], turnright):-
    meetWump(5), retract(meetWump(5)), assert(meetWump(6)),
    condition_C(5), assert(wumpus_found(1)),        % this gave the hint for shoot next step
    ori_turnright, update_action_num.

% else, turn back
run_agent([no, _, no, no, no, no], turnleft):-
    meetWump(5), retract(meetWump(5)),assert(meetWump(7)),
    current_location(X, Y), wumpus_check(A, B),
    (B == Y; A == X),
    retract(wumpus_check(A, B)), ori_turnleft,
    update_action_num.

% 7. if wumpus found, shoot,
% shoot if get stench
run_agent([yes, _, no, no, no, no], shoot):-
    meetWump(6), retract(arrow(1)), assert(arrow(0)), wumpus_found(1),
    update_action_num.


% 8. check if shoot works
% killed the wumpus!
run_agent([yes, _, no, no, no, yes], goforward):-
    arrow(0),
    current_location(X,Y),
    meetWump(6),
    retract(meetWump(6)),
    assert(meetWump(7)),
    update_action_num, assert(occupy_wumpus(1)),
    revise_location(X,Y), display_world, assert(visited(X,Y)),  % this is for forward action
    retract(wumpDead(0)), assert(wumpDead(1)).

% otherwise turn the second step
run_agent([no, _, no, no, no, no], turnleft):-
    meetWump(7), retract(meetWump(7)),assert(meetWump(8)),
    ori_turnleft,
    update_action_num.

% 9. go straight to center point

run_agent([no, _, no, no, no, no], goforward):-
    meetWump(8), retract(meetWump(8)),assert(meetWump(9)),
    current_location(X,Y),
    condition_C(5),
    update_action_num,
    revise_location(X,Y), display_world, assert(visited(X,Y)).

% 10.
%|     |  X  |     |      |     |     |     |
%--------------------     --------------------
%|  X  |     |     |      |  X  |     |     |
%--------------------     --------------------
%|     |  <  |     |      |     |  <  |     |


% D.1 go forward, bacause there is one left to check just at the left/right side
run_agent([no, no, no, no, no, no], goforward):-
    meetWump(9), retract(meetWump(9)), assert(meetWump(10)),
    current_location(X, Y), wumpus_check(A, B),
    assert(condition_D(1)),
    abs2(X-A, 1),
    update_action_num,
    revise_location(X,Y), display_world, assert(visited(X,Y)).

    %|     |  X  |     |      |     |  X  |     |
    %--------------------     --------------------
    %|     |     |     |      |     |     |     |
    %--------------------     --------------------
    %|     |  <  |     |      |     |  >  |     |
% D.2 turn to the center checkpoint because the only suspectful cell is middle one
run_agent([no, no, no, no, no, no], turnright):-
    meetWump(9), retract(meetWump(9)), assert(meetWump(10)),
    current_location(X, Y), wumpus_check(A, B), current_orientation(Z),
    assert(condition_D(2)),
    \+ abs2(X-A, 1),
    (Z == 0, B0 is B + 2, Y == B0;
    Z == 180, A0 is A - 2, A0 == X;
    Z == 90, B0 is B - 2, Y == B0;
    Z  == 270, A0 is A + 2, A0 == X),
    ori_turnright, update_action_num.

run_agent([no, no, no, no, no, no], turnleft):-
    meetWump(9), retract(meetWump(9)), assert(meetWump(10)),
    current_location(X, Y), wumpus_check(A, B), current_orientation(Z),
    assert(condition_D(2)),
    \+ abs2(X-A, 1),
    (Z == 0, B0 is B - 2, Y == B0;
    Z == 180, A0 is A + 2, A0 == X;
    Z == 90, B0 is B + 2, Y == B0;
    Z  == 270, A0 is A - 2, A0 == X),
    ori_turnleft, update_action_num.

% 11.
% D.3 if go straight, smell stench, assure the place
%|     |  X  |     |      |     |     |     |
%--------------------     --------------------
%|  X  |     |     |      |  X  |     |     |
%--------------------     --------------------
%|  <  |     |     |      |  <  |     |     |
run_agent([yes, _, no, no, no, no], turnright):-
    meetWump(10), retract(meetWump(10)), assert(meetWump(11)),
    condition_D(1), retract(condition_D(1)), assert(condition_D(3)),
    ori_turnleft, update_action_num.

% D.4 if go straight, dont smell stench, assure the place
%|     |  X  |     |
%--------------------
%|     |     |     |
%--------------------
%|  <  |     |     |
run_agent([no, _, no, no, no, no], turnright):-
    meetWump(10), retract(meetWump(10)), assert(meetWump(11)),
    condition_D(1), retract(condition_D(1)), assert(condition_D(4)),
    ori_turnleft, update_action_num.


    %|     |  X  |     |
    %--------------------
    %|     |     |     |
    %--------------------
    %|     |  ^  |     |
% D.2, ready to shoot
run_agent([no, _, no, no, no, no], shoot):-
    meetWump(10), retract(meetWump(10)), assert(meetWump(12)),
    condition_D(2), arrow(1), retract(arrow(1)), assert(arrow(0)),
    update_action_num.


% 12.

% D.3 shoot, facing the wumpus
%|     |     |     |      |     |     |     |
%--------------------     --------------------
%|  X  |     |     |      |  X  |     |     |
%--------------------     --------------------
%|  ^  |     |     |      |  ^  |     |     |
run_agent([yes, _, no, no, no, no], shoot):-
    meetWump(11), retract(meetWump(11)), assert(meetWump(12)),
    condition_D(3), arrow(1), retract(arrow(1)), assert(arrow(0)),
    update_action_num.

% D.4, no wumpus, goforward and get close to wumpus
%|     |  X  |     |
%--------------------
%|     |     |     |
%--------------------
%|  ^  |     |     |
run_agent([no, no, no, no, no], goforward):-
    meetWump(11), retract(meetWump(11)), assert(meetWump(12)),
    condition_D(4),
    update_action_num, current_location(X, Y),
    revise_location(X,Y), display_world, assert(visited(X,Y)).

% 13.
%|     |  ~  |     |
%--------------------
%|     |     |     |
%--------------------
%|     |  ^  |     |
% D.2, after shoot, wumpus dead
run_agent([no, _, no, no, no, yes], goforward):-
    meetWump(12), retract(meetWump(12)), assert(meetWump(13)),
    condition_D(2), arrow(0), retract(wumpDead(0)), assert(wumpDead(1)),
    update_action_num, current_location(X, Y),
    revise_location(X,Y), display_world, assert(visited(X,Y)).

% D.3 wumpus killed
%|     |     |     |      |     |     |     |
%--------------------     --------------------
%|  ~  |     |     |      |  ~  |     |     |
%--------------------     --------------------
%|  ^  |     |     |      |  ^  |     |     |
run_agent([yes, _, no, no, no, yes], goforward):-
    meetWump(12), retract(meetWump(12)), assert(meetWump(13)),
    condition_D(3), arrow(0), retract(wumpDead(0)), assert(wumpDead(1)),
    update_action_num, current_location(X, Y),
    assert(occupy_wumpus(1)),
    revise_location(X,Y), display_world, assert(visited(X,Y)).

% D.4, no wumpus, goforward and get close to wumpus
%|     |  X  |     |
%--------------------
%|  ^  |     |     |
%--------------------
%|     |     |     |
run_agent([no, no, no, no, no], goforward):-
    meetWump(12), retract(meetWump(12)), assert(meetWump(13)),
    condition_D(4),
    update_action_num, current_location(X, Y),
    revise_location(X,Y), display_world, assert(visited(X,Y)).

% D.5 dangerous ahead, need turn left
%|  !  |  X  |     |
%--------------------
%|  ^  |     |     |
%--------------------
%|     |     |     |
run_agent([no, yes, no, no, no], turnleft):-
    meetWump(12), retract(meetWump(12)), assert(meetWump(13)),
    condition_D(4), retract(condition_D(4)), assert(condition_D(5)),
    ori_turnleft, update_action_num.

% 14
%|     |  ~  |     |
%--------------------
%|     |  ^  |     |
%--------------------
%|     |     |     |
% D.2, after shoot, wumpus dead
run_agent([no, _, no, no, no, yes], goforward):-
    meetWump(13), retract(meetWump(13)), assert(meetWump(14)),
    condition_D(2), wumpDead(1),
    update_action_num, current_location(X, Y), assert(occupy_wumpus(1)),
    revise_location(X,Y), display_world, assert(visited(X,Y)).

% D.4
%|  ^  |  X  |     |
%--------------------
%|     |     |     |
%--------------------
%|     |     |     |
run_agent([yes, no, no, no, no], turnright):-
    meetWump(13), retract(meetWump(13)), assert(meetWump(14)),
    condition_D(4),
    update_action_num, ori_turnright.

% D.5
%|  !  |  X  |     |
%--------------------
%|  >  |     |     |
%--------------------
%|     |     |     |
run_agent([no, yes, no, no, no], goforward):-
    meetWump(13), retract(meetWump(13)), assert(meetWump(14)),
    condition_D(5),
    update_action_num, current_location(X, Y),
    revise_location(X,Y), display_world, assert(visited(X,Y)).

% 15
% D.4, shoot!
%|  >  |  X  |     |
%--------------------
%|     |     |     |
%--------------------
%|     |     |     |
run_agent([yes, no, no, no, no], shoot):-
    meetWump(14), retract(meetWump(14)), assert(meetWump(16)),
    condition_D(4), arrow(1), retract(arrow(1)), assert(arrow(0)),
    update_action_num.

% D.5 turn to face the wumpus
%|  !  |  X  |     |
%--------------------
%|     |  >  |     |
%--------------------
%|     |     |     |
run_agent([yes, no, no, no, no], turnleft):-
    meetWump(14), retract(meetWump(14)), assert(meetWump(15)),
    condition_D(5),
    update_action_num, ori_turnleft.

% 16
% D.5 turn to face the wumpus
%|  !  |  X  |     |
%--------------------
%|     |  ^  |     |
%--------------------
%|     |     |     |
run_agent([yes, no, no, no, no], shoot):-
    meetWump(15), retract(meetWump(15)), assert(meetWump(16)),
    condition_D(5), arrow(1), retract(arrow(1)), assert(arrow(0)),
    update_action_num.

% 17, just go ahead...
run_agent([yes, no, no, no, no, yes], goforward):-
    meetWump(16), arrow(1), retract(arrow(1)), assert(arrow(0)),
    update_action_num, current_location(X, Y), assert(occupy_wumpus(1)),
    revise_location(X,Y), display_world, assert(visited(X,Y)).

% stench ends=======================================================================


% breeze =======================================================================
% meet breeze, turn around and run!!!!!
run_agent([_, yes, no, no, no], turnleft):-
    current_location(X,Y), current_orientation(Z),
    set_pit_check(X, Y, Z), retractall(meetPit(_)),
    assert(meetPit(0)), \+ meetWump(12),
    ori_turnleft, update_action_num.

% second turn
run_agent([_, yes, no, no, no], turnleft):-
    meetPit(0), retract(meetPit(0)), assert(meetPit(1)),
    ori_turnleft, update_action_num.

% then run
run_agent([_, yes, no, no, no], goforward):-
    meetPit(1),
    update_action_num, current_location(X, Y), assert(occupy_wumpus(1)),
    revise_location(X,Y), display_world.

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
    X > 0, X < 9, Y > 0, Y < 9,
    assert(pit_check(X,Y)).




% this is used with turn left/right action
ori_turnleft:-
    current_orientation(Z),
    retractall(current_orientation(_)),
    NewZ is (Z + 90) mod 360, assert(current_location(NewZ)).

ori_turnright:-
    current_orientation(Z),
    retractall(current_orientation(_)),
    NewZ is (Z - 90) mod 360, assert(current_location(NewZ)).

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
    X > 0, X < 9, Y > 0, Y < 9,
    assert(wumpus_check(X,Y)).









location_safe(X, Y):-
    !,
    X0 is X -1, Y0 is Y - 1, X1 is X + 1, Y1 is Y + 1,
    add_safe_location(X0,Y), add_safe_location(X1,Y),
    add_safe_location(X,Y1), add_safe_location(X,Y0).

add_safe_location(X,Y):-
    X>=1, Y>=1,
    !,
    assert(safelocation(X,Y)).

% when move (means action is goforward, execute the movement)
revise_location(X,Y):-
    current_orientation(0), X < 8,
    !,
    retractall(current_location(_,_)),
    NewX is X + 1,
    assert(current_location(NewX ,Y)).
revise_location(X,Y):-
    current_orientation(90), Y < 8,
    !,
    retractall(current_location(_,_)),
    NewY is Y + 1,
    assert(current_location(X ,NewY)).
revise_location(X,Y):-
    current_orientation(180), X>= 2,
    !,
    retractall(current_location(_,_)),
    NewX is X - 1,
    assert(current_location(NewX ,Y)).
revise_location(X,Y):-
    current_orientation(270),Y>= 2,
    !,
    retractall(current_location(_,_)),
    NewY is Y - 1,
    assert(current_location(X ,NewY)).

update_action_num:-
    num_actions(X),
    NewX is X + 1,
    !,
    retractall(num_actions(_)),
    assert(num_actions(NewX)).

abs2(X,Y) :- X < 0 -> Y is -X ; Y = X.
