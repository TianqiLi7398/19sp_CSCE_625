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
 assert(safelocation((1,1))),

  format('\n=====================================================\n'),
  format('This is init_agent:\n\tIt gets called once, use it for your initialization\n\n'),
  format('=====================================================\n\n').

%run_agent(Percept,Action):-

%run_agent(Percept, Action ):-
    %   'Percept = [Stench,Breeze,Glitter,Bump,Scream]
%             The five parameters are either 'yes' or 'no'.'

run_agent(Percept, Action ):-
     nth0(2, Percept, Glitter),
     Glitter,
    Action is grab,

  % check if it is breeze
%  nth0(0, Percept, Stench).
%  nth0(1, Percept, Breeze).
%  nth0(2, Percept, Glitter).
%  nth0(3, Percept, Bump  ).
%  nth0(4, Percept, Scream).
%    checkbreeze()
  
  format('\n=====================================================\n'),
  format('This is run_agent(.,.):\n\t It gets called each time step.\n\tThis default one simply moves forward\n'),
  format('You might find "display_world" useful, for your debugging.\n'),
  display_world,   
  format('=====================================================\n\n').



