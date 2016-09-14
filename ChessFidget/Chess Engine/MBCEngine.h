/*
	File:		MBCEngine.h
	Contains:	An agent representing the chess playing engine
	Copyright:	� 2002-2010 by Apple Inc., all rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MBCMove.h"

//
// Moves are sent to all interested parties. Trusted clients,
// e.g., chess engines, broadcast MBC*MoveNotification. Untrusted
// clients, e.g. human players, broadcast MBCUnchecked*MoveNotification,
// which is checked by the engine and either turned into a
// MBC*MoveNotification or a MBCIllegalMoveNotification. The legal move
// notification is executed by the board view (possibly using animation)
// and turned into a MBCEndMoveNotification.
//
extern NSString * const MBCGameLoadNotification;
extern NSString * const MBCGameStartNotification;

extern NSString * const MBCWhiteMoveNotification;
extern NSString * const MBCBlackMoveNotification;
extern NSString * const MBCUncheckedWhiteMoveNotification;
extern NSString * const MBCUncheckedBlackMoveNotification;
extern NSString * const MBCIllegalMoveNotification;
extern NSString * const MBCEndMoveNotification;
extern NSString * const MBCGameEndNotification;

extern NSString * const kMBCHumanPlayer;
extern NSString * const kMBCEnginePlayer;

//
// MBCEngine is an instance of MBCPlayer, but it also serves other
// purposes like move generation and checking.
//
@interface MBCEngine : NSObject <NSPortDelegate>
{
	NSTask *fEngineTask;	// The chess engine
	NSFileHandle *fToEngine;		// Writing to the engine
	NSFileHandle *fFromEngine;	// Reading from the engine
	NSPipe *fToEnginePipe;
	NSPipe *fFromEnginePipe;
	NSRunLoop *fMainRunLoop;

	NSPort *fEngineMoves;	// Moves parsed from engine
	NSPortMessage *fMove;			// 	... the move

	MBCMove *fLastMove;		// Last move played by player
	MBCSide fLastSide;		// Side of player
	bool fThinking;		// Engine currently thinking
	bool fWaitForStart;	// Wait for StartGame command
	bool fSetPosition;	// Position set up already
	bool fEngineEnabled;	// Engine moves enabled?
	bool fNeedsGo;		// Engine needs explicit start
//	MBCSide fSide;			// What side(s) engine is playing
	NSTimeInterval fDontMoveBefore;// Delay next engine move
	bool fIsLogging;
	NSFileHandle *fEngineLogFile;
	BOOL fHasObservers;
}

@property (nonatomic, weak) id engineOwner;
@property MBCSide fSide;

#pragma mark - Getters and setters

- (BOOL)isLogging;
- (void)setLogging:(BOOL)logging;
- (void)setSearchTime:(int)time;

#pragma mark - Time conversion

+ (int)secondsForTime:(int)time;

#pragma mark - Starting games

- (void)startGameWithSideToPlay:(MBCSide)sideToPlay;
- (void)startGameWithFEN:(NSString *)fen holding:(NSString *)holding moves:(NSString *)moves;

@end
