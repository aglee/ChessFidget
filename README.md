# ChessFidget

ChessFidget is a toy app that lets you play chess against the computer.

I wrote this app for two reasons.

Reason 1 was to learn Swift.  I learned Swift well enough to:

- Model the rules of chess in a reasonably Swifty way (I think), though I'm sure it could be Swiftier.
- Create a simple Cocoa application.
- Do some simple bridging with Objective-C.

My chess model does not detect the cases of a draw due to insufficient material or due to the 50-move rule.  As far as I know, it handles all the other rules of chess.

Reason 2 for writing this app was to have an opponent I can easily beat, because I am terrible at chess and too lazy to get good.  ChessFidget lets you choose between two strength levels:

1. The computer plays very weak moves.
2. The computer plays totally random (but always legal) moves.  This weaker level is the default.

I noticed an odd thing about myself when the computer is playing in random-move mode.  Sometimes I have the illusion that it made a move "on purpose", even though I know perfectly well it chose the move randomly, since after all ***I programmed it that way***.  For example, the computer sometimes makes the correct move to deflect a threat, as if it had reasoned somehow about my intentions.  When the computer puts me in check, I feel like it is acting aggressively.  I don't know if I experience this illusion because I'm unusually suggestible or if it's an "uncanny valley" thing that others will experience as well.  Maybe there is a lesson here about how easy it is to read meaning into things.

I specifically did not write this app as an exercise in writing a chess engine.  To generate the computer's moves, I use an open source chess engine called sjeng, plus a modified excerpt from Apple's source code for Chess.app.  Details are in the _README.md files that accompany the relevant code.

A bit of history: in the late 1980's, my then-colleague Gabe Lawrence and I wrote a similar app, also for the Mac.  As I recall it was written in Object Pascal, and it ran as a desk accessory, or "DA".

