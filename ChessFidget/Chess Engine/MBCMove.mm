/*
	File:		MBCMove.mm
	Contains:	Implementation of fundamental board and move classes
	Copyright:	© 2002-2011 by Apple Inc., all rights reserved.
 */

#import "MBCMove.h"
#import "MBCEngineCommands.h"

#import <string.h>
#include <ctype.h>

const MBCSide gHumanSide[] = {
	kBothSides, kWhiteSide, kBlackSide, kNeitherSide, kBothSides
};

const MBCSide gEngineSide[] = {
	kNeitherSide, kBlackSide, kWhiteSide, kBothSides, kNeitherSide
};

@implementation MBCMove

#pragma mark - Factory methods

+ (id)newWithCommand:(MBCMoveCode)command
{
	return [[self alloc] initWithCommand:command];
}

+ (id)moveWithCommand:(MBCMoveCode)command
{
	return [self newWithCommand:command];
}

+ (id)newFromCompactMove:(MBCCompactMove)move
{
	return [[self alloc] initFromCompactMove:move];
}

+ (id)moveFromCompactMove:(MBCCompactMove)move
{
	return [self newFromCompactMove:move];
}

+ (id)newFromEngineMove:(NSString *)engineMove
{
	return [[self alloc] initFromEngineMove:engineMove];
}

+ (id)moveFromEngineMove:(NSString *)engineMove
{
	return [self newFromEngineMove:engineMove];
}

#pragma mark - Init/awake/dealloc

- (id)initWithCommand:(MBCMoveCode)command
{
	self = [super init];
	if (self == nil) {
		return nil;
	}

	fCommand	=	command;
	fFromSquare	=	kInvalidSquare;
	fToSquare	=	kInvalidSquare;
	fPiece		=	EMPTY;
	fPromotion	= 	EMPTY;
	fVictim		= 	EMPTY;
	fCastling	=	kUnknownCastle;
	fEnPassant	= 	NO;
	fAnimate	=	YES;

	return self;
}

- (id)initFromCompactMove:(MBCCompactMove)move
{
	self = [self initWithCommand:MBCMoveCode(move >> 24)];
	if (self == nil) {
		return nil;
	}

	switch (fCommand) {
		case kCmdMove:
		case kCmdPMove:
			fFromSquare	= (move >> 16) & 0xFF;
			fToSquare	= (move >> 8)  & 0xFF;
			fPromotion	= move & 0xFF;
			break;
		case kCmdDrop:
		case kCmdPDrop:
			fToSquare	= (move >> 8)  & 0xFF;
			fPiece		= move & 0xFF;
			break;
		default:
			break;
	}

	return self;
}

- (id)initFromEngineMove:(NSString *)engineMove
{
	const char *piece = " KQBNRP  kqbnrp ";
	const char *move = [engineMove UTF8String];

	if (move[1] == '@') {
		self = [self initWithCommand:kCmdDrop];
		if (self) {
			fPiece = static_cast<MBCPiece>(strchr(piece, move[0])-piece);
			fToSquare = Square(move+2);
		}
	} else {
		self = [self initWithCommand:kCmdMove];
		if (self) {
			fFromSquare = Square(move);
			fToSquare = Square(move+2);

			if (move[4]) {
				fPromotion	= static_cast<MBCPiece>(strchr(piece, move[4])-piece);
			}
		}
	}

	return self;
}

#pragma mark - Getters and setters

- (NSString *)localizedText
{
	NSString *origin       = [self origin];
	NSString *operation    = [self operation];
	NSString *destination  = [self destinationForTitle:YES];
	NSString *check        = [self check];
	NSString *text;

	if ([origin length] || [destination length]) {
		text = [NSString localizedStringWithFormat:NSLocalizedString(@"title_move_fmt", "%@%@%@"),
				origin, operation, destination];
	} else {
		text = operation;
	}

	if ([check length]) {
		text = [NSString localizedStringWithFormat:NSLocalizedString(@"title_check_fmt", @"%@%@"),
				text, check];
	}

	return text;
}

- (NSString *)origin
{
	switch (fCommand) {
		case kCmdMove:
		case kCmdPMove:
			if (fCastling != kNoCastle) {
				return @"";
			} else {
				return [NSString localizedStringWithFormat:NSLocalizedString(@"move_origin_fmt", @"%@%c%c"),
						[self pieceLetter:fPiece forDrop:NO],
						Col(fFromSquare), Row(fFromSquare)+'0'];
			}
		case kCmdDrop:
		case kCmdPDrop:
			return [NSString localizedStringWithFormat:NSLocalizedString(@"drop_origin_fmt", @"%@"),
					[self pieceLetter:fPiece forDrop:YES]];
		default:
			return @"";
	}
}

- (NSString *)operation
{
	UniChar op = fVictim ? 0x00D7 : '-';
	switch (fCommand) {
		case kCmdMove:
		case kCmdPMove:
			switch (fCastling) {
				case kCastleQueenside:
					return @"0 - 0 - 0";
				case kCastleKingside:
					return @"0 - 0";
				default:
					break;
			}
			break;
		case kCmdDrop:
		case kCmdPDrop:
			op = '@';
			break;
		default:
			op = ' ';
			break;
	}
	return [NSString localizedStringWithFormat:NSLocalizedString(@"operation_fmt", @"%C"), op];
}

- (NSString *)destination
{
	return [self destinationForTitle:NO];
}

- (NSString *)check
{
	if (fCheckMate) {
		return NSLocalizedString(@"move_is_checkmate", @"­");
	} else if (fCheck) {
		return NSLocalizedString(@"move_is_check", @"+");
	} else {
		return @"";
	}
}

- (NSString *)engineMoveWithoutNewline
{
	const char *piece = " KQBNRP  kqbnrp ";

#define SQUARETOCOORD(sq) 	Col(sq), Row(sq)+'0'

	switch (fCommand) {
		case kCmdMove:
			if (fPromotion) {
				return [NSString stringWithFormat:@"%c%c%c%c%c",
						SQUARETOCOORD(fFromSquare),
						SQUARETOCOORD(fToSquare),
						piece[fPromotion&15]];
			} else {
				return [NSString stringWithFormat:@"%c%c%c%c",
						SQUARETOCOORD(fFromSquare),
						SQUARETOCOORD(fToSquare)];
			}
		case kCmdDrop:
			return [NSString stringWithFormat:@"%c@%c%c",
					piece[fPiece&15],
					SQUARETOCOORD(fToSquare)];
			break;
		default:
			return nil;
	}
}

- (NSString *)engineMove
{
	return [self.engineMoveWithoutNewline stringByAppendingString:@"\n"];
}

#pragma mark - Misc

+ (BOOL)compactMoveIsWin:(MBCCompactMove)move
{
	switch (move >> 24) {
		case kCmdWhiteWins:
		case kCmdBlackWins:
			return YES;
		default:
			return NO;
	}
}

static NSString *sPieceLetters[] = {
	@"",
	@"king_letter",
	@"queen_letter",
	@"bishop_letter",
	@"knight_letter",
	@"rook_letter",
	@"pawn_letter"
};

- (NSString *)pieceLetter:(MBCPiece)piece forDrop:(BOOL)drop
{
	piece = Piece(piece);
	if (!drop && piece==PAWN) {
		return @" ";
	} else {
		return NSLocalizedString(sPieceLetters[piece],
								 "Piece Letter");
	}
}

- (NSString *)destinationForTitle:(BOOL)forTitle
{
	NSString * check = [self check];
	NSString * text;

	if (fCastling != kNoCastle && fCastling != kUnknownCastle) {
		return check;
	} else if (fPromotion) {
		text = [NSString localizedStringWithFormat:NSLocalizedString(@"promo_dest_fmt", @"%c%c=@%"),
				Col(fToSquare), Row(fToSquare)+'0', [self pieceLetter:fPromotion forDrop:NO]];
	} else {
		text = [NSString localizedStringWithFormat:NSLocalizedString(@"move_dest_fmt", @"%c%c"),
				Col(fToSquare), Row(fToSquare)+'0'];
	}

	if ([check length]) {
		return [NSString localizedStringWithFormat:NSLocalizedString(@"dest_check_fmt", @"%@ %@"),
				text, check];
	} else {
		return text;
	}
}

@end



#pragma mark - Functions

MBCPiece Captured(MBCPiece victim)
{
	victim = Opposite(victim & ~kPieceMoved);

	if (Promoted(victim)) {	// Captured promoted pieces revert to pawns
		return Matching(victim, PAWN);
	} else {
		return victim;
	}
}

inline MBCCompactMove EncodeCompactMove(MBCMoveCode cmd, MBCSquare from, MBCSquare to, MBCPiece piece)
{
	return (cmd << 24) | (from << 16) | (to << 8) | piece;
}

inline MBCCompactMove EncodeCompactCommand(MBCMoveCode cmd)
{
	return cmd << 24;
}

MBCCompactMove MBCEncodeMove(const char * mv, int ponder)
{
	const char *piece = " kqbnrp ";
	const char *p;
	MBCPiece promo = EMPTY;

	if (mv[4] && (p = strchr(piece, mv[4]))) {
		promo = p - piece;
	}

	return EncodeCompactMove(ponder ? kCmdPMove : kCmdMove,
							 Square(mv+0), Square(mv+2), promo);
}

MBCCompactMove MBCEncodeDrop(const char * drop, int ponder)
{
	const char *piece = " KQBNRP  kqbnrp ";

	return EncodeCompactMove(ponder ? kCmdPDrop : kCmdDrop,
							 0, Square(drop+2),
							 strchr(piece, drop[0])-piece);
}

MBCCompactMove MBCEncodeIllegal()
{
	return EncodeCompactCommand(kCmdUndo);
}

MBCCompactMove MBCEncodeLegal()
{
	return EncodeCompactCommand(kCmdMoveOK);
}

MBCCompactMove MBCEncodePong()
{
	return EncodeCompactCommand(kCmdPong);
}

MBCCompactMove MBCEncodeStartGame()
{
	return EncodeCompactCommand(kCmdStartGame);
}

MBCCompactMove MBCEncodeWhiteWins()
{
	return EncodeCompactCommand(kCmdWhiteWins);
}

MBCCompactMove MBCEncodeBlackWins()
{
	return EncodeCompactCommand(kCmdBlackWins);
}

MBCCompactMove MBCEncodeDraw()
{
	return EncodeCompactCommand(kCmdDraw);
}

MBCCompactMove MBCEncodeTakeback()
{
	return EncodeCompactCommand(kCmdUndo);
}

