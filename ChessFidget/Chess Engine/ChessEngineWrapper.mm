//
//  ChessEngineWrapper.mm
//
//  Created by Andy Lee on 9/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "ChessEngineWrapper.h"
#import "MBCBoard.h"
#import "MBCEngine.h"
#import "QuietLog.h"
#import "ChessFidget-Swift.h"

@interface ChessEngineWrapper ()
@property MBCEngine *engine;
@end

// Assumes computer vs. human.
@implementation ChessEngineWrapper

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

	_engine = [[MBCEngine alloc] init];
	_engine.engineOwner = self;
	_engine.logging = YES;
	[self _startObservingChessEngineNotifications];
	[_engine startGameWithSideToPlay:side];

	return self;
}

- (void)dealloc
{
	[self _stopObservingChessEngineNotifications];
}

- (void)sendMove:(NSString *)moveString
{
	QLog(@"sending move '%@'", moveString);
	MBCMove *move = [MBCMove newFromEngineMove:moveString];
	NSString *notificationName = (self._humanSide == kWhiteSide
								  ? MBCUncheckedWhiteMoveNotification
								  : MBCUncheckedBlackMoveNotification);
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:(id)move];
}

#pragma mark - Private methods

- (MBCSide)_computerSide
{
	return self.engine.fSide;
}

- (MBCSide)_humanSide
{
	switch (self._computerSide) {
		case kWhiteSide: return kBlackSide;
		case kBlackSide: return kWhiteSide;
		default:
			QLog(@"ERROR: Unexpected value for _computerSide: %d", self._computerSide);
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
			QLog(@"move by human (playing White) was approved: %@", move.engineMove);
		} else {
			QLog(@"move by computer (playing White) was received: %@", move.engineMove);
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:MBCEndMoveNotification object:self userInfo:(id)move];
	} else if ([notif.name isEqualToString:MBCBlackMoveNotification]) {
		if (self._humanSide == kBlackSide) {
			QLog(@"move by human (playing Black) was approved: %@", move.engineMove);
		} else {
			QLog(@"move by computer (playing Black) was received: %@", move.engineMove);
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:MBCEndMoveNotification object:self userInfo:(id)move];
	} else {
		QLog(@"got misc notification: '%@' %@", notif.name, move.engineMove);
	}
}

@end
