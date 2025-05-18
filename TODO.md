- **Still having the problem where sometimes no move is received from the Sjeng engine, we seem to be sitting there waiting forever.  Maybe I need to ping periodically?**
	- See commit 7f9bd97, where I corrected `outputPipe` to `errorPipe`.  I wonder if this will fix it.
- Handle failure to connect to chess engine, in case Apple moves it again, or removes it, or whatever.
- Is there a way to configure Sjeng without having to put the `sjeng.rc` file in the home directory?
- Follow up on the bug I found in Sjeng's `sd` command: <https://github.com/apple-oss-distributions/Chess/compare/main...aglee:Chess:main?expand=1>, FB17637104.
- Localize.
- Add a little randomization to the Mona Lisa practice layout.  This may mean it's not always guaranteed to work against a strong enough opponent, but it should still be doable if you get lucky and the lone King plays poorly enough.  The more randomness, the more difficult it's likely to be.
- Add the ability to play Mona Lisa with the black pieces, just for variety.
- Add ability to premove.
- If you click on one of your own pieces, then another, the second one should immediately become selected.
- Add ability to drag the mouse.
- Consider adding an eval bar.
- Show moves more clearly.
- Make move history visible, including half move clock.
- Instead of Sjeng, consider this Swift chess AI library, which looks a lot like what I want and is under an MIT license <https://github.com/SteveBarnegren/SwiftChess/tree/master>.  It looks like it could replace my own whole library outright -- but I'm not interested in that, I just want a lightweight AI engine.







