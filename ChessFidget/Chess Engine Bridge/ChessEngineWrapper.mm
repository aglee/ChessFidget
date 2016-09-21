//
//  ChessEngineWrapper.mm
//
//  Created by Andy Lee on 9/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "ChessEngineWrapper.h"
#import "MBCMove.h"
#import "MBCEngine.h"
#import "QuietLog.h"
#import "ChessFidget-Swift.h"

@interface ChessEngineWrapper ()
@property MBCEngine *backendEngine;
@end

@implementation ChessEngineWrapper

// MARK: - Factory methods

+ (instancetype)chessEngineWithComputerPlayingBlack
{
	return [[self alloc] initWithComputerPlayingSide:kBlackSide];
}

+ (instancetype)chessEngineWithComputerPlayingWhite
{
	return [[self alloc] initWithComputerPlayingSide:kWhiteSide];
}

- (id)initWithComputerPlayingSide:(MBCSide)side
{
	self = [super init];
	if (self == nil) {
		return nil;
	}

	_backendEngine = [[MBCEngine alloc] init];
	_backendEngine.engineOwner = self;
	_backendEngine.logging = YES;
	[self _startObservingChessEngineNotifications];
	[_backendEngine startGameWithSideToPlay:side];

	return self;
}

- (void)dealloc
{
	[self _stopObservingChessEngineNotifications];
}

// MARK: - Getters and setters

- (int)maxSearchDepth
{
	return self.backendEngine.maxSearchDepth;
}

- (void)setMaxSearchDepth:(int)maxSearchDepth
{
	self.backendEngine.maxSearchDepth = maxSearchDepth;
}

- (int)maxSecondsPerMove
{
	return self.backendEngine.maxSecondsPerMove;
}

- (void)setMaxSecondsPerMove:(int)maxSecondsPerMove
{
	self.backendEngine.maxSecondsPerMove = maxSecondsPerMove;
}

- (BOOL)shouldThinkWhileHumanIsThinking
{
	return self.backendEngine.shouldThinkWhileHumanIsThinking;
}

- (void)setShouldThinkWhileHumanIsThinking:(BOOL)shouldThinkWhileHumanIsThinking
{
	self.backendEngine.shouldThinkWhileHumanIsThinking = shouldThinkWhileHumanIsThinking;
}

// MARK: - Communicating with the chess engine

- (void)sendEngineHumanMove:(NSString *)moveString
{
	MLog(@"sending move to chess engine: '%@'", moveString);
	MBCMove *move = [MBCMove newFromEngineMove:moveString];
	NSString *notificationName = (self._humanSide == kWhiteSide
								  ? MBCUncheckedWhiteMoveNotification
								  : MBCUncheckedBlackMoveNotification);
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:(id)move];
}

// MARK: - Private methods

- (MBCSide)_computerSide
{
	return self.backendEngine.fSide;
}

- (MBCSide)_humanSide
{
	switch (self._computerSide) {
		case kWhiteSide: return kBlackSide;
		case kBlackSide: return kWhiteSide;
		default:
			MLog(@"ERROR: Unexpected value for _computerSide: %d", self._computerSide);
			return kWhiteSide;
	}
}

- (void)_startObservingChessEngineNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleChessNotification:) name:nil object:self];
}

- (void)_stopObservingChessEngineNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:self];
}

- (void)_handleChessNotification:(NSNotification *)notif
{
	MBCMove *move = (id)notif.userInfo;

	if ([notif.name isEqualToString:MBCWhiteMoveNotification]) {
		if (self._humanSide == kWhiteSide) {
			MLog(@"move by human (playing White) was approved: %@", move.engineMoveWithoutNewline);
			[self.game humanMoveWasApproved:move.engineMoveWithoutNewline];
		} else {
			MLog(@"move by computer (playing White) was received: %@", move.engineMoveWithoutNewline);
			[self.game computerMoveWasReceived:move.engineMoveWithoutNewline];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:MBCEndMoveNotification object:self userInfo:(id)move];
	} else if ([notif.name isEqualToString:MBCBlackMoveNotification]) {
		if (self._humanSide == kBlackSide) {
			MLog(@"move by human (playing Black) was approved: %@", move.engineMoveWithoutNewline);
			[self.game humanMoveWasApproved:move.engineMoveWithoutNewline];
		} else {
			MLog(@"move by computer (playing Black) was received: %@", move.engineMoveWithoutNewline);
			[self.game computerMoveWasReceived:move.engineMoveWithoutNewline];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:MBCEndMoveNotification object:self userInfo:(id)move];
	} else {
		MLog(@"got misc notification: '%@' %@", notif.name, move.engineMoveWithoutNewline);
	}
}

@end
