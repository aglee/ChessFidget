# ChessFidget

ChessFidget is a toy app for the Mac that lets you play chess against the computer.  You need Xcode 9 to compile it.  I wrote ChessFidget while at the [Recurse Center](https://www.recurse.com/) to help myself learn Swift by (a) modeling the rules of chess and (b) making a simple UI so I could learn the Swift equivalents for Cocoa stuff I already knew in Objective-C.  The UI also helped me test whether I'd modeled the rules of chess correctly.

ChessFidget lets you choose between two strength options:

1. The computer plays totally random (but always legal) moves.
2. The computer plays very weak moves.

Option 1 gets boring after a while, but I sometimes still play it anyway.

Option 2 wasn't in my original plans -- my goal was to write a program that plays random chess moves, with no AI whatsoever -- but I discovered that every Mac has a built-in chess engine that anybody can access.  You can try it yourself: run `/Applications/Chess.app/Contents/Resources/sjeng.ChessEngine` in Terminal and play chess by entering your moves in algebraic notation.  So I added the ability to play against Sjeng, with very low settings for strength.  This way it is less boring than option 1, but I still win most of the time (except when I hang a piece, as I am prone to do).  I can get a quick dopamine hit from the minor mental challenge.

ChessFidget communicates with a Sjeng process through pipes, the same way Chess.app does.  To do this, at first I copied and tweaked some of the Objective-C++ code from Chess.app (which is open source).  That was kind of a kludgy mess, but was helpful for learning how to bridge between Swift and Objective-C.  Later I replaced it with my own Swift code, so now ChessFidget is a 100% Swift application.

