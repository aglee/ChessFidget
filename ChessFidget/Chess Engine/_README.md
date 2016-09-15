# Sjeng chess engine

ChessFidget uses the [sjeng](https://sjeng.org/) chess engine to generate moves played by the computer.  The files in this directory provide an Objective-C++ interface to sjeng.  sjeng.ChessEngine is a standalone binary executable that is launched in a subprocess.  Commands and responses are exchanged as plain text.

The Objective-C++ code here is a trimmed-down excerpt of Apple's code for Chess.app version 3.13, which uses sjeng in just this way.  Chess.app is open source.  You can browse the code at <http://opensource.apple.com/source/Chess/Chess-318/>.  A tarball of the source for Chess.app, including the source for sjeng, is included in this directory.  It was downloaded from <https://opensource.apple.com/tarballs/Chess/>.

