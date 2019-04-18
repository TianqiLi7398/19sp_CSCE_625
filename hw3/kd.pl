influenza.
smoking.

coughing :- smoking.
coughing :- influenza.

brid(swallow).
brid(robin).
brid(eagle).

eats(eagle, robin).

person(alice).
person(bob).
person(kate).
dog(rufus).

mammal(X) :- dog(X).
mammal(X) :- person(X).

understands(alice, bob).
understands(alice, kate).
understands(kate, alice).

friends(X,Y) :- person(X), person(Y), understands(X,Y).
