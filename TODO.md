- **Still having the problem where sometimes no move is received from the Sjeng engine, we seem to be sitting there waiting forever.  Maybe I need to ping periodically?**
	- See commit 7f9bd97, where I corrected `outputPipe` to `errorPipe`.  I wonder if this will fix it.
- Add ability to premove.
- `var game` should probably be `weak`.
- Add a mate-in-one initial board option to help with testing.
- Impose a minimum window size.
- Detect when the Mona Lisa has failed.  The cases I can think of are losing a piece, promoting incorrectly (e.g. two dark-square bishops), and stalemate.
- Add a timer and a move counter to see how long it takes to do the Mona Lisa.
- Add a little randomization to the Mona Lisa practice layout.  This may mean it's not always guaranteed to work against a strong enough opponent, but it should still be doable if you get lucky and the lone King plays poorly enough.  The more randomness, the more difficult it's likely to be.  Randomness can be about placement of your pawns, placement of the kings, and adding some number of pawns on the opponent's side.  There are other challenges that could be thrown in too, like covering up squares so you can't see what pieces are on them.  Or the thing Aman said he's seen Ben Finegold do, lining up pieces along the side of the board instead of the bottom.  Maybe multiple boards at once?  Maybe a time limit.  Maybe a scoreboard.
- Add the ability to play Mona Lisa with the black pieces, just for variety.
- Set up initial board variations for useful exercises like mating with bishop and knight.
- Handle failure to connect to chess engine, in case Apple moves it again, or removes it, or whatever.

----

- Make an iPad version -- could be a way to study SwiftUI.
- Is there a way to configure Sjeng without having to put the `sjeng.rc` file in the home directory?
- Follow up on the bug I found in Sjeng's `sd` command: <https://github.com/apple-oss-distributions/Chess/compare/main...aglee:Chess:main?expand=1>, FB17637104.
- Localize.
- Consider adding an eval bar.
- Show moves more clearly (as in what moved from where to where; the red and blue square outlines only tell part of the story).
- Make move history visible, including half move clock.
- Instead of Sjeng, consider this Swift chess AI library, which looks a lot like what I want and is under an MIT license <https://github.com/SteveBarnegren/SwiftChess/tree/master>.  It looks like it could replace my own whole library outright -- but I'm not interested in that aspect, I just want a lightweight AI engine, and hopefully to learn from reading someone else's code.
- Add PGN methods.
- Add voice input.
- Add timestamps to moves to make games replayable with each move at actual speed.
- Thinking of changing how I think of the `Player` objects.  Each of them could be treated like a stream of moves.  The job of the `Game` object would then be to alternate between pulling from the two streams, rather than the current conceptual model, where it's each `Player` object's job to call `applyMove()`.
- Add an option to flip the board at any time regardless of which color the user is playing.

- Rename:
	- `squareName` -> `algebraicNotation` (maybe)





