/*
	File:		MBCEngineCommands.l
	Contains:	Encode commands sent by chess engine.
	Copyright:	© 2002 by Apple Computer, Inc., all rights reserved.

 
	[agl] NOTE: In Build Settings for the project or target, you need to add -R to "Other Lex Flags".
 
 
 */
%{
#include "MBCEngineCommands.h"

#define YY_SKIP_YYWRAP		1
#define YY_NO_UNPUT			1
#define YY_DECL				MBCCompactMove yylex(yyscan_t yyscanner)
#define YY_INPUT(buf,res,max_size) res = MBCReadInput(buf, max_size)
#define yywrap(x)           1
%}

ROW	([1-8])
COL	([a-h])
PIECE	([prnbqkPRNBQK])
%%
"move "{COL}{ROW}{COL}{ROW}\n			{ return MBCEncodeMove(yytext+yyleng-5, 0); }
"move "{PIECE}@{COL}{ROW}\n				{ return MBCEncodeDrop(yytext+yyleng-5, 0); }
"move "{COL}{ROW}{COL}{ROW}{PIECE}\n		{ return MBCEncodeMove(yytext+yyleng-6, 0); }
"ponder "{COL}{ROW}{COL}{ROW}\n			{ return MBCEncodeMove(yytext+yyleng-5, 1); }
"ponder "{PIECE}@{COL}{ROW}\n			{ return MBCEncodeDrop(yytext+yyleng-5, 1); }
"ponder "{COL}{ROW}{COL}{ROW}{PIECE}\n	{ return MBCEncodeMove(yytext+yyleng-6, 1); }
"Illegal move":.*\n                     { return MBCEncodeIllegal();	}
"Legal move":.*\n                     	{ return MBCEncodeLegal();	}
"pong ".*\n                     		{ return MBCEncodePong();	}
"tellics set 1 Sjeng ".*\n      	    { return MBCEncodeStartGame();	}
1-0.*\n									{ return MBCEncodeWhiteWins();  }
0-1.*\n									{ return MBCEncodeBlackWins();	}
"1/2-1/2".*\n							{ return MBCEncodeDraw();		}
.*\n									{ MBCIgnoredText(yytext);}
%%

void MBCLexerInit(MBCLexerInstance *scanner)
{
    yylex_init((yyscan_t*)scanner);
}

void MBCLexerDestroy(MBCLexerInstance scanner)
{
    yylex_destroy((yyscan_t)scanner);
}

MBCCompactMove MBCLexerScan(MBCLexerInstance scanner)
{
    return yylex((yyscan_t)scanner);
}
