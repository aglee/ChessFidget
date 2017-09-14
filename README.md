# ChessFidget

ChessFidget is a toy app for the Mac that lets you play chess against the computer.  Compiling it requires Xcode 9.  I wrote this while at the [Recurse Center](https://www.recurse.com/) to help myself learn Swift.

ChessFidget lets you choose between two strength options:

1. The computer plays totally random (but always legal) moves.
2. The computer plays very weak moves.

Truth be told, option 1 gets boring after a while, but I sometimes still play it anyway.

Option 2 wasn't in my original plans -- my goal was simply to write a program that plays random chess moves, with no AI whatsoever -- but I discovered that every Mac has a built-in chess engine that anybody can access.  Inside Chess.app is a program called Sjeng that is a standalone command-line chess program.  You can run `/Applications/Chess.app/Contents/Resources/sjeng.ChessEngine` in Terminal and play chess by typing your moves.  I implemented Option 2 by communicating with a Sjeng process through pipes, the same way Chess.app does.  At first I copied and tweaked some of the Objective-C++ code from Chess.app (which is open source).  This was kind of a kludgy mess.  Later I replaced that with my own Swift code, so now this is a 100% Swift application.  I think it's pretty close to what I'd have written if I'd known Swift when I started.

