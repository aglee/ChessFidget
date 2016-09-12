/*
	File:		MBCEngineCommands.h
	Contains:	Encode commands sent by chess engine.
	Copyright:	� 2002 by Apple Inc., all rights reserved.
*/

#ifdef __cplusplus
#import "MBCBoard.h"
extern "C" {
#else
typedef unsigned MBCCompactMove;
#endif

extern MBCCompactMove MBCEncodeMove(const char * move, int ponder);
extern MBCCompactMove MBCEncodeDrop(const char * drop, int ponder);
extern MBCCompactMove MBCEncodeIllegal();
extern MBCCompactMove MBCEncodeLegal();
extern MBCCompactMove MBCEncodePong();
extern MBCCompactMove MBCEncodeStartGame();
extern MBCCompactMove MBCEncodeWhiteWins();
extern MBCCompactMove MBCEncodeBlackWins();
extern MBCCompactMove MBCEncodeDraw();
extern MBCCompactMove MBCEncodeTakeback();

extern void MBCIgnoredText(const char * text);
extern int MBCReadInput(char * buf, int max_size);

typedef void *          MBCLexerInstance;
extern void             MBCLexerInit(MBCLexerInstance*scanner);
extern void             MBCLexerDestroy(MBCLexerInstance scanner);
extern MBCCompactMove   MBCLexerScan(MBCLexerInstance scanner);

#ifdef __cplusplus
}
#endif
