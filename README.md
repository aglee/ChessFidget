# ChessFidget

ChessFidget is a toy app for the Mac that lets you play chess against the computer.  I wrote ChessFidget while at the [Recurse Center](https://www.recurse.com/) to help myself learn Swift by (a) modeling the rules of chess and (b) making a simple UI so I could learn the Swift equivalents for Cocoa stuff I already knew in Objective-C.  The UI also helped me test whether I'd modeled the rules of chess correctly.

ChessFidget lets you choose between two strength options:

1. The computer plays totally random (but always legal) moves.
2. The computer plays very weak moves.

Option 1 gets boring after a while, but I sometimes still play it anyway.

Option 2 wasn't in my original plans -- my goal was to write a program that plays random chess moves, with no AI whatsoever -- but I discovered that every Mac has a built-in chess engine that anybody can access.  You can try it yourself: run `/Applications/Chess.app/Contents/Resources/sjeng.ChessEngine` in Terminal and play chess by entering your moves in algebraic notation.  So I added the ability to play against Sjeng, with very low settings for strength.  This way it is less boring than option 1, but I still win most of the time (except when I hang a piece, as I am prone to do).  I can get a quick dopamine hit from the minor mental challenge.

**NOTE 1:** At some point Chess.app got moved from `/Applications` to `/System/Applications`.

**NOTE 2:** As of Sequoia 15.4.1, there is a bug in `sjeng.ChessEngine` such that its search depth can't be set less than 40, at least not through the CLI.  I corrected this in a fork of Apple's Chess.app source code, at <https://github.com/aglee/Chess/commit/dfb16b3f32e5a6633d2119a9fec62cb86d159d00>.  I don't have permissions to file a pull request, so I submitted FB17637104 on Feedback Assistant, and pointed to my fix.  Until Apple fixes it, ChessFidget will take much longer to receive moves from Sjeng than it should, and the moves will be much stronger than intended.  I could build a fixed version of `sjeng.ChessEngine` and embed it in this app, but IIUC I'd have to GPL the whole app, and I don't want to do that.

ChessFidget communicates with a Sjeng process through pipes, the same way Chess.app does.  To do this, at first I copied and tweaked some of the Objective-C++ code from Chess.app (which is open source).  That was kind of a kludgy mess, but was helpful for learning how to bridge between Swift and Objective-C.  Later I replaced it with my own Swift code, so now ChessFidget is a 100% Swift application.

