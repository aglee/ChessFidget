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

/*
 Runs a chess engine in a subprocess (NSTask) and communicates with it via text commands and responses, using the "Chess Engine Communication Protocol" specified at <https://www.gnu.org/software/xboard/engine-intf.html>.

 Commands for setting the strength of the engine:

 - "sd DEPTH" specifies the max search depth the engine should go to.
 - "st TIME" specifies the max time the engine should spend per move.  The protocol says "TIME" can be either a number of seconds or a string like 05:30.
 - There is a "level" command for regulating time, with more sophisticated parameters.  The "level" command is not supported here.
 */
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

@property int maxSearchDepth;
@property int maxSecondsPerMove;

#pragma mark - Getters and setters

- (BOOL)isLogging;
- (void)setLogging:(BOOL)logging;
- (void)setMaxSearchDepth:(int)maxPly;

#pragma mark - Starting games

- (void)startGameWithSideToPlay:(MBCSide)sideToPlay;
- (void)startGameWithFEN:(NSString *)fen holding:(NSString *)holding moves:(NSString *)moves;

@end
