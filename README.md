# ChessFidget

ChessFidget is a toy app for the Mac that lets you play chess against the computer.  It's written in Swift 3, so you'll need Xcode 8 or better to compile it.

Here's a binary you can run if you don't want to compile it from scratch:

- [ChessFidget 2016-09-27 14-01-27](https://github.com/aglee/ChessFidget/files/496365/ChessFidget.2016-09-27.14-01-27.zip)

I specifically did not write this app as an exercise in chess AI.  To generate the computer's moves, I use an open source chess engine called sjeng, plus a modified excerpt from Apple's source code for Chess.app.  Details are in the _README.md file that accompanies the relevant code.

I think "sjeng" is pronounced either "sheng" or "zheng" -- I think it's Dutch.

I wrote this app for two reasons.

Reason 1 was to learn Swift.  I learned Swift well enough to:

- Model the rules of chess in a reasonably Swifty way (I think), though I'm sure it could be Swiftier.
- Create a simple Cocoa application almost entirely in Swift.  (There's a little bit of Objective-C that isn't really my code but a modification of some code from Apple.)
- Do some simple bridging between Swift and Objective-C.

Note: my chess model detects checkmate and stalemate, but does not detect cases of a draw due to insufficient material or due to the 50-move rule.  As far as I know, it handles all the other rules of chess, though I've only tested this manually and not with rigorous unit tests.

Reason 2 for writing this app was to have an opponent I can easily beat, because I am terrible at chess and too lazy to get good.  ChessFidget lets you choose between two strength levels:

1. The computer plays very weak moves.
2. The computer plays totally random (but always legal) moves.  This weaker level is the default.

The UI for selecting the computer's strength level is yucky -- it doesn't take effect until you start a new game.  I may or may not get around to cleaning that up.

I noticed an odd thing about myself when the computer is playing in random-move mode.  Sometimes I have the illusion that it made a move "on purpose", even though I know perfectly well it chose the move randomly, since after all ***I programmed it that way***.  For example, the computer sometimes makes the correct move to deflect a threat, as if it had reasoned somehow about my intentions.  Another example: when the computer puts me in check, I feel like it is acting aggressively.  I don't know if I experience this illusion because I'm unusually suggestible or if it's an "uncanny valley" thing that others will experience as well.  Maybe there is a lesson here about how easy it is to read meaning into things.

A bit of history: in the late 1980's, my then-colleague Gabe Lawrence and I wrote a similar app, also for the Mac.  As I recall it was written in Object Pascal, and it ran as a desk accessory, or "DA".

