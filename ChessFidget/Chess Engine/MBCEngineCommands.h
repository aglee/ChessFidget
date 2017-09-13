/*
	File:		MBCEngineCommands.h
	Contains:	Encode commands sent by chess engine.
	Copyright:	� 2002 by Apple Inc., all rights reserved.
*/

#ifdef __cplusplus
extern "C" {
#endif

typedef unsigned MBCCompactMove;

extern MBCCompactMove MBCEncodeMove(const char * move, int ponder);
extern MBCCompactMove MBCEncodeDrop(const char * drop, int ponder);
extern MBCCompactMove MBCEncodeIllegal(void);
extern MBCCompactMove MBCEncodeLegal(void);
extern MBCCompactMove MBCEncodePong(void);
extern MBCCompactMove MBCEncodeStartGame(void);
extern MBCCompactMove MBCEncodeWhiteWins(void);
extern MBCCompactMove MBCEncodeBlackWins(void);
extern MBCCompactMove MBCEncodeDraw(void);
extern MBCCompactMove MBCEncodeTakeback(void);

extern void MBCIgnoredText(const char * text);
extern int MBCReadInput(char * buf, int max_size);

typedef void *          MBCLexerInstance;
extern void             MBCLexerInit(MBCLexerInstance*scanner);
extern void             MBCLexerDestroy(MBCLexerInstance scanner);
extern MBCCompactMove   MBCLexerScan(MBCLexerInstance scanner);

#ifdef __cplusplus
}
#endif
