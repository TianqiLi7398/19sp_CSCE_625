init_agent:-
  format('\n=====================================================\n'),
  format('This is init_agent:\n\tIt gets called once, use it for your initialization\n\n'),
  assert(agent_location(1,1)),
  format('=====================================================\n\n').


safe(X,Y):-
	X0 is X-1,
  wumpus_world_extent(E),         % check if agent off world
  X0 > 0,
  X0 =< E,
  !,
  safe(X0,Y).

safe(X,Y):-
	Y0 is Y-1,
    wumpus_world_extent(E),         % check if agent off world
    Y0 > 0,
    Y0 =< E,
    !,
	safe(X,Y0).

safe(X,Y):-
	Y0 is Y+1,
    wumpus_world_extent(E),         % check if agent off world
    Y0 > 0,
    Y0 =< E,
    !,
	safe(X,Y0).

safe(X,Y):-
    X0 is X+1,
	wumpus_world_extent(E),         % check if agent off world
    X0 > 0,
    X0 =< E,
    !,
	safe(X0,Y).

safe(_,_):-
	stench(no),
	breeze(no).

safe(_,_):-
	wumpus_health(dead),
	breeze(no).
%run_agent(Percept,Action):-


run_agent([_,_,yes,_,_],get_the_gold):-
format('\n=====================================================\n'),
  format('Hurray! We got the gold'),
  display_world,
  format('=====================================================\n\n').





run_agent([_,_,_,_,_],goforward):-
	agent_location(X,Y),
	safe(X,Y),
	format('\n=====================================================\n'),
	format('Can move forward'),
	display_world,
	format('=====================================================\n\n').

run_agent([_,_,_,_,_],turnleft):-
	agent_orientation(0),
	agent_location(X,Y),
	Y0 is Y+1,
	safe(X,Y0),
	format('\n=====================================================\n'),
	format('Turning Left'),
	display_world,
	format('=====================================================\n\n').

run_agent([_,_,_,_,_],turnleft):-
	agent_orientation(90),
	agent_location(X,Y),
	X0 is X-1,
	safe(X0,Y),
	format('\n=====================================================\n'),
	format('Turning Left'),
	display_world,
	format('=====================================================\n\n').

run_agent([_,_,_,_,_],turnleft):-
	agent_orientation(180),
	agent_location(X,Y),
	Y0 is Y-1,
	safe(X,Y0),
	format('\n=====================================================\n'),
	format('Turning Left'),
	display_world,
	format('=====================================================\n\n').

run_agent([_,_,_,_,_],turnleft):-
	agent_orientation(270),
	agent_location(X,Y),
	X0 is X+1,
	safe(X0,Y),
	format('\n=====================================================\n'),
	format('Turning Left'),
	display_world,
	format('=====================================================\n\n').

run_agent([_,_,_,_,_],turnright):-
	agent_orientation(270),
	agent_location(X,Y),
	X0 is X-1,
	safe(X0,Y),
	format('\n=====================================================\n'),
	format('Turning Right'),
	display_world,
	format('=====================================================\n\n').

run_agent([_,_,_,_,_],turnright):-
	agent_orientation(0),
	agent_location(X,Y),
	Y0 is Y-1,
	safe(X,Y0),
	format('\n=====================================================\n'),
	format('Turning Right'),
	display_world,
	format('=====================================================\n\n').

run_agent([_,_,_,_,_],turnright):-
	agent_orientation(90),
	agent_location(X,Y),
	X0 is X+1,
	safe(X0,Y),
	format('\n=====================================================\n'),
	format('Turning Right'),
	display_world,
	format('============== =======================================\n\n').

run_agent([_,_,_,_,_],turnright):-
	agent_orientation(180),
	agent_location(X,Y),
	Y0 is Y+1,
	safe(X,Y0),
	format('\n=====================================================\n'),
	format('Turning Right'),
	display_world,
	format('=====================================================\n\n').
