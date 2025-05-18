- **Still having the problem where sometimes no move is received from the Sjeng engine, we seem to be sitting there waiting forever.  Maybe I need to ping periodically?**
	- See commit 7f9bd97, where I corrected `outputPipe` to `errorPipe`.  I wonder if this will fix it.
- Handle failure to connect to chess engine, in case Apple moves it again, or removes it, or whatever.
- Is there a way to configure Sjeng without having to put the `sjeng.rc` file in the home directory?
- Follow up on the bug I found in Sjeng's `sd` command: <https://github.com/apple-oss-distributions/Chess/compare/main...aglee:Chess:main?expand=1>, FB17637104.
- Localize.






