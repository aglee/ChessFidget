/*
	File:		MBCBoard.h
	Contains:	Fundamental move and board classes.
	Copyright:	� 2002-2012 by Apple Inc., all rights reserved.
*/

#import <Cocoa/Cocoa.h>
#import <stdio.h>

enum MBCSideCode {
    kPlayWhite,
    kPlayBlack,
    kPlayEither
};

enum MBCPieceCode {
	EMPTY = 0, 
	KING, QUEEN, BISHOP, KNIGHT, ROOK, PAWN,
	kWhitePiece = 0,
	kBlackPiece = 8,
	kPromoted	= 16,
	kPieceMoved	= 32
};
typedef unsigned char MBCPiece;

inline MBCPiece White(MBCPieceCode code) { return kWhitePiece | code; }
inline MBCPiece Black(MBCPieceCode code) { return kBlackPiece | code; }
inline MBCPieceCode Piece(MBCPiece piece){ return (MBCPieceCode)(piece&7); }
inline MBCPieceCode Color(MBCPiece piece){ return (MBCPieceCode)(piece&8); }
inline MBCPieceCode What(MBCPiece piece) { return (MBCPieceCode)(piece&15);} 
inline MBCPiece Matching(MBCPiece piece, MBCPieceCode code) 
                                         { return (piece & 8) | code; }
inline MBCPiece Opposite(MBCPiece piece) { return piece ^ 8; }
inline MBCPieceCode Promoted(MBCPiece piece) 
                                         { return (MBCPieceCode)(piece & 16); }
inline MBCPieceCode PieceMoved(MBCPiece piece) 
                                         { return (MBCPieceCode)(piece & 32); }

enum MBCMoveCode { 
	kCmdNull, 
	kCmdMove, 		kCmdDrop, 		kCmdUndo, 
	kCmdWhiteWins, 	kCmdBlackWins, 	kCmdDraw,
	kCmdPong, 		kCmdStartGame,
	kCmdPMove,		kCmdPDrop, 
	kCmdMoveOK
};

typedef unsigned char MBCSquare;

enum {
	kSyntheticSquare	= 0x70,
    kWhitePromoSquare	= 0x71,
	kBlackPromoSquare	= 0x72,
	kBorderRegion		= 0x73,
	kInHandSquare  		= 0x80,
	kInvalidSquare 		= 0xFF
};

inline unsigned  Row(MBCSquare square) { return 1+(square>>3); }
inline char 	 Col(MBCSquare square) { return 'a'+(square&7); }
inline MBCSquare Square(char col, unsigned row) { return ((row-1)<<3)|(col-'a'); }
inline MBCSquare Square(const char *colrow) { return ((colrow[1]-'1')<<3)|(colrow[0]-'a'); }

enum MBCCastling {
	kUnknownCastle, kCastleQueenside, kCastleKingside, kNoCastle
};

enum MBCSide {
	kWhiteSide, kBlackSide, kBothSides, kNeitherSide
};

inline bool SideIncludesWhite(MBCSide side) { return side==kWhiteSide || side==kBothSides; }
inline bool SideIncludesBlack(MBCSide side) { return side==kBlackSide || side==kBothSides; }

extern const MBCSide gHumanSide[];
extern const MBCSide gEngineSide[];

//
// A compact move has a very short existence and is only used in places
// where the information absolutely has to be kept to 32 bits.
//
typedef unsigned MBCCompactMove;

//
// MBCMove - A move
//
@interface MBCMove : NSObject
{
@public
    MBCMoveCode		fCommand;		// Command
    MBCSquare		fFromSquare;	// Starting square of piece if move
    MBCSquare		fToSquare;		// Finishing square if move or drop
    MBCPiece		fPiece;			// Moved or dropped piece
    MBCPiece		fPromotion;		// Pawn promotion piece
    MBCPiece		fVictim;		// Captured piece, set by [board makeMove]
    MBCCastling		fCastling;		// Castling move, set by [board makeMove]
    BOOL			fEnPassant;		// En passant, set by [board makeMove]
    BOOL           fCheck;        // Check, set by [board makeMove]
    BOOL           fCheckMate;    // Checkmate, set asynchronously
    BOOL 			fAnimate;		// Animate on board
}

+ (id)newWithCommand:(MBCMoveCode)command;
+ (id)moveWithCommand:(MBCMoveCode)command;
+ (id)newFromCompactMove:(MBCCompactMove)move;
+ (id)moveFromCompactMove:(MBCCompactMove)move;
+ (id)newFromEngineMove:(NSString *)engineMove;
+ (id)moveFromEngineMove:(NSString *)engineMove;

- (id)initWithCommand:(MBCMoveCode)command;
- (id)initFromCompactMove:(MBCCompactMove)move;
- (id)initFromEngineMove:(NSString *)engineMove;

+ (BOOL)compactMoveIsWin:(MBCCompactMove)move;

- (NSString *)localizedText;
- (NSString *)engineMove;
- (NSString *)origin;
- (NSString *)operation;
- (NSString *)destination;
- (NSString *)check;

@end

NSString * LocalizedString(NSDictionary * localization, NSString * key, NSString * fallback);

#define LOC(key, fallback) LocalizedString(localization, key, fallback)

